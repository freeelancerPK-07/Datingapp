import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:version1/services/api_service.dart';

class WebRTCService extends ChangeNotifier {
  final String callId;
  final bool isCaller;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  io.Socket? _socket;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoOff = false;
  bool get isVideoOff => _isVideoOff;

  bool _isRemoteConnected = false;
  bool get isRemoteConnected => _isRemoteConnected;

  final List<RTCIceCandidate> _pendingCandidates = [];
  dynamic _pendingOffer;
  bool _hasRemoteDescription = false;
  bool _isOffering = false;
  Timer? _offerRetryTimer;

  WebRTCService({required this.callId, required this.isCaller});

  // Production STUN configuration (Google + Cloudflare + Mozilla)
  static const Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {'urls': 'stun:stun.cloudflare.com:3478'},
      {'urls': 'stun:stun.services.mozilla.com'},
    ],
  };

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    // Re-render when first remote video frame arrives
    remoteRenderer.onResize = () {
      debugPrint('[WebRTC] remoteRenderer video dimensions: ${remoteRenderer.videoWidth}x${remoteRenderer.videoHeight}');
      _isRemoteConnected = true;
      notifyListeners();
    };

    // 1. Acquire media (camera + mic)
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
      });
      localRenderer.srcObject = _localStream;
      notifyListeners();
      debugPrint('[WebRTC] Local media stream acquired successfully');
    } catch (e) {
      debugPrint('[WebRTC] Error acquiring media stream: $e');
    }

    // Set speakerphone on mobile
    try {
      Helper.setSpeakerphoneOn(true);
    } catch (_) {}

    // 2. Pre-create PeerConnection eagerly so tracks are bound before signaling starts
    await _createPeerConnection();

    // 3. Connect to backend signaling Socket
    _initSocket();
  }

  void _initSocket() {
    final serverUrl = ApiService.instance.baseUrl.replaceAll('/api/v1', '');
    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    // Register ALL event handlers BEFORE calling connect()
    _socket?.onConnect((_) async {
      debugPrint('[WebRTC Socket] Connected to $serverUrl');

      // 1. Initialize peer connection FIRST so we are ready before announcing join!
      await _createPeerConnection();

      // 2. NOW announce join to the room
      debugPrint('[WebRTC Socket] PeerConnection ready. Joining call_$callId');
      _socket?.emit('call:join', callId);

      if (isCaller) {
        // Send initial offer and start auto-retry timer until Answer is received
        await _createOffer();
        _startOfferRetryTimer();
      }
    });

    _socket?.on('call:peer-ready', (data) async {
      debugPrint('[WebRTC Socket] Received call:peer-ready in room call_$callId (isCaller=$isCaller)');
      if (isCaller) {
        await _createOffer();
      } else {
        _socket?.emit('webrtc:ready', {'callId': callId});
      }
    });

    _socket?.on('webrtc:ready', (data) async {
      debugPrint('[WebRTC Socket] Receiver is ready for offer (isCaller=$isCaller)');
      if (isCaller) {
        await _createOffer();
      }
    });

    _socket?.on('webrtc:offer', (data) async {
      debugPrint('[WebRTC Socket] Received webrtc:offer (isCaller=$isCaller)');
      if (!isCaller && data != null && data['sdp'] != null) {
        await _handleOffer(data['sdp']);
      }
    });

    _socket?.on('webrtc:answer', (data) async {
      debugPrint('[WebRTC Socket] Received webrtc:answer (isCaller=$isCaller)');
      if (isCaller && data != null && data['sdp'] != null) {
        _offerRetryTimer?.cancel();
        await _handleAnswer(data['sdp']);
      }
    });

    _socket?.on('webrtc:ice-candidate', (data) async {
      if (data != null && data['candidate'] != null) {
        try {
          final c = Map<String, dynamic>.from(data['candidate'] as Map);
          final mLine = c['sdpMLineIndex'];
          final candidate = RTCIceCandidate(
            c['candidate']?.toString(),
            c['sdpMid']?.toString(),
            mLine is int ? mLine : int.tryParse(mLine?.toString() ?? '0') ?? 0,
          );

          if (_hasRemoteDescription && _peerConnection != null) {
            await _peerConnection!.addCandidate(candidate);
          } else {
            _pendingCandidates.add(candidate);
          }
        } catch (e) {
          debugPrint('[WebRTC Socket] Error processing ICE candidate: $e');
        }
      }
    });

    // Connect now that all event listeners are ready
    _socket?.connect();
  }

  void _startOfferRetryTimer() {
    _offerRetryTimer?.cancel();
    // Auto-retry offer every 2s until remote answer arrives
    _offerRetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_hasRemoteDescription || _isRemoteConnected || !isCaller) {
        timer.cancel();
        return;
      }
      debugPrint('[WebRTC] Retrying SDP Offer for call_$callId...');
      await _createOffer();
    });
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) return;

    final configuration = <String, dynamic>{
      ..._iceServers,
      'sdpSemantics': 'unified-plan',
      'iceCandidatePoolSize': 10,
    };

    final constraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
        {'googIPv6': true},
      ],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);

    // Add local tracks to peer connection
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection?.addTrack(track, _localStream!);
      }
    }

    // Modern onTrack listener
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      debugPrint('[WebRTC] onTrack: ${event.track.kind}, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      } else if (remoteRenderer.srcObject != null) {
        remoteRenderer.srcObject!.addTrack(event.track);
      }
      _isRemoteConnected = true;
      notifyListeners();
    };

    // Android/Legacy onAddStream fallback
    _peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint('[WebRTC] onAddStream: id=${stream.id}');
      remoteRenderer.srcObject = stream;
      _isRemoteConnected = true;
      notifyListeners();
    };

    // Local ICE candidate generation (with null guard for gathering completion)
    _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null || candidate.candidate == null || candidate.candidate!.isEmpty) {
        return;
      }
      _socket?.emit('webrtc:ice-candidate', {
        'callId': callId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('[WebRTC] IceConnectionState: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _isRemoteConnected = true;
        notifyListeners();
      }
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('[WebRTC] PeerConnectionState: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _isRemoteConnected = true;
        notifyListeners();
      }
    };

    // If an offer arrived while PeerConnection was being created, handle it now!
    if (_pendingOffer != null && !isCaller) {
      debugPrint('[WebRTC] Processing queued offer after PeerConnection created');
      final off = _pendingOffer;
      _pendingOffer = null;
      await _handleOffer(off);
    }
  }

  Future<void> _drainPendingCandidates() async {
    _hasRemoteDescription = true;
    for (final candidate in _pendingCandidates) {
      try {
        await _peerConnection?.addCandidate(candidate);
      } catch (e) {
        debugPrint('[WebRTC] Error draining candidate: $e');
      }
    }
    _pendingCandidates.clear();
  }

  Future<void> _createOffer() async {
    if (_peerConnection == null || _isOffering) return;
    _isOffering = true;
    try {
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });
      await _peerConnection!.setLocalDescription(offer);
      _socket?.emit('webrtc:offer', {
        'callId': callId,
        'sdp': offer.toMap(),
      });
      debugPrint('[WebRTC] Sent SDP Offer for call_$callId');
    } catch (e) {
      debugPrint('[WebRTC] Error creating offer: $e');
    } finally {
      _isOffering = false;
    }
  }

  Future<void> _handleOffer(dynamic sdpData) async {
    if (_peerConnection == null) {
      debugPrint('[WebRTC] PeerConnection not ready yet, queuing incoming offer');
      _pendingOffer = sdpData;
      return;
    }
    try {
      final sdpMap = Map<String, dynamic>.from(sdpData as Map);
      final desc = RTCSessionDescription(
        sdpMap['sdp']?.toString(),
        sdpMap['type']?.toString(),
      );
      await _peerConnection!.setRemoteDescription(desc);
      await _drainPendingCandidates();

      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });
      await _peerConnection!.setLocalDescription(answer);

      _socket?.emit('webrtc:answer', {
        'callId': callId,
        'sdp': answer.toMap(),
      });
      debugPrint('[WebRTC] Created & sent SDP Answer for call_$callId');
    } catch (e) {
      debugPrint('[WebRTC] Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(dynamic sdpData) async {
    if (_peerConnection == null) return;
    try {
      final sdpMap = Map<String, dynamic>.from(sdpData as Map);
      final desc = RTCSessionDescription(
        sdpMap['sdp']?.toString(),
        sdpMap['type']?.toString(),
      );
      await _peerConnection!.setRemoteDescription(desc);
      await _drainPendingCandidates();
      debugPrint('[WebRTC] Applied remote SDP Answer for call_$callId');
    } catch (e) {
      debugPrint('[WebRTC] Error handling answer: $e');
    }
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final current = audioTracks[0].enabled;
        audioTracks[0].enabled = !current;
        _isMuted = !current;
        notifyListeners();
      }
    }
  }

  void toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final current = videoTracks[0].enabled;
        videoTracks[0].enabled = !current;
        _isVideoOff = !current;
        notifyListeners();
      }
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks[0]);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _offerRetryTimer?.cancel();

    _socket?.disconnect();
    _socket?.dispose();

    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();

    _peerConnection?.close();
    _peerConnection?.dispose();

    localRenderer.dispose();
    remoteRenderer.dispose();

    super.dispose();
  }
}

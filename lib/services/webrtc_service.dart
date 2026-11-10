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
  MediaStream? _fallbackRemoteStream;
  io.Socket? _socket;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _disposed = false;
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoOff = false;
  bool get isVideoOff => _isVideoOff;

  bool _isRemoteConnected = false;
  bool get isRemoteConnected => _isRemoteConnected;

  bool _hasTurnServer = false;
  bool get hasTurnServer => _hasTurnServer;

  String _connectionStatus = 'Starting camera...';
  String get connectionStatus => _connectionStatus;

  final List<RTCIceCandidate> _pendingRemoteCandidates = [];
  final List<Map<String, dynamic>> _pendingLocalCandidatesToSend = [];
  dynamic _pendingOffer;
  bool _hasRemoteDescription = false;
  bool _isOffering = false;
  bool _offerSent = false;
  bool _isHandlingOffer = false;
  bool _iceRestartAttempted = false;
  Timer? _iceRestartTimer;

  WebRTCService({required this.callId, required this.isCaller});

  // Live STUN fallback servers (no dead/blackholed endpoints)
  static const List<Map<String, dynamic>> _defaultStunServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun.cloudflare.com:3478'},
    {'urls': 'stun:global.relay.metered.ca:80'},
  ];

  void _setStatus(String status) {
    if (_disposed) return;
    _connectionStatus = status;
    notifyListeners();
  }

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    if (_disposed) return;

    // Re-render when first remote video frame arrives
    remoteRenderer.onResize = () {
      if (_disposed) return;
      debugPrint('[WebRTC] remoteRenderer video dimensions: ${remoteRenderer.videoWidth}x${remoteRenderer.videoHeight}');
      _isRemoteConnected = true;
      _connectionStatus = 'Live Video Connected';
      notifyListeners();
    };

    // 1. Acquire local camera + microphone
    _setStatus('Opening camera...');
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
          'frameRate': {'ideal': 24},
        },
      });
      if (_disposed) {
        _localStream?.dispose();
        return;
      }
      localRenderer.srcObject = _localStream;
      notifyListeners();
      debugPrint('[WebRTC] Local media stream acquired successfully');
    } catch (e) {
      debugPrint('[WebRTC] Error acquiring video+audio stream: $e');
      // Fallback to audio-only if camera fails or is busy
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      } catch (e2) {
        debugPrint('[WebRTC] Error acquiring fallback audio stream: $e2');
      }
    }

    if (_disposed) return;

    try {
      Helper.setSpeakerphoneOn(true);
    } catch (_) {}

    // 2. Fetch dynamic ICE (STUN + TURN) servers from backend (fast 3s timeout, STUN fallback)
    _setStatus('Preparing network...');
    List<Map<String, dynamic>> iceServers = List<Map<String, dynamic>>.from(_defaultStunServers);
    try {
      final res = await ApiService.instance.getIceServers();
      if (res != null && res['success'] == true && res['iceServers'] is List) {
        iceServers = (res['iceServers'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _hasTurnServer = res['hasTurn'] == true;
        debugPrint('[WebRTC] Loaded ${iceServers.length} ICE servers from backend (hasTurn=$_hasTurnServer, provider=${res['provider']})');
      }
    } catch (e) {
      debugPrint('[WebRTC] Using built-in STUN servers fallback: $e');
    }

    if (_disposed) return;

    // 3. Create PeerConnection with local tracks BEFORE signaling starts
    await _createPeerConnection(iceServers);
    if (_disposed) return;

    // 4. Connect to backend Socket.IO signaling server
    _setStatus('Connecting call room...');
    _initSocket();
  }

  void _initSocket() {
    final serverUrl = ApiService.instance.baseUrl.replaceAll('/api/v1', '');
    debugPrint('[WebRTC Socket] Connecting to $serverUrl for call_$callId (isCaller=$isCaller)');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) async {
      if (_disposed) return;
      debugPrint('[WebRTC Socket] Connected to $serverUrl');
      _setStatus(isCaller ? 'Waiting for other person to join...' : 'Waiting for caller video...');

      // Flush any ICE candidates generated earlier
      if (_pendingLocalCandidatesToSend.isNotEmpty) {
        for (final payload in _pendingLocalCandidatesToSend) {
          _socket?.emit('webrtc:ice-candidate', payload);
        }
        _pendingLocalCandidatesToSend.clear();
      }

      // Join room with role metadata so server replays buffered SDP/ICE if other peer arrived first
      _socket?.emit('call:join', {'callId': callId, 'isCaller': isCaller});
    });

    _socket?.onConnectError((err) {
      debugPrint('[WebRTC Socket] Connect error: $err');
      _setStatus('Signaling connection retrying...');
    });

    // Server tells us how many peers are already in the room right after call:join
    _socket?.on('call:room-state', (data) async {
      if (_disposed) return;
      final peerCount = (data is Map ? data['peerCount'] : 1) ?? 1;
      debugPrint('[WebRTC Socket] Room state call_$callId: peerCount=$peerCount (isCaller=$isCaller)');
      if (peerCount >= 2) {
        if (isCaller && !_offerSent) {
          await _createOffer();
          _scheduleIceRestartFallback();
        } else if (!isCaller && !_hasRemoteDescription) {
          _socket?.emit('webrtc:ready', {'callId': callId});
        }
      }
    });

    // Existing peer gets notified when the 2nd peer joins the room
    _socket?.on('call:peer-ready', (data) async {
      if (_disposed) return;
      debugPrint('[WebRTC Socket] Received call:peer-ready in call_$callId (isCaller=$isCaller, offerSent=$_offerSent)');
      if (isCaller) {
        if (!_offerSent) {
          await _createOffer();
          _scheduleIceRestartFallback();
        }
      } else if (!_hasRemoteDescription) {
        _socket?.emit('webrtc:ready', {'callId': callId});
      }
    });

    // Receiver explicitly signals readiness
    _socket?.on('webrtc:ready', (data) async {
      if (_disposed) return;
      debugPrint('[WebRTC Socket] Receiver ready in call_$callId (isCaller=$isCaller, offerSent=$_offerSent)');
      if (isCaller && !_offerSent) {
        await _createOffer();
        _scheduleIceRestartFallback();
      }
    });

    _socket?.on('webrtc:offer', (data) async {
      if (_disposed) return;
      debugPrint('[WebRTC Socket] Received webrtc:offer (isCaller=$isCaller)');
      if (!isCaller && data != null && data['sdp'] != null) {
        await _handleOffer(data['sdp']);
      }
    });

    _socket?.on('webrtc:answer', (data) async {
      if (_disposed) return;
      debugPrint('[WebRTC Socket] Received webrtc:answer (isCaller=$isCaller)');
      if (isCaller && data != null && data['sdp'] != null) {
        await _handleAnswer(data['sdp']);
      }
    });

    _socket?.on('webrtc:ice-candidate', (data) async {
      if (_disposed) return;
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
            _pendingRemoteCandidates.add(candidate);
          }
        } catch (e) {
          debugPrint('[WebRTC Socket] Error processing ICE candidate: $e');
        }
      }
    });

    _socket?.connect();
  }

  void _scheduleIceRestartFallback() {
    _iceRestartTimer?.cancel();
    _iceRestartTimer = Timer(const Duration(seconds: 9), () async {
      if (_disposed || _isRemoteConnected || !isCaller || _iceRestartAttempted) return;
      _iceRestartAttempted = true;
      debugPrint('[WebRTC] Call not connected after 9s; triggering clean ICE Restart...');
      _setStatus('Re-negotiating video connection...');
      await _createOffer(iceRestart: true);
    });
  }

  Future<void> _createPeerConnection(List<Map<String, dynamic>> iceServers) async {
    if (_peerConnection != null || _disposed) return;

    final configuration = <String, dynamic>{
      'iceServers': iceServers,
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
      ],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);
    if (_disposed) return;

    // Bind local audio & video tracks
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection?.addTrack(track, _localStream!);
      }
    }

    // Receive remote tracks (with unified-plan streams.isEmpty fallback)
    _peerConnection?.onTrack = (RTCTrackEvent event) async {
      if (_disposed) return;
      debugPrint('[WebRTC] onTrack: ${event.track.kind}, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      } else {
        _fallbackRemoteStream ??= await createLocalMediaStream('remote_$callId');
        await _fallbackRemoteStream!.addTrack(event.track);
        remoteRenderer.srcObject = _fallbackRemoteStream;
      }
      _isRemoteConnected = true;
      _connectionStatus = 'Live Video Connected';
      _iceRestartTimer?.cancel();
      notifyListeners();
    };

    // Legacy fallback
    _peerConnection?.onAddStream = (MediaStream stream) {
      if (_disposed) return;
      debugPrint('[WebRTC] onAddStream: id=${stream.id}');
      remoteRenderer.srcObject = stream;
      _isRemoteConnected = true;
      _connectionStatus = 'Live Video Connected';
      _iceRestartTimer?.cancel();
      notifyListeners();
    };

    // Local ICE candidate generation
    _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
      if (_disposed || candidate == null || candidate.candidate == null || candidate.candidate!.isEmpty) {
        return;
      }
      final payload = <String, dynamic>{
        'callId': callId,
        'isCaller': isCaller,
        'candidate': candidate.toMap(),
      };
      if (_socket != null && _socket!.connected) {
        _socket!.emit('webrtc:ice-candidate', payload);
      } else {
        _pendingLocalCandidatesToSend.add(payload);
      }
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      if (_disposed) return;
      debugPrint('[WebRTC] IceConnectionState: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateChecking) {
        _setStatus('Establishing video connection...');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _isRemoteConnected = true;
        _iceRestartTimer?.cancel();
        _setStatus('Live Video Connected');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _setStatus(_hasTurnServer
            ? 'Network firewall blocked direct stream. Retrying...'
            : 'Firewall blocked direct P2P. TURN server needed for cross-network calls.');
      }
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      if (_disposed) return;
      debugPrint('[WebRTC] PeerConnectionState: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _isRemoteConnected = true;
        _iceRestartTimer?.cancel();
        _setStatus('Live Video Connected');
      }
    };

    // Process offer if it arrived while PeerConnection was initializing
    if (_pendingOffer != null && !isCaller) {
      debugPrint('[WebRTC] Processing queued offer after PeerConnection created');
      final off = _pendingOffer;
      _pendingOffer = null;
      await _handleOffer(off);
    }
  }

  Future<void> _drainPendingRemoteCandidates() async {
    _hasRemoteDescription = true;
    for (final candidate in _pendingRemoteCandidates) {
      try {
        await _peerConnection?.addCandidate(candidate);
      } catch (e) {
        debugPrint('[WebRTC] Error draining candidate: $e');
      }
    }
    _pendingRemoteCandidates.clear();
  }

  Future<void> _createOffer({bool iceRestart = false}) async {
    if (_disposed || _peerConnection == null || _isOffering) return;
    _isOffering = true;
    try {
      _setStatus('Sending video request...');
      final offerOptions = <String, dynamic>{
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
        if (iceRestart) 'iceRestart': true,
      };
      final offer = await _peerConnection!.createOffer(offerOptions);
      if (_disposed) return;
      await _peerConnection!.setLocalDescription(offer);
      _offerSent = true;
      _socket?.emit('webrtc:offer', {
        'callId': callId,
        'sdp': offer.toMap(),
      });
      debugPrint('[WebRTC] Sent SDP Offer (iceRestart=$iceRestart) for call_$callId');
    } catch (e) {
      debugPrint('[WebRTC] Error creating offer: $e');
    } finally {
      _isOffering = false;
    }
  }

  Future<void> _handleOffer(dynamic sdpData) async {
    if (_disposed) return;
    if (_peerConnection == null) {
      debugPrint('[WebRTC] PeerConnection not ready yet, queuing incoming offer');
      _pendingOffer = sdpData;
      return;
    }
    if (_isHandlingOffer) return;
    _isHandlingOffer = true;
    try {
      _setStatus('Connecting incoming video...');
      final sdpMap = Map<String, dynamic>.from(sdpData as Map);
      final desc = RTCSessionDescription(
        sdpMap['sdp']?.toString(),
        sdpMap['type']?.toString(),
      );
      await _peerConnection!.setRemoteDescription(desc);
      await _drainPendingRemoteCandidates();

      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });
      if (_disposed) return;
      await _peerConnection!.setLocalDescription(answer);

      _socket?.emit('webrtc:answer', {
        'callId': callId,
        'sdp': answer.toMap(),
      });
      debugPrint('[WebRTC] Created & sent SDP Answer for call_$callId');
    } catch (e) {
      debugPrint('[WebRTC] Error handling offer: $e');
    } finally {
      _isHandlingOffer = false;
    }
  }

  Future<void> _handleAnswer(dynamic sdpData) async {
    if (_disposed || _peerConnection == null) return;
    try {
      final sigState = _peerConnection!.signalingState;
      if (sigState == RTCSignalingState.RTCSignalingStateStable) {
        debugPrint('[WebRTC] Ignoring duplicate answer; already in stable state');
        return;
      }
      final sdpMap = Map<String, dynamic>.from(sdpData as Map);
      final desc = RTCSessionDescription(
        sdpMap['sdp']?.toString(),
        sdpMap['type']?.toString(),
      );
      await _peerConnection!.setRemoteDescription(desc);
      await _drainPendingRemoteCandidates();
      _setStatus('Connecting video stream...');
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
    _disposed = true;
    _iceRestartTimer?.cancel();

    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}

    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream?.dispose();
    } catch (_) {}

    try {
      _fallbackRemoteStream?.dispose();
    } catch (_) {}

    try {
      _peerConnection?.close();
      _peerConnection?.dispose();
    } catch (_) {}

    localRenderer.dispose();
    remoteRenderer.dispose();

    super.dispose();
  }
}

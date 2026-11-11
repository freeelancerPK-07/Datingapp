import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:version1/services/api_service.dart';

class AgoraCallService extends ChangeNotifier {
  final String callId;
  final bool isCaller;
  final bool isVideoCall;

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  String? _channelId;
  String? get channelId => _channelId;

  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  VideoViewController? _localVideoController;
  VideoViewController? get localVideoController => _localVideoController;

  VideoViewController? _remoteVideoController;
  VideoViewController? get remoteVideoController => _remoteVideoController;
  int? _lastRemoteControllerUid;

  bool _localUserJoined = false;
  bool get localUserJoined => _localUserJoined;

  bool _isRemoteConnected = false;
  bool get isRemoteConnected => _isRemoteConnected;

  bool _isRemoteVideoOff = false;
  bool get isRemoteVideoOff => _isRemoteVideoOff;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoOff = false;
  bool get isVideoOff => _isVideoOff;

  bool _disposed = false;

  String _connectionStatus = 'Checking permissions...';
  String get connectionStatus => _connectionStatus;

  AgoraCallService({
    required this.callId,
    required this.isCaller,
    this.isVideoCall = true,
  });

  void _setStatus(String status) {
    if (_disposed) return;
    _connectionStatus = status;
    notifyListeners();
  }

  Future<void> initialize() async {
    // 1. Request Microphone & Camera runtime permissions on Android/iOS
    _setStatus('Requesting camera & mic permissions...');
    final permissions = <Permission>[
      Permission.microphone,
      if (isVideoCall) Permission.camera,
    ];
    final statuses = await permissions.request();
    if (_disposed) return;

    if (statuses[Permission.microphone] != PermissionStatus.granted ||
        (isVideoCall && statuses[Permission.camera] != PermissionStatus.granted)) {
      _setStatus('Please allow Camera & Microphone permissions in App Settings.');
      return;
    }

    // 2. Fetch Agora App ID, Channel Name & RTC Token from Render backend
    _setStatus('Fetching live call channel...');
    final credRes = await ApiService.instance.getAgoraCallCredentials(callId);
    if (_disposed) return;

    if (credRes['success'] != true || credRes['appId'] == null || credRes['channelName'] == null) {
      _setStatus(credRes['error']?.toString() ?? 'Failed to initialize Agora call session.');
      return;
    }

    final appId = credRes['appId'].toString().trim();
    final channelName = credRes['channelName'].toString().trim();
    final token = credRes['token']?.toString() ?? '';
    final uid = (credRes['uid'] is int) ? credRes['uid'] as int : 0;

    _channelId = channelName;

    // 3. Create and Initialize Agora RtcEngine
    _setStatus('Starting Agora live engine...');
    try {
      final rtcEngine = createAgoraRtcEngine();
      _engine = rtcEngine;

      await rtcEngine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      if (_disposed) return;

      // 4. Register Agora Event Handlers
      rtcEngine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('[Agora] Local user ${connection.localUid} joined $channelName (${elapsed}ms)');
            if (_disposed) return;
            _localUserJoined = true;
            _setStatus('Waiting for other person to join...');
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('[Agora] Remote user $remoteUid joined $channelName');
            if (_disposed) return;
            _remoteUid = remoteUid;
            _isRemoteConnected = true;
            _ensureRemoteController(remoteUid);
            _setStatus('Live Video Connected');
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('[Agora] Remote user $remoteUid went offline ($reason)');
            if (_disposed) return;
            if (_remoteUid == remoteUid) {
              _remoteUid = null;
              _remoteVideoController = null;
              _lastRemoteControllerUid = null;
              _isRemoteConnected = false;
              _setStatus('Other user disconnected...');
            }
          },
          onRemoteVideoStateChanged: (
            RtcConnection connection,
            int remoteUid,
            RemoteVideoState state,
            RemoteVideoStateReason reason,
            int elapsed,
          ) {
            if (_disposed) return;
            debugPrint('[Agora] Remote video state ($remoteUid): $state ($reason)');
            if (state == RemoteVideoState.remoteVideoStateStopped ||
                reason == RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted) {
              _isRemoteVideoOff = true;
            } else if (state == RemoteVideoState.remoteVideoStateDecoding ||
                state == RemoteVideoState.remoteVideoStateStarting) {
              _isRemoteVideoOff = false;
              _remoteUid = remoteUid;
              _isRemoteConnected = true;
              _ensureRemoteController(remoteUid);
            }
            notifyListeners();
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora Error] $err: $msg');
            if (_disposed) return;
            if (err == ErrorCodeType.errInvalidAppId) {
              _setStatus('Invalid Agora App ID on server. Update AGORA_APP_ID on Render.');
            } else if (err == ErrorCodeType.errInvalidToken || err == ErrorCodeType.errTokenExpired) {
              _setStatus('Invalid Agora Token. Check AGORA_APP_CERTIFICATE on Render.');
            } else {
              _setStatus('Agora error (${err.name}): $msg');
            }
          },
        ),
      );

      // 5. Enable Audio / Video & Local Camera Preview
      await rtcEngine.enableAudio();
      await rtcEngine.setDefaultAudioRouteToSpeakerphone(true);
      await rtcEngine.setEnableSpeakerphone(true);

      if (isVideoCall) {
        await rtcEngine.enableVideo();
        await rtcEngine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 24,
            bitrate: standardBitrate,
          ),
        );
        await rtcEngine.startPreview();
        _localVideoController = VideoViewController(
          rtcEngine: rtcEngine,
          canvas: const VideoCanvas(uid: 0),
        );
      } else {
        await rtcEngine.disableVideo();
      }

      if (_disposed) return;

      // 6. Join 1-on-1 Communication Channel
      _setStatus('Connecting to live room...');
      await rtcEngine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideoCall,
          publishCameraTrack: isVideoCall,
          publishMicrophoneTrack: true,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[Agora] Initialize exception: $e');
      _setStatus('Agora connection failed: $e');
    }
  }

  void _ensureRemoteController(int uid) {
    if (_engine == null || _channelId == null || uid == 0) return;
    if (_remoteVideoController == null || _lastRemoteControllerUid != uid) {
      _lastRemoteControllerUid = uid;
      _remoteVideoController = VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: _channelId),
      );
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    notifyListeners();
    try {
      await _engine?.muteLocalAudioStream(_isMuted);
    } catch (_) {}
  }

  Future<void> toggleVideo() async {
    _isVideoOff = !_isVideoOff;
    notifyListeners();
    try {
      await _engine?.muteLocalVideoStream(_isVideoOff);
      await _engine?.enableLocalVideo(!_isVideoOff);
    } catch (_) {}
  }

  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setSpeakerphone(bool enabled) async {
    try {
      await _engine?.setEnableSpeakerphone(enabled);
    } catch (_) {}
  }

  Future<void> _releaseEngine() async {
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _releaseEngine();
    super.dispose();
  }
}

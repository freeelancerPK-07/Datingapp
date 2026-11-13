import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:version1/services/api_service.dart';

class AgoraCallService extends ChangeNotifier {
  static Future<void>? _pendingRelease;

  final String callId;
  final bool isCaller;
  final bool isVideoCall;

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;
  RtcEngineEventHandler? _eventHandler;

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

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _permissionDeniedPermanently = false;
  bool get permissionDeniedPermanently => _permissionDeniedPermanently;

  bool _disposed = false;
  bool _previewStarted = false;

  String _connectionStatus = 'Checking permissions...';
  String get connectionStatus => _connectionStatus;

  AgoraCallService({
    required this.callId,
    required this.isCaller,
    this.isVideoCall = true,
  });

  void _setStatus(String status, {bool isError = false}) {
    if (_disposed) return;
    _connectionStatus = status;
    _hasError = isError;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_disposed) return;
    _hasError = false;
    _permissionDeniedPermanently = false;
    _localUserJoined = false;
    _isRemoteConnected = false;
    _previewStarted = false;

    // Wait for any previous engine release to complete (RtcEngine is a singleton)
    if (_pendingRelease != null) {
      try {
        await _pendingRelease;
      } catch (_) {}
    }
    if (_disposed) return;

    // 1. Check & Request Microphone & Camera runtime permissions with instant bypass if already granted
    _setStatus('Checking camera & mic...');
    bool micOk = false;
    bool camOk = false;

    try {
      final micCurrent = await Permission.microphone.status;
      final camCurrent =
          isVideoCall ? await Permission.camera.status : PermissionStatus.granted;

      if (micCurrent.isGranted && camCurrent.isGranted) {
        micOk = true;
        camOk = true;
      } else {
        _setStatus('Requesting camera & mic permissions...');
        final statuses = await [
          Permission.microphone,
          if (isVideoCall) Permission.camera,
        ].request().timeout(
          const Duration(seconds: 4),
          onTimeout: () => <Permission, PermissionStatus>{},
        );

        micOk = statuses[Permission.microphone]?.isGranted ??
            (await Permission.microphone.isGranted);
        camOk = !isVideoCall ||
            (statuses[Permission.camera]?.isGranted ??
                (await Permission.camera.isGranted));
      }
    } catch (e) {
      debugPrint('[Agora] Permission check fallback: $e');
      micOk = await Permission.microphone.isGranted;
      camOk = !isVideoCall || (await Permission.camera.isGranted);
    }
    if (_disposed) return;

    if (!micOk || !camOk) {
      final micStatus = await Permission.microphone.status;
      final camStatus = isVideoCall ? await Permission.camera.status : PermissionStatus.granted;
      _permissionDeniedPermanently =
          micStatus.isPermanentlyDenied || camStatus.isPermanentlyDenied;
      _setStatus(
        _permissionDeniedPermanently
            ? 'Camera or Microphone permission blocked. Open App Settings to allow access.'
            : 'Camera & Microphone permissions are required for calls.',
        isError: true,
      );
      return;
    }

    // 2. Fetch Agora App ID, Channel Name & RTC Token from backend
    _setStatus('Fetching live call channel...');
    final credRes = await ApiService.instance.getAgoraCallCredentials(callId);
    if (_disposed) return;

    if (credRes['success'] != true ||
        credRes['appId'] == null ||
        credRes['channelName'] == null) {
      _setStatus(
        credRes['error']?.toString() ?? 'Failed to initialize Agora call session.',
        isError: true,
      );
      return;
    }

    final appId = credRes['appId'].toString().trim();
    final channelName = credRes['channelName'].toString().trim();
    final token = credRes['token']?.toString() ?? '';
    final uid = (credRes['uid'] is int) ? credRes['uid'] as int : 0;

    if (appId.isEmpty || channelName.isEmpty) {
      _setStatus('Invalid Agora credentials from server.', isError: true);
      return;
    }

    _channelId = channelName;

    // 3. Create and Initialize Agora RtcEngine
    _setStatus('Starting Agora live engine...');
    String step = 'createEngine';
    try {
      final rtcEngine = createAgoraRtcEngine();
      _engine = rtcEngine;

      step = 'initialize';
      await rtcEngine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      if (_disposed) return;

      // 4. Register Agora Event Handlers
      step = 'registerEventHandler';
      _eventHandler = RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          debugPrint('[Agora] Local user ${connection.localUid} joined $channelName (${elapsed}ms)');
          if (_disposed) return;
          _localUserJoined = true;
          // Note: setEnableSpeakerphone must ONLY be called after joining channel (calling before throws -3 ERR_NOT_READY)
          try {
            await _engine?.setEnableSpeakerphone(true);
          } catch (e) {
            debugPrint('[Agora] Post-join speakerphone skipped: $e');
          }
          if (_disposed) return;
          if (!_isRemoteConnected) {
            _setStatus('Waiting for other person to join...');
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('[Agora] Remote user $remoteUid joined $channelName');
          if (_disposed) return;
          _remoteUid = remoteUid;
          _isRemoteConnected = true;
          _isRemoteVideoOff = false;
          _ensureRemoteController(remoteUid);
          _setStatus(isVideoCall ? 'Live Video Connected' : 'Live Voice Connected');
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
        onFirstRemoteVideoDecoded: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
          debugPrint('[Agora] First remote video decoded ($remoteUid: ${width}x$height)');
          if (_disposed) return;
          _isRemoteVideoOff = false;
          _remoteUid = remoteUid;
          _isRemoteConnected = true;
          _ensureRemoteController(remoteUid);
          _setStatus('Live Video Connected');
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
          if (reason == RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted ||
              state == RemoteVideoState.remoteVideoStateStopped) {
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
        onLocalVideoStateChanged: (VideoSourceType source, LocalVideoStreamState state, LocalVideoStreamReason error) {
          debugPrint('[Agora] Local video state ($source): $state (err: $error)');
          if (_disposed) return;
          if (state == LocalVideoStreamState.localVideoStreamStateFailed) {
            _setStatus('Camera capture error: ${error.name}', isError: true);
          }
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('[Agora] Connection state: $state ($reason)');
          if (_disposed) return;
          if (state == ConnectionStateType.connectionStateFailed) {
            _setStatus('Connection failed (${reason.name}). Tap Retry.', isError: true);
          }
        },
        onPermissionError: (PermissionType permissionType) {
          debugPrint('[Agora] Permission error callback: $permissionType');
          if (_disposed) return;
          _setStatus('Permission denied for ${permissionType.name}.', isError: true);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('[Agora Error] $err: $msg');
          if (_disposed) return;
          if (err == ErrorCodeType.errInvalidAppId) {
            _setStatus('Invalid Agora App ID on server.', isError: true);
          } else if (err == ErrorCodeType.errInvalidToken || err == ErrorCodeType.errTokenExpired) {
            _setStatus('Agora token rejected. Please retry.', isError: true);
          } else if (err == ErrorCodeType.errVdmCameraNotAuthorized || err == ErrorCodeType.errNoPermission) {
            _setStatus('Camera/Microphone access denied in device settings.', isError: true);
          } else {
            _setStatus('Agora error (${err.name}): $msg', isError: true);
          }
        },
      );
      rtcEngine.registerEventHandler(_eventHandler!);

      // 5. Enable Audio Module (pre-join default route only; speakerphone enabled after joinChannel)
      step = 'enableAudio';
      await rtcEngine.enableAudio();
      try {
        await rtcEngine.setDefaultAudioRouteToSpeakerphone(true);
      } catch (e) {
        debugPrint('[Agora] setDefaultAudioRouteToSpeakerphone skipped: $e');
      }

      // 6. Enable Video & Start Local Camera Preview IMMEDIATELY before joining channel
      if (isVideoCall) {
        step = 'enableVideo';
        await rtcEngine.enableVideo();
        await rtcEngine.enableLocalVideo(true);
        try {
          await rtcEngine.setVideoEncoderConfiguration(
            const VideoEncoderConfiguration(
              dimensions: VideoDimensions(width: 640, height: 480),
              frameRate: 24,
              bitrate: standardBitrate,
            ),
          );
        } catch (e) {
          debugPrint('[Agora] setVideoEncoderConfiguration skipped: $e');
        }

        _localVideoController = VideoViewController(
          rtcEngine: rtcEngine,
          canvas: const VideoCanvas(
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
          ),
        );

        step = 'startPreview';
        await rtcEngine.startPreview();
        _previewStarted = true;
        // Render local PiP camera preview immediately while joining channel
        if (!_disposed) notifyListeners();
      } else {
        await rtcEngine.disableVideo();
      }

      if (_disposed) return;

      // 7. Join 1-on-1 Communication Channel
      _setStatus('Connecting to live room...');
      step = 'joinChannel';
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
          enableAudioRecordingOrPlayout: true,
        ),
      );
      if (!_disposed) notifyListeners();
    } catch (e) {
      debugPrint('[Agora] Initialize exception at step=$step: $e');
      _setStatus('Agora $step failed: $e', isError: true);
    }
  }

  /// Called by AgoraVideoView.onAgoraVideoViewCreated so Android TextureView binds preview frames reliably
  Future<void> ensureLocalPreviewStarted() async {
    if (_disposed || !isVideoCall || _engine == null || _isVideoOff) return;
    try {
      if (!_previewStarted) {
        await _engine!.startPreview();
        _previewStarted = true;
      }
    } catch (e) {
      debugPrint('[Agora] ensureLocalPreviewStarted warning: $e');
    }
  }

  Future<void> retryConnection() async {
    if (_disposed) return;
    _hasError = false;
    _localVideoController = null;
    _remoteVideoController = null;
    _lastRemoteControllerUid = null;
    _remoteUid = null;
    _localUserJoined = false;
    _isRemoteConnected = false;
    _previewStarted = false;
    _setStatus('Reconnecting camera & room...');
    await _releaseEngine();
    if (!_disposed) {
      await initialize();
    }
  }

  void _ensureRemoteController(int uid) {
    if (_engine == null || _channelId == null || uid == 0) return;
    if (_remoteVideoController == null || _lastRemoteControllerUid != uid) {
      _lastRemoteControllerUid = uid;
      _remoteVideoController = VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: uid,
          renderMode: RenderModeType.renderModeHidden,
        ),
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
      if (!_isVideoOff && isVideoCall) {
        await _engine?.startPreview();
        _previewStarted = true;
      }
    } catch (_) {}
  }

  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setSpeakerphone(bool enabled) async {
    if (!_localUserJoined) return;
    try {
      await _engine?.setEnableSpeakerphone(enabled);
    } catch (_) {}
  }

  Future<void> _releaseEngine() {
    final engine = _engine;
    final handler = _eventHandler;
    _engine = null;
    _eventHandler = null;
    if (engine == null) return Future.value();

    final completer = Completer<void>();
    _pendingRelease = completer.future;

    () async {
      try {
        if (handler != null) {
          engine.unregisterEventHandler(handler);
        }
      } catch (_) {}
      try {
        await engine.stopPreview();
      } catch (_) {}
      try {
        await engine.leaveChannel();
      } catch (_) {}
      try {
        await engine.release();
      } catch (_) {}
      if (_pendingRelease == completer.future) {
        _pendingRelease = null;
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    }();

    return completer.future;
  }

  @override
  void dispose() {
    _disposed = true;
    _releaseEngine();
    super.dispose();
  }
}

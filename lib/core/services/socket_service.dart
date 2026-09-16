import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile_model.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  IO.Socket get socket => _socket!;

  void connect(String serverUrl, {int? userId}) {
    final authData = <String, dynamic>{};
    if (userId != null) {
      authData['userId'] = userId;
    }

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': kIsWeb ? ['polling', 'websocket'] : ['websocket', 'polling'],
      'autoConnect': true,
      'forceNew': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'timeout': 20000,
      'auth': authData,
    });

    _socket!.onConnect((_) {
      print('Connected to socket server: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    _socket!.onConnectError((data) {
      print('Socket connection error: $data');
    });

    _socket!.onError((data) {
      print('Socket error: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void sendMessage(int receiverId, String text) {
    _socket?.emit('send_message', {
      'receiverId': receiverId,
      'text': text,
    });
  }

  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  void offNewMessage() {
    _socket?.off('new_message');
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
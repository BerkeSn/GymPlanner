import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io;

class SocketService {
  SocketService._();
  static final SocketService instance =
      SocketService._();

  io.Socket? _socket;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final socketUrl = ApiConstants.baseUrl
        .replaceAll('/api/', '');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();
    _socket!.onConnect((_) {
      _socket!.emit('join_own_room', userId);
    });
  }

  void on(
    String event,
    void Function(dynamic data) callback,
  ) {
    _socket?.on(event, callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  // Mevcut off(String event) metodunu bununla DEĞİŞTİR:
  void off(
    String event, [
    void Function(dynamic data)? callback,
  ]) {
    if (callback != null) {
      _socket?.off(event, callback);
    } else {
      _socket?.off(event);
    }
  }
}

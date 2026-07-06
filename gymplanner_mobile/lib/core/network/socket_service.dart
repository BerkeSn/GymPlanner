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

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

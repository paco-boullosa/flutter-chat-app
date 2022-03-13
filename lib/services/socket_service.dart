// ignore_for_file: constant_identifier_names, library_prefixes

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat/global/environment.dart';

import 'package:chat/services/auth_service.dart';

// enumerador para identificar el estado del servidor
enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

// const String _SERVER_URL = 'http://127.0.0.1:3000';
// const String _SERVER_URL = 'http://localhost:3000';
// const String _SERVER_URL = 'http://192.168.1.136:3000';
// const String _SERVER_URL = 'http://10.0.2.2:3000';
// const String _SERVER_URL = 'https://flutter-socket-server-rock.herokuapp.com/';

class SocketService with ChangeNotifier {
  // ChangeNotifier ayuda a decirle Provider cuando tiene que refrescar el UI o redibujar algun widget

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket!;

  void conectarSocket() async {
    // tenemos que enviar el token al servidor de sockets para que el server pueda
    // comprobar que es un JWT valido
    final token = await AuthService.getToken();

    _socket = IO.io(
        Environment.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect() // por defecto ya es true
            .enableForceNew()
            .setExtraHeaders({'x-token': token})
            .build());

    _socket!.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      // socket.emit('mensaje', 'conectado desde app Flutter');
    });

    _socket!.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // _socket!.on('nuevo-mensaje', (payload) {
    //   // print('nuevo-mensaje: $payload');
    //   print('nombre:' + payload['nombre']);
    //   print('mensaje:' + payload['mensaje']);
    // });
  }

  void desconectarSocket() {
    _socket?.disconnect();
  }
}

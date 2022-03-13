import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:chat/global/environment.dart';
import 'package:chat/models/usuario.dart';
import 'package:chat/models/mensaje_response.dart';
import 'package:chat/services/auth_service.dart';

// este servicio permite comunicar por chat a un usuario con otros
class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future<List<Mensaje>> getChat(String usuarioID) async {
    final Uri url = Uri(
      scheme: Environment.apiProtocolo,
      host: Environment.apiUrl,
      port: Environment.apiPort,
      path: '${Environment.apiRutaBase}/mensajes/$usuarioID',
    );
    final token = await AuthService.getToken();
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token.toString(),
      },
    );

    final mensajesResponse = mensajesResponseFromJson(resp.body);

    return mensajesResponse.mensajes;
  }
}

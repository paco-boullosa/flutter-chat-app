import 'package:http/http.dart' as http;

import 'package:chat/global/environment.dart';
import 'package:chat/models/usuario.dart';
import 'package:chat/models/usuarios_response.dart';
import 'package:chat/services/auth_service.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final Uri url = Uri(
        scheme: Environment.apiProtocolo,
        host: Environment.apiUrl,
        port: Environment.apiPort,
        path: '${Environment.apiRutaBase}/usuarios',
      );
      final token = await AuthService.getToken();

      final resp = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-token': token.toString(),
        },
      );

      final usuariosResponse = usuariosResponseFromJson(resp.body);

      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}

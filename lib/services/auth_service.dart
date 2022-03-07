import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';
import 'package:chat/models/usuario.dart';
import 'package:chat/models/login_response.dart';

class AuthService with ChangeNotifier {
  late Usuario usuario;
  bool _autenticando = false;
  // Crea storage
  final _storage = const FlutterSecureStorage();

  // getters y setters de variables
  bool get autenticando {
    return (_autenticando == true) ? true : false;
  }

  // Getters del token de forma estatica
  static Future<String?> getToken() async {
    // al ser estatico no tiene acceso a las propiedades de la clase (como _storage, por eso se vuelve a crear)
    const _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    const _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  set autenticando(bool valor) {
    _autenticando = valor;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // creamos el payload para enviarselo al backend
    autenticando = true;
    final data = {
      'email': email,
      'password': password,
    };
    final Uri url = Uri(
      scheme: Environment.apiProtocolo,
      host: Environment.apiUrl,
      port: Environment.apiPort,
      path: '${Environment.apiRutaBase}/login',
    );

    final resp = await http.post(
      url,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      // guardar el token en el telefono
      await _guardarToken(loginResponse.token);
      return true; // login correcto
    } else {
      return false; // login incorrecto
    }
  }

  Future<String> registrarNuevoUsuario(
      String nombre, String email, String password) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Son obligatorios todos los campos';
    }
    autenticando = true;
    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };
    final Uri url = Uri(
      scheme: Environment.apiProtocolo,
      host: Environment.apiUrl,
      port: Environment.apiPort,
      path: '${Environment.apiRutaBase}/login/new',
    );
    final resp = await http.post(
      url,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
    autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      await _guardarToken(loginResponse.token);
      return '';
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> estaLogueado() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      return false;
    }
    // comprobar si el token es valido
    final Uri url = Uri(
      scheme: Environment.apiProtocolo,
      host: Environment.apiUrl,
      port: Environment.apiPort,
      path: '${Environment.apiRutaBase}/login/renovar',
    );
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token,
      },
    );
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      await _guardarToken(loginResponse.token);
      return true;
    } else {
      logout(); // si el token no es valido es mejor borrarlo del storage
      return false;
    }
  }

  Future _guardarToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token'); // eliminar token
  }
}

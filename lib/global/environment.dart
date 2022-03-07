// Se crea una clase que solo contiene metodos estaticos
// Al ser estaticos, se puede acceder a ellos sin necesidad de instanciar la clase

import 'dart:io';

class Environment {
  static String apiProtocolo = 'http';
  static String apiUrl = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  static int apiPort = 3000;
  static String apiRutaBase = '/api';

  static String socketUrl =
      Platform.isAndroid ? 'http://127.0.0.1:3000' : 'http://localhost:3000';
}

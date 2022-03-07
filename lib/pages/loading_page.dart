import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/pages/usuarios_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: comprobarEstadoLogin(context),
        builder: (context, snapshot) {
          return const Center(
            child: Text('Espere un momento...'),
          );
        },
      ),
    );
  }

  Future comprobarEstadoLogin(BuildContext context) async {
    // se envia el context para poder hacer la navegacion

    final authService = Provider.of<AuthService>(context, listen: false);
    final autenticado = await authService.estaLogueado();
    if (autenticado) {
      // TODO: conectar al socket server
      // Navigator.pushReplacementNamed(context, 'usuarios');
      // --- Mejor se pone como abajo para que no haga una transicion de pagina
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const UsuariosPage(),
            transitionDuration: const Duration(milliseconds: 0),
          ));
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }
}

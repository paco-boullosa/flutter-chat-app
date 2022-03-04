import 'package:flutter/material.dart';

class LoginPie extends StatelessWidget {
  final String link;

  const LoginPie({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textoPie;
    String textoLink;
    if (link != 'register') {
      textoPie = '¿Ya tienes una cuenta?';
      textoLink = 'Accede con tu usuario';
    } else {
      textoPie = '¿No tienes cuenta?';
      textoLink = 'Crea una ahora';
    }
    return Column(
      children: [
        Text(textoPie,
            style: const TextStyle(
                color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w300)),
        const SizedBox(height: 10),
        GestureDetector(
          child: Text(textoLink,
              style: TextStyle(
                  color: Colors.blue[600], fontSize: 18, fontWeight: FontWeight.bold)),
          onTap: () {
            Navigator.pushReplacementNamed(context, link);
          },
        ),
      ],
    );
  }
}

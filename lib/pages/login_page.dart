import 'package:flutter/material.dart';

import 'package:chat/widgets/login_logo.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/custom_btn.dart';
import 'package:chat/widgets/login_pie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          // para evitar que no quepa en pantalla cuando se despliega el teclado
          physics: const BouncingScrollPhysics(), // para que rebote como en iPhone
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .9,
            // para que ocupe todo el alto de la pantalla (se * por 90% por los paddings)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LoginLogo(titulo: 'Messenger'),
                const _Formulario(),
                const LoginPie(link: 'register'),
                _Legal(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario({Key? key}) : super(key: key);
  @override
  State<_Formulario> createState() => __FormularioState();
}

class __FormularioState extends State<_Formulario> {
  // al ser un StatefulWidget se pueden definir los controladores
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          CustomInput(
            icono: Icons.mail_outline,
            placeholder: 'Correo electrónico',
            tipoTeclado: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icono: Icons.lock_outlined,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          CustomBtn(
            textoBoton: 'Acceder',
            onPressed: () {
              print(emailCtrl.text);
              print(passCtrl.text);
            },
          ),
        ],
      ),
    );
  }
}

class _Legal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('Términos y condiciones de uso',
            style: TextStyle(fontWeight: FontWeight.w200)),
        SizedBox(height: 10)
      ],
    );
  }
}

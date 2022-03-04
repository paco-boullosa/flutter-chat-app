import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final IconData icono;
  final String placeholder;
  final TextEditingController textController;
  final TextInputType tipoTeclado;
  final bool isPassword;

  const CustomInput({
    Key? key,
    required this.icono,
    required this.placeholder,
    required this.textController,
    this.tipoTeclado = TextInputType.text,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5, right: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5),
              blurRadius: 5,
            )
          ]),
      child: TextField(
        controller: textController,
        autocorrect: false,
        keyboardType: tipoTeclado,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icono),
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          hintText: placeholder,
        ),
      ),
    );
  }
}

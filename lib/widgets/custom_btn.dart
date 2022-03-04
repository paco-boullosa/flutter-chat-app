import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String textoBoton;
  final Function() onPressed;

  const CustomBtn({
    Key? key,
    required this.textoBoton,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(textoBoton, style: const TextStyle(fontSize: 18)),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

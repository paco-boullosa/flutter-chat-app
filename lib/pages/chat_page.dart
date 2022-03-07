import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat/widgets/mensaje_chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

// para mostrar animaciones hay que indicarle al widget del State que debe
// sincronizarse con el vertical sync y para ello hay que hacer mixin con
// TickerProviderStateMixin
class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _estamosEscribiendo = false;

  final List<MensajeChat> _mensajes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Column(
            children: [
              CircleAvatar(
                child: const Text('Te', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[100],
                maxRadius: 15,
              ),
              const SizedBox(height: 3),
              const Text('Nombre de Usuario',
                  style: TextStyle(color: Colors.black54, fontSize: 12))
            ],
          )),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              reverse: true, // en un chat lo mas reciente esta abajo
              itemCount: _mensajes.length,
              itemBuilder: (_, i) => _mensajes[i],
            ),
          ),
          const Divider(height: 1),
          // caja de texto donde se escribe
          Container(
            color: Colors.white,
            // height: 70,
            child: _inputChat(),
          )
        ],
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _gestionarSubmit,
                onChanged: (String texto) {
                  // solo se postea cuando tiene contenido
                  if (texto.trim().isNotEmpty) {
                    setState(() {
                      _estamosEscribiendo = true;
                    });
                  } else {
                    setState(() {
                      _estamosEscribiendo = false;
                    });
                  }
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar mensaje',
                ),
                focusNode: _focusNode, // para controlar el foco
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: const Text('Enviar'),
                      onPressed: _estamosEscribiendo
                          ? () => _gestionarSubmit(_textController.text.trim())
                          : null,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: const IconThemeData(color: Colors.blue),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.send),
                          onPressed: _estamosEscribiendo
                              ? () => _gestionarSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _gestionarSubmit(String texto) {
    if (texto.isEmpty) return;

    _focusNode.requestFocus(); // mantiene el foco en la caja de texto (si se pulso enter)
    // borra la caja de texto (pq ya se envió)
    _textController.clear();
    final nuevoMensaje = MensajeChat(
      uid: '123',
      texto: texto,
      animationController: AnimationController(
        vsync: this, // para eso es necesario el mixin del TickerProviderStateMixin
        duration: const Duration(milliseconds: 300),
      ),
    );
    _mensajes.insert(0, nuevoMensaje);
    nuevoMensaje.animationController.forward(); // para que lance la animacion

    setState(() {
      _estamosEscribiendo = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // off del socket
    // liberar memoria
    for (MensajeChat mensaje in _mensajes) {
      mensaje.animationController.dispose();
    }
    super.dispose();
  }
}

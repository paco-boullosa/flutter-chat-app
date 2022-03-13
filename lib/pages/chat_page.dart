// esta es la pagina de chat (conversacion) entre 2 usuarios

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/models/mensaje_response.dart';

import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/auth_service.dart';

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

  final List<MensajeChat> _mensajes = []; // contiene toda la conversacion entre 2 users

  late ChatService chatService;
  SocketService socketService = SocketService(); // se instancia porque tiene el emit
  late AuthService authService; // se instancia pq contiene la info del usuario que emite

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    // escucha si llega algun mensaje
    socketService.socket.on('mensaje-personal', (data) => _escuchaMensaje);

    // carga los mensajes anteriores de la BD
    _cargarHistorial(chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioID) async {
    List<Mensaje> chatHistorico = await chatService.getChat(usuarioID);

    final history = chatHistorico.map(
      (m) => MensajeChat(
        texto: m.mensaje,
        uid: m.de,
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 0),
        )..forward(),
      ),
    );

    setState(() {
      _mensajes.insertAll(0, history);
    });
  }

  void _escuchaMensaje(dynamic payload) {
    // carga la instancia del mensaje con la info recibida
    MensajeChat mensaje = MensajeChat(
      texto: payload['mensaje'],
      uid: payload['de'],
      animationController:
          AnimationController(vsync: this, duration: const Duration(milliseconds: 300)),
    );
    setState(() {
      _mensajes.insert(0, mensaje); // añade el mensaje a la conversacion
    });
    mensaje.animationController.forward(); // realiza la animacion
  }

  @override
  Widget build(BuildContext context) {
    final usuarioPara = chatService.usuarioPara;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Column(
            children: [
              CircleAvatar(
                child: Text(usuarioPara.nombre.substring(0, 2),
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[100],
                maxRadius: 15,
              ),
              const SizedBox(height: 3),
              Text(usuarioPara.nombre,
                  style: const TextStyle(color: Colors.black54, fontSize: 12))
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
      uid: authService.usuario.uid,
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

    socketService.socket.emit('mensaje-personal', {
      'de': authService.usuario.uid,
      'para': chatService.usuarioPara.uid,
      'mensaje': texto,
    });
  }

  @override
  void dispose() {
    // liberar memoria
    for (MensajeChat mensaje in _mensajes) {
      mensaje.animationController.dispose();
    }
    // deja de escuchar los mensajes
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}

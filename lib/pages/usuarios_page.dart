import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat/models/usuario.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/usuarios_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({Key? key}) : super(key: key);
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuarioService = UsuariosService();
  List<Usuario> usuarios = [];
  // final usuarios = [
  //   Usuario(uid: '1', nombre: 'Moncho', email: 'mon@aaa.com', online: true),
  //   Usuario(uid: '2', nombre: 'Luigi', email: 'luis@banco.com', online: true),
  //   Usuario(uid: '3', nombre: 'Tututu', email: 'poli@redondela.com', online: false),
  //   Usuario(uid: '4', nombre: 'Fernando', email: 'varelita@aaa.com', online: true),
  // ];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    _cargarUsuarios(); // se cargan aqui tambien para que se carguen al entrar en la pagina
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    final usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(usuario.nombre, style: const TextStyle(color: Colors.black54)),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.black54),
          onPressed: () {
            socketService.desconectarSocket();
            AuthService.deleteToken();
            Navigator.pushReplacementNamed(context, 'login');
          },
        ),
        actions: [
          // para poner a la derecha de la appbar el icono del estado
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[400]),
          waterDropColor: Colors.blue.shade400,
        ),
        onRefresh: _cargarUsuarios,
        child: _listViewUsuarios(),
      ),
    );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, i) => _usuarioListTile(usuarios[i]),
      separatorBuilder: (_, i) => const Divider(),
      itemCount: usuarios.length,
    );
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        child: Text(usuario.nombre.substring(0, 2)),
        backgroundColor: Colors.blue[100],
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: (usuario.online) ? Colors.blue[300] : Colors.red,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.usuarioPara = usuario;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  _cargarUsuarios() async {
    usuarios = await usuarioService.getUsuarios();
    setState(() {});

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}

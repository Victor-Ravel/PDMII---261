import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

void main() async {
  print('🌐 === SISTEMA IoT COMPLETO ===');
  print('1️⃣ Iniciando SERVIDOR...\n');

  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
  print('✅ Servidor ativo: ${server.address.address}:8080');

  server.listen((Socket client) {
    print(
      '\n🔗 IoT conectado: ${client.remoteAddress.address}:${client.remotePort}',
    );
    _handleClient(client);
  });

  await Future.delayed(Duration(seconds: 2));
  print('\n2️⃣ Iniciando DISPOSITIVO IoT...\n');
  _iniciarDispositivoIoT();

  print('\n🎉 SISTEMA RODANDO! Pressione Ctrl+C para parar.\n');
  print('─' * 60);
}

void _handleClient(Socket client) {
  final stream = client
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((linha) => linha.trim().isNotEmpty)
      .listen(
        (linha) => _processarTemperatura(client, linha),
        onDone: () {
          print('🔌 IoT desconectado');
          client.destroy();
        },
      );

  client.done.then((_) => stream.cancel());
}

void _processarTemperatura(Socket client, String linha) {
  try {
    final dados = jsonDecode(linha);
    final temp = dados['temperatura']?.toDouble() ?? 0.0;
    final timestamp = dados['timestamp'];

    print('''
🌡️  SENSOR: ${temp.toStringAsFixed(1)}°C
   ⏰  ${timestamp}
   📡 ${client.remoteAddress.address}
${'─' * 40}''');
  } catch (e) {
    print('❌ Erro JSON: $linha');
  }
}

Future<void> _iniciarDispositivoIoT() async {
  Socket? socket;
  Timer? timer;

  try {
  
    socket = await Socket.connect('127.0.0.1', 8080);
    print('✅ IoT conectado ao servidor!');

  
    timer = Timer.periodic(Duration(seconds: 10), (t) {
      _enviarTemperatura(socket!);
    });

 
    socket!.listen(
      (data) => print('📨 Resposta: ${utf8.decode(data)}'),
      onDone: () {
        print('🔌 Servidor desconectado');
        timer?.cancel();
      },
    );
  } catch (e) {
    print('❌ Erro IoT: $e');
  }
}

void _enviarTemperatura(Socket socket) {
  try {
    final temperatura = 15 + Random().nextDouble() * 20;
    final dados = {
      'temperatura': temperatura,
      'timestamp': DateTime.now().toIso8601String(),
      'dispositivo': 'IoT_SENSOR_001',
    };

    final mensagem = jsonEncode(dados) + '\n';
    socket.write(mensagem);
    print('📤 IoT → Servidor: ${temperatura.toStringAsFixed(1)}°C');
  } catch (e) {
    print('❌ Erro envio: $e');
  }
}

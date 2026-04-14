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
  client
      // 🔥 CORREÇÃO PRINCIPAL (resolve erro de tipo)
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((linha) => linha.trim().isNotEmpty)
      .listen(
        (linha) => _processarTemperatura(client, linha),
        onError: (e) {
          print('❌ Erro no stream: $e');
        },
        onDone: () {
          print('🔌 IoT desconectado');
          client.destroy();
        },
        cancelOnError: true,
      );
}

void _processarTemperatura(Socket client, String linha) {
  try {
    final dados = jsonDecode(linha);

    final temp = (dados['temperatura'] as num?)?.toDouble() ?? 0.0;
    final timestamp = dados['timestamp'] ?? 'sem timestamp';

    print('''
🌡️  SENSOR: ${temp.toStringAsFixed(1)}°C
   ⏰  $timestamp
   📡 ${client.remoteAddress.address}
${'─' * 40}''');
  } catch (e) {
    print('❌ Erro JSON recebido: $linha');
  }
}

Future<void> _iniciarDispositivoIoT() async {
  Socket? socket;
  Timer? timer;

  try {
    socket = await Socket.connect('127.0.0.1', 8080);
    print('✅ IoT conectado ao servidor!');

    // envia imediatamente
    _enviarTemperatura(socket);

    timer = Timer.periodic(Duration(seconds: 10), (_) {
      _enviarTemperatura(socket!);
    });

    socket.listen(
      (data) {
        try {
          print('📨 Resposta: ${utf8.decode(data)}');
        } catch (_) {
          print('📨 Resposta (bytes): $data');
        }
      },
      onDone: () {
        print('🔌 Servidor desconectado');
        timer?.cancel();
      },
      onError: (e) {
        print('❌ Erro no cliente: $e');
        timer?.cancel();
      },
      cancelOnError: true,
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

    // ✅ envio correto
    socket.add(utf8.encode(mensagem));

    print('📤 IoT → Servidor: ${temperatura.toStringAsFixed(1)}°C');
  } catch (e) {
    print('❌ Erro envio: $e');
  }
}

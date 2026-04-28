//exemplo

abstract class Acao {
  void executar();
}

class Robo implements Acao {
  @override
  void executar() {
    print("Robô está se movendo.");
  }
}

class ConsultaSQL implements Acao {
  @override
  void executar() {
    print("Executando consulta no banco de dados.");
  }
}

class Musica implements Acao {
  @override
  void executar() {
    print("Tocando música.");
  }
}

void rodarJogo(Acao acao) {
  acao.executar();
}

void main() {
  rodarJogo(Robo());
  rodarJogo(ConsultaSQL());
  rodarJogo(Musica());
}

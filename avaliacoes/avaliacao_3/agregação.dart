// 14-agregacao.dart  
// Agregação e Composição
import 'dart:convert';

class dependente {
  late String _nome;

  dependente(String nome) {
    this._nome = nome;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': _nome,
    };
  }
}

class funcionario {
  late String _nome;
  late List<dependente> _dependentes;

  funcionario(String nome, List<dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': _nome,
      'dependentes': _dependentes.map((d) => d.toJson()).toList(),
    };
  }
}

class equipeProjeto {
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  equipeProjeto(String nomeprojeto, List<funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeProjeto': _nomeProjeto,
      'funcionarios': _funcionarios.map((f) => f.toJson()).toList(),
    };
  }
}

void main() {
  var dep1 = dependente("Alan");
  var dep2 = dependente("Celso");
  var dep3 = dependente("João");

  var func1 = funcionario("Laylson", [dep1, dep2]);
  var func2 = funcionario("Eduarda", [dep3]);
  var funcionarios = [func1, func2];
  var equipe = equipeProjeto("Sistema de Vendas", funcionarios);

  print(jsonEncode(equipe.toJson()));
}

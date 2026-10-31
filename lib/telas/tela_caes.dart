import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaCaes extends StatefulWidget {
  const TelaCaes({super.key});

  @override
  State<TelaCaes> createState() => _TelaCaesState();
}

class _TelaCaesState extends State<TelaCaes> {
  final List<String> racas = ['hound', 'pug', 'husky', 'labrador'];
  String racaSelecionada = 'hound';
  int contador = 0;

  String? imagem;
  String? erro;
  bool carregando = false;

  Future<void> buscarCao() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final resposta = await http.get(
        Uri.parse('https://dog.ceo/api/breed/$racaSelecionada/images/random'),
      );
      if (resposta.statusCode != 200) throw Exception('Falha na consulta');
      final dados = jsonDecode(resposta.body);
      if (!mounted) return;
      setState(() {
        imagem = dados['message'];
        contador++;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível carregar a foto.';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.amber.shade50,
    appBar: AppBar(
      title: const Text('Cãezinhos Fofos'),
      backgroundColor: Colors.amber.shade200,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha uma raça e veja um amigo de 4 patas!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fotos sorteadas: $contador',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: racas.map((raca) {
                return ChoiceChip(
                  label: Text(raca.toUpperCase()),
                  selected: racaSelecionada == raca,
                  onSelected: (selecionado) {
                    if (selecionado) {
                      setState(() {
                        racaSelecionada = raca;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (carregando) const CircularProgressIndicator(),
            if (erro != null) Text(erro!),
            if (imagem != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imagem!,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Text('Imagem indisponível'),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: carregando ? null : buscarCao,
              child: const Text('Ver outro cãozinho!'),
            ),
          ],
        ),
      ),
    ),
  );
}

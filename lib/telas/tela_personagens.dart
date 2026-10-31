import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/personagem.dart';
import 'tela_detalhe_personagem.dart';

class TelaPersonagens extends StatefulWidget {
  const TelaPersonagens({super.key});

  @override
  State<TelaPersonagens> createState() => _TelaPersonagensState();
}

class _TelaPersonagensState extends State<TelaPersonagens> {
  late Future<List<Personagem>> _futuro;
  String filtroStatus = ''; // '' = todos, 'alive' = vivos, 'dead' = mortos
  int pagina = 1;
  int totalPaginas = 1;
  int? idFavorito;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
    _futuro = buscarPersonagens(); // pede os dados UMA vez, ao abrir a tela
  }

  Future<void> _carregarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      idFavorito = prefs.getInt('personagem_favorito');
    });
  }

  Future<List<Personagem>> buscarPersonagens() async {
    var url = 'https://rickandmortyapi.com/api/character?page=$pagina';
    if (filtroStatus.isNotEmpty) {
      url += '&status=$filtroStatus';
    }
    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode != 200) {
      throw Exception('Falha na consulta: ${resposta.statusCode}');
    }
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    final info = dados['info'] as Map<String, dynamic>;
    final paginasDaApi = info['pages'] as int;
    if (mounted && totalPaginas != paginasDaApi) {
      setState(() {
        totalPaginas = paginasDaApi;
      });
    }
    final lista = dados['results'] as List<dynamic>;
    return lista
        .map((item) => Personagem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  void _recarregar() {
    setState(() {
      _futuro = buscarPersonagens();
    });
  }

  void _mudarFiltro(String novoStatus) {
    setState(() {
      filtroStatus = novoStatus;
      pagina = 1;
      _futuro = buscarPersonagens();
    });
  }

  void _mudarPagina(int novaPagina) {
    setState(() {
      pagina = novaPagina;
      _futuro = buscarPersonagens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: filtroStatus == '',
                  onSelected: (_) => _mudarFiltro(''),
                ),
                ChoiceChip(
                  label: const Text('Vivos'),
                  selected: filtroStatus == 'alive',
                  onSelected: (_) => _mudarFiltro('alive'),
                ),
                ChoiceChip(
                  label: const Text('Mortos'),
                  selected: filtroStatus == 'dead',
                  onSelected: (_) => _mudarFiltro('dead'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Personagem>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Não foi possível carregar os personagens.',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _recarregar,
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  );
                }
                final personagens = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: personagens.length,
                  itemBuilder: (context, i) {
                    final p = personagens[i];
                    final ehFavorito = p.id == idFavorito;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(p.imagem),
                        ),
                        title: Text(p.nome),
                        subtitle: Text('${p.especie} · ${p.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ehFavorito)
                              const Icon(Icons.star, color: Colors.amber),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TelaDetalhePersonagem(personagem: p),
                            ),
                          );
                          await _carregarFavorito();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: pagina > 1 ? () => _mudarPagina(pagina - 1) : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
                Text('Página $pagina de $totalPaginas'),
                ElevatedButton.icon(
                  onPressed: pagina < totalPaginas
                      ? () => _mudarPagina(pagina + 1)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Próxima'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/personagem.dart';

class TelaDetalhePersonagem extends StatefulWidget {
  final Personagem personagem;
  const TelaDetalhePersonagem({super.key, required this.personagem});

  @override
  State<TelaDetalhePersonagem> createState() => _TelaDetalhePersonagemState();
}

class _TelaDetalhePersonagemState extends State<TelaDetalhePersonagem> {
  bool ehFavorito = false;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    final idSalvo = prefs.getInt('personagem_favorito');
    if (!mounted) return;
    setState(() {
      ehFavorito = (idSalvo == widget.personagem.id);
    });
  }

  Future<void> _alternarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    if (ehFavorito) {
      await prefs.remove('personagem_favorito');
    } else {
      await prefs.setInt('personagem_favorito', widget.personagem.id);
    }
    if (!mounted) return;
    setState(() {
      ehFavorito = !ehFavorito;
    });
  }

  Color _corStatus() {
    switch (widget.personagem.status) {
      case 'Alive':
        return Colors.green;
      case 'Dead':
        return Colors.red;
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final personagem = widget.personagem;
    return Scaffold(
      appBar: AppBar(
        title: Text(personagem.nome),
        actions: [
          IconButton(
            onPressed: _alternarFavorito,
            icon: Icon(
              ehFavorito ? Icons.star : Icons.star_border,
              color: ehFavorito ? Colors.amber : null,
            ),
            tooltip: 'Marcar como favorito',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                personagem.imagem,
                width: 240,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image, size: 120),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              personagem.nome,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(Icons.circle, size: 12, color: _corStatus()),
              label: Text(personagem.status),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _alternarFavorito,
              icon: Icon(
                ehFavorito ? Icons.star : Icons.star_border,
                color: ehFavorito ? Colors.amber : null,
              ),
              label: Text(
                ehFavorito ? 'Personagem favorito' : 'Favoritar personagem',
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Espécie'),
              subtitle: Text(personagem.especie),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Gênero'),
              subtitle: Text(personagem.genero),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Origem'),
              subtitle: Text(personagem.origem),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Localização atual'),
              subtitle: Text(personagem.localizacao),
            ),
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('ID'),
              subtitle: Text('${personagem.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

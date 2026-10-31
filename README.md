# apis_imagens

Projeto **APIs Divertidas em Flutter** (Móveis I · Aula prática · Profª. Madianita Bogo Marioti).

## Funcionalidades

1. **Galeria de cães (`dog.ceo`)**: Sorteia imagens de cães com tratamento de estado de carregamento (`CircularProgressIndicator`), tratamento de erros e `ClipRRect`.
2. **Pokédex (`pokeapi.co`)**: Busca Pokémon por nome ou número usando `TextEditingController`, exibindo sprite, altura e peso.
3. **Personagens (`rickandmortyapi.com`)**: Lista personagens consumindo JSON paginado na classe modelo `Personagem` (`fromMap`) com `FutureBuilder`, botão de tentar novamente e navegação para a tela de detalhes (`TelaDetalhePersonagem`).

## Comandos para rodar (com Flutter SDK instalado)

Caso você abra em um ambiente com o Flutter SDK instalado e quiser recriar os arquivos nativos de plataforma (android/ios/web/windows):

```bash
cd apis_imagens
flutter create .
flutter pub get
flutter run
```


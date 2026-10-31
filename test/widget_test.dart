import 'package:flutter_test/flutter_test.dart';
import 'package:apis_imagens/main.dart';

void main() {
  testWidgets('Verifica botoes da tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Galeria de cães'), findsOneWidget);
    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Personagens'), findsOneWidget);
  });
}

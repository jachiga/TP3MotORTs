import 'package:flutter_test/flutter_test.dart';
import 'package:tp3motorts/main.dart';

void main() {
  testWidgets('Prueba inicial de inicio de la aplicación', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
  });
}
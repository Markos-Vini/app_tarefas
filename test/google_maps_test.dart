import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  testWidgets('Google Maps Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 11.0,
          ),
        ),
      ),
    ));

    // Verifica se o widget GoogleMap foi renderizado
    expect(find.byType(GoogleMap), findsOneWidget);

    // Verifica se a câmera inicial está configurada corretamente
    expect(find.byType(GoogleMap), findsOneWidget);
    final GoogleMap googleMapWidget = tester.widget(find.byType(GoogleMap));
    expect(googleMapWidget.initialCameraPosition, CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 11.0,
    ));
  });
}

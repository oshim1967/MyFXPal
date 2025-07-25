import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatelessWidget {
  final String data;

  const QrCodeScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ваш QR-код'),
      ),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}

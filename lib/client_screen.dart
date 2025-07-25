import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_currency_exchanger/qr_scanner_screen.dart';

class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  String? _exchangerId;
  DatabaseReference? _ratesRef;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сегодняшний курс'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QrScannerScreen()),
              );
              if (result != null) {
                setState(() {
                  _exchangerId = result;
                  _ratesRef =
                      FirebaseDatabase.instance.ref('rates/$_exchangerId');
                });
              }
            },
          ),
        ],
      ),
      body: _ratesRef == null
          ? Center(child: Text('Отсканируйте QR-код валютчика'))
          : StreamBuilder(
              stream: _ratesRef!.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final rates = data.entries.map((e) {
                  return {
                    'currency': e.key,
                    'buy': e.value['buy'],
                    'sell': e.value['sell']
                  };
                }).toList();
                return ListView.builder(
                  itemCount: rates.length,
                  itemBuilder: (context, index) {
                    final rate = rates[index];
                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(rate['currency']!),
                        ),
                        title: Text('Покупка: ${rate['buy']}'),
                        subtitle: Text('Продажа: ${rate['sell']}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

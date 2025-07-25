import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_currency_exchanger/services/api_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:my_currency_exchanger/qr_code_screen.dart';

class ExchangerScreen extends StatefulWidget {
  @override
  _ExchangerScreenState createState() => _ExchangerScreenState();
}

class _ExchangerScreenState extends State<ExchangerScreen> {
  final _buyController = TextEditingController();
  final _sellController = TextEditingController();
  final _amountController = TextEditingController();
  final _percentController = TextEditingController();
  final _notificationController = TextEditingController();
  final _apiService = ApiService();
  List<dynamic> _officialRates = [];
  bool _isLoading = false;
  String? _fromCurrency;
  String? _toCurrency;
  double _result = 0.0;

  void _convert() {
    if (_fromCurrency == null ||
        _toCurrency == null ||
        _amountController.text.isEmpty) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final percent = _percentController.text.isEmpty
        ? 0.0
        : double.parse(_percentController.text);

    final fromRate = _officialRates
        .firstWhere((rate) => rate['cc'] == _fromCurrency)['rate'];
    final toRate = _officialRates
        .firstWhere((rate) => rate['cc'] == _toCurrency)['rate'];

    setState(() {
      _result = (amount * fromRate / toRate) * (1 + percent / 100);
    });
  }

  Future<void> _sendNotification() async {
    if (_notificationController.text.isEmpty) {
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY', // TODO: Замените на ваш ключ сервера
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': _notificationController.text,
              'title': 'Горячий курс!',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': '/topics/all',
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveRates() async {
    if (_buyController.text.isEmpty || _sellController.text.isEmpty) {
      return;
    }

    final database = FirebaseDatabase.instance.ref();
    await database.child('rates/exchanger123').set({
      'USD': {
        'buy': _buyController.text,
        'sell': _sellController.text,
      }
    });
  }

  Future<void> _loadOfficialRates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rates = await _apiService.getExchangeRates();
      setState(() {
        _officialRates = rates;
      });
    } catch (e) {
      // TODO: Handle error
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Панель валютчика'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _buyController,
              decoration: InputDecoration(labelText: 'Курс покупки'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _sellController,
              decoration: InputDecoration(labelText: 'Курс продажи'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRates,
              child: Text('Сохранить'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadOfficialRates,
              child: Text('Загрузить официальные курсы'),
            ),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _officialRates.length,
                  itemBuilder: (context, index) {
                    final rate = _officialRates[index];
                    return ListTile(
                      title: Text(rate['txt']),
                      subtitle: Text(rate['rate'].toString()),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text('Конвертация', style: TextStyle(fontSize: 20)),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    items: _officialRates.map((rate) {
                      return DropdownMenuItem<String>(
                        value: rate['cc'],
                        child: Text(rate['cc']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value;
                      });
                    },
                    hint: Text('Из'),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    items: _officialRates.map((rate) {
                      return DropdownMenuItem<String>(
                        value: rate['cc'],
                        child: Text(rate['cc']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value;
                      });
                    },
                    hint: Text('В'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _percentController,
              decoration: InputDecoration(labelText: 'Процент'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              child: Text('Конвертировать'),
            ),
            SizedBox(height: 20),
            Text('Результат: $_result'),
            SizedBox(height: 20),
            TextField(
              controller: _notificationController,
              decoration: InputDecoration(labelText: 'Текст уведомления'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text('Отправить уведомление'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrCodeScreen(data: 'exchanger123'),
                  ),
                );
              },
              child: Text('Поделиться QR-кодом'),
            ),
          ],
        ),
      ),
    );
  }
}

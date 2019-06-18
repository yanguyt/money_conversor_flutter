import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=806f1d5f";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _realController = TextEditingController();
  final _dolarController = TextEditingController();
  final _euroController = TextEditingController();

  double dolar;
  double euro;

  void _changeReal(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double real = double.parse(text);
    _dolarController.text = (real / dolar).toStringAsFixed(2);
    _euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _changeDolar(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double dolar = double.parse(text);
    _realController.text = (dolar * this.dolar).toStringAsFixed(2);
    _euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _changeEuro(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double euro = double.parse(text);
    _realController.text = (euro * this.euro).toStringAsFixed(2);
    _dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    _realController.text = "";
    _dolarController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            "conversor de moedas",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber, fontSize: 24),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error ao carregar dados",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"] +
                      0.10;
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"] +
                      0.10;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            color: Colors.amber, size: 150),
                        myTextField(
                            "Reais", "R\$", _realController, _changeReal),
                        Divider(),
                        myTextField(
                            "Dolares", "U\$", _dolarController, _changeDolar),
                        Divider(),
                        myTextField(
                            "Euros", "EU\$", _euroController, _changeEuro)
                      ],
                    ),
                  );
                }
            }
          },
        ));
  }
}

Widget myTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    onChanged: f,
    decoration: InputDecoration(
        labelText: label,
        prefix: Text(prefix, style: TextStyle(color: Colors.amber)),
        border: OutlineInputBorder(),
        labelStyle: TextStyle(fontSize: 20, color: Colors.amber)),
    style: TextStyle(color: Colors.white, fontSize: 15),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

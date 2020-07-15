import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    "https://api.hgbrasil.com/finance?format=json&key=e8c388e6"; // API

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conversor de Moedas',
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          )),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _realControler = TextEditingController();
  final _dolarControler = TextEditingController();
  final _euroControler = TextEditingController();

  double dolar;
  double euro;

  void _mudarReal(String text) {
    double real = double.parse(text);
    _dolarControler.text = (real*dolar).toStringAsFixed(2);
    _euroControler.text = (real*euro).toStringAsFixed(2);
  }
  void _mudarDolar(String text) {
    double dolar = double.parse(text);
    _realControler.text = (dolar*this.dolar).toStringAsFixed(2);
    _euroControler.text = (dolar*this.dolar / euro).toStringAsFixed(2);
  }
  void _mudarEuro(String text) {
    double euro = double.parse(text);
    _realControler.text = (euro*this.euro).toStringAsFixed(2);
    _dolarControler.text = (euro*this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    _realControler.text = "";
    _dolarControler.text = "";
    _euroControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("\$ Conversor de Moedas",
            style: TextStyle(color: Colors.yellow)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh, color: Colors.yellow), onPressed: _clearAll)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.yellow,
                    ),
                    SizedBox(height: 20),
                    Text("Carregando os dados ...",
                        style: TextStyle(color: Colors.yellow, fontSize: 25),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            default:
              if (snapshot.hasError) {
                Text("Ocorreu um erro ao carregar os dados ...",
                    style: TextStyle(color: Colors.yellow, fontSize: 25),
                    textAlign: TextAlign.center);
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150, color: Colors.yellow),
                      SizedBox(height: 40),
                      buildTextField("Reais", "R\$ ", _realControler, _mudarReal),
                      Divider(),
                      buildTextField("Dólares", "\$ ", _dolarControler, _mudarDolar),
                      Divider(),
                      buildTextField("Euros", "€ ", _euroControler, _mudarEuro),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      prefixText: prefix,
      labelText: label,
      labelStyle: TextStyle(color: Colors.yellow),
    ),
    style: TextStyle(color: Colors.amber),
    onChanged: function,
  );
}

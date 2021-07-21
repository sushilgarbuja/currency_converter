import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  static final appId = '81165ced607f49cfa389d7af98a7c63f';
  static final baseUrl = 'https://openexchangerates.org/api/latest.json';
  final endpoint = '$baseUrl?app_id=$appId';
  Map? rates;
  String? d1;
  String? d2;

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CC'),
      ),
      body: rates == null ? showLoading() : buildBody(),
    );
  }

  Widget showLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<dynamic>(
            hint: Text('Currency 1'),
            isExpanded: true,
            value: d1,
            onChanged: (val) {
              print(val);
              setState(() {
                d1 = val;
              });
            },
            items: rates!.entries.map<DropdownMenuItem>((e) {
              return DropdownMenuItem(
                child: Text(e.key),
                value: e.key,
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: c1,
            onChanged: (val) => updateCurrency2(val),
            decoration: InputDecoration(
              hintText: 'Enter Value (Currency 1)',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<dynamic>(
            hint: Text('Currency 2'),
            isExpanded: true,
            value: d2,
            onChanged: (val) {
              print(val);
              setState(() {
                d2 = val;
              });
            },
            items: rates!.entries.map<DropdownMenuItem>((e) {
              return DropdownMenuItem(
                child: Text(e.key),
                value: e.key,
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: c2,
            onChanged: (val) => updateCurrency1(val),
            decoration: InputDecoration(
              hintText: 'Enter value (Currency 2)',
            ),
          ),
        ),
      ],
    );
  }

  void updateCurrency2(String input) {
    double i = double.tryParse(input) ?? 0.0;
    if (i == 0) {
      c2.text = '';
      return;
    }
    if (d1 == null || d2 == null) {
      c2.text = '';
      final snackBar = SnackBar(
        content: Text('Please Select Value from Dropdown'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    final r1 = rates![d1];
    final r2 = rates![d2];
    final relative = r2 / r1;
    final double result = relative * i;

    c2.text = '${result.toStringAsFixed(2)}';
  }

  void updateCurrency1(String input) {
    double i = double.tryParse(input) ?? 0.0;
    if (i == 0) {
      c1.text = '';
      return;
    }
    if (d1 == null || d2 == null) {
      c1.text = '';
       final snackBar = SnackBar(
        content: Text('Please Select Value from Dropdown'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    final r1 = rates![d1];
    final r2 = rates![d2];
    final relative = r1 / r2;
    final double result = relative * i;

    c1.text = '${result.toStringAsFixed(2)}';
  }

  void fetchExchangeRates() async {
    final uri = Uri.parse(endpoint);
    final rawResponse = await http.get(uri);
    final stringResponse = rawResponse.body;
    final jsonResponse = json.decode(stringResponse);

    setState(() {
      rates = jsonResponse['rates'];
    });
  }
}

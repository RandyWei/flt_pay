import 'dart:async';

import 'package:flt_pay_ali/flt_pay_ali.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _payInfo = "";

  String _payResult;

  Future<void> _pay() async {
    try {
      await FltPayAli.aliPay(_payInfo, (String result) {
        print('aliPay result : $result');
        setState(() {
          _payResult = result;
        });
      });
    } on PlatformException {
      setState(() {
        _payResult = 'Failed to get platform version.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('aliPay plugin example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Pay info:\n$_payInfo\n'),
            ),
            RaisedButton(
              onPressed: _pay,
              child: Text('pay'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('pay result : $_payResult'),
            )
          ],
        ),
      ),
    );
  }
}

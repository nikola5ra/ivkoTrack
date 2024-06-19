import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:http/http.dart' as http;
import 'script_response.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IV QR scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showQRScanner = true;
  bool _showProgressBar = false;
  bool _showData = false;

  String? _assetId;
  ScriptResponse? _scripResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002855),
        title: const Text(
          'IV QR scanner',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          if (_showQRScanner)
            QRBarScannerCamera(
              onError: (context, error) => Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
              qrCodeCallback: (code) {
                _qrCallback(code);
              },
            ),
          if (_showProgressBar)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_showData)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                    child: Text(
                      _scripResponse?.message ?? '',
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //
                  // Employee and asses data
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        // Asset id
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RichText(
                            text: TextSpan(
                              text: "Asset ID:\n",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _assetId ?? '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //
                        // Employee name
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RichText(
                            text: TextSpan(
                              text: "Name:\n",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _scripResponse?.name ?? '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //
                        // Asset model
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RichText(
                            text: TextSpan(
                              text: "Model:\n",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _scripResponse?.model ?? '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //
                        // Asset serial number
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RichText(
                            text: TextSpan(
                              text: "Serial number:\n",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _scripResponse?.serialNumber ?? '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                  // Scan again
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: TextButton(
                        child: const Text(
                          'Scan again',
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          setState(
                            () {
                              _showQRScanner = true;
                              _showData = false;
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  _qrCallback(String? code) async {
    setState(() {
      _showData = false;
      _showProgressBar = true;
      _showQRScanner = false;
    });
    const String scriptURL =
        'https://script.google.com/macros/s/AKfycbyo7Dx15Ye830kdhuGXQBBbmJR73_7XxTSncX4UzU3usPJG9RF-n9zce4xcHPoApONI/exec';

    String id = _assetId = code ?? '';

    String queryString = "?assetNumber=$id";

    var finalURI = Uri.parse(scriptURL + queryString);
    var response = await http.get(finalURI);

    if (response.statusCode == 200) {
      _scripResponse = ScriptResponse.fromJson(jsonDecode(response.body));

      setState(() {
        _showData = true;
        _showProgressBar = false;
      });
    }
  }
}

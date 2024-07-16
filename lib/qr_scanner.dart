import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:iv_docs/initial_page.dart';
import 'package:iv_docs/script_response.dart';
import 'package:http/http.dart' as http;

class QrScanner extends StatefulWidget {
  const QrScanner({super.key, required this.readOnly});

  final bool readOnly;

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool _showQRScanner = true;
  bool _showProgressBar = false;
  bool _showData = false;

  String? _assetId;
  ScriptResponse? _scripResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 80
                            : 20,
                        24,
                        60,
                      ),
                      child: Center(
                        child: Text(
                          _scripResponse?.message ?? '',
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    //
                    // Employee and asses data
                    if (_scripResponse?.status != 'ERROR')
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
                                      style:
                                          const TextStyle(color: Colors.green),
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
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //
                            // Team
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RichText(
                                text: TextSpan(
                                  text: "Team:\n",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 22),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: _scripResponse?.team ?? '',
                                      style:
                                          const TextStyle(color: Colors.green),
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
                                      style:
                                          const TextStyle(color: Colors.green),
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
                                      style:
                                          const TextStyle(color: Colors.green),
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
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const InitialPage()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                            foregroundColor: Colors.white, // Text color
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: const Text(
                            'Scan new',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
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
        'https://script.google.com/macros/s/AKfycbx-oQGoYz--ngSpxGYAx0TKkBv6vVyuyc9XZxGb_XAv-KV2ltyfk1x8TArR5ojtceOz/exec';

    String id = _assetId = code ?? '';

    debugPrint('********** ${widget.readOnly}');

    String queryString = "?assetNumber=$id&readOnly=${widget.readOnly}";

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

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
  ScriptResponse? _scriptResponse;

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
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 80
                          : 20,
                      24,
                      60,
                    ),
                    //
                    // Response message
                    child: Center(
                      child: Text(
                        _scriptResponse?.message ?? '',
                        style: const TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  //
                  // User not found message
                  if (_scriptResponse?.name == null &&
                      _scriptResponse?.team == null &&
                      _scriptResponse?.serialNumber == null &&
                      _scriptResponse?.model == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'There is no user with Asset id: $_assetId',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  //
                  // Employee and asses data
                  if (_scriptResponse?.status != 'ERROR' &&
                      (_scriptResponse?.name != null &&
                              _scriptResponse?.team != null ||
                          _scriptResponse?.serialNumber != null ||
                          _scriptResponse?.model != null))
                    AssetDataWidget(
                      assetId: _assetId,
                      scriptResponse: _scriptResponse,
                    ),
                  //
                  // Scan new
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 40
                                : 20,
                          ),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const InitialPage()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Background color
                                foregroundColor: Colors.white, // Text color
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Scan new',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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

    String queryString = "?assetNumber=$id&readOnly=${widget.readOnly}";

    var finalURI = Uri.parse(scriptURL + queryString);
    var response = await http.get(finalURI);

    if (response.statusCode == 200) {
      _scriptResponse = ScriptResponse.fromJson(jsonDecode(response.body));

      setState(() {
        _showData = true;
        _showProgressBar = false;
      });
    }
  }
}

class AssetDataWidget extends StatelessWidget {
  const AssetDataWidget({
    super.key,
    required this.assetId,
    required this.scriptResponse,
  });

  final String? assetId;
  final ScriptResponse? scriptResponse;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      //
      // Asset id
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RichText(
          text: TextSpan(
            text: "Asset ID:\n",
            style: const TextStyle(color: Colors.black, fontSize: 22),
            children: <TextSpan>[
              TextSpan(
                text: assetId ?? '',
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
            style: const TextStyle(color: Colors.black, fontSize: 22),
            children: <TextSpan>[
              TextSpan(
                text: scriptResponse?.name ?? '',
                style: const TextStyle(color: Colors.green),
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
            style: const TextStyle(color: Colors.black, fontSize: 22),
            children: <TextSpan>[
              TextSpan(
                text: scriptResponse?.team ?? '',
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
            style: const TextStyle(color: Colors.black, fontSize: 22),
            children: <TextSpan>[
              TextSpan(
                text: scriptResponse?.model ?? '',
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
            style: const TextStyle(color: Colors.black, fontSize: 22),
            children: <TextSpan>[
              TextSpan(
                text: scriptResponse?.serialNumber ?? '',
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      )
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: MediaQuery.of(context).orientation == Orientation.portrait
          ? Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            )
          : SizedBox(
              height: 140,
              child: Wrap(
                runSpacing: 40,
                direction: Axis.vertical,
                children: widgets,
              ),
            ),
    );
  }
}

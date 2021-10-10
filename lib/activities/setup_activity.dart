import 'dart:async';
import 'package:udp/udp.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app_localizations.dart';

/// This activity is presented as a Scaffold as well,
/// but given to the Navigator as a full-screen dialog,
/// to make it easier to dismiss and more lightweight.
// ignore: must_be_immutable
class SetupActivity extends StatefulWidget{

  /// The position of the item waiting to be set up.
  int position;

  /// Constructor giving the item's position from the AppCenterActivity.
  SetupActivity({this.position});

  @override
  State<StatefulWidget> createState() {
    return _SetupActivityState();
  }

}

class _SetupActivityState extends State<SetupActivity> {

  /// The softAP default IP Address,
  /// UDP IP Address,
  /// and port in the address.
  String _INITIAL_URL = "http://192.168.4.1";
  final String _UDP_IP = "192.168.43.200";
  final int _UDP_PORT = 4210;

  /// The SSID and corresponding password placeholders.
  String _ssid = "";
  String _password = "";

  /// The device's local IP.
  var _localIP;

  /// The controller responsible for handling the webView.
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("SETUP")),
        elevation: 0,
      ),

      body: WebView(
        // Load the URL.
        initialUrl: _INITIAL_URL,

        // Set Javascript on.
        javascriptMode: JavascriptMode.unrestricted,

        // Use the controller once the site is fully loaded.
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },

        /// Detect the submit button touch on the webview,
        /// open the UDP port,
        /// listen to the local IP sent by the module.
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
            name: 'MessageInvoker',
            onMessageReceived: (s) async {
              /// Inform the user the info has been submitted.
              Fluttertoast.showToast(msg: s.message);

              /// Initialize a UDP receiver
              /// and point it at the programmed port.
              var receiver = await UDP.bind(
                Endpoint.loopback(port: Port(_UDP_PORT))
              );

              /// The localIP string contains the address
              /// through which the app communicates with the module.
              await receiver.listen((datagram) {
                _localIP = String.fromCharCodes(datagram.data);
              },
                timeout: Duration(seconds: 30),
              );

              // Close the receiver and update the database.
              receiver.close();

              /**
               * TODO: Add LOCAL_IP to the device document, using the position argument.
               */

            })
        ].toSet(),

      )
    );
  }

}
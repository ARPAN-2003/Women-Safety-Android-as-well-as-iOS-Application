import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class SafeWebView extends StatelessWidget {
  final String? url;
  const SafeWebView({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(
        controller: WebViewController()..loadRequest(Uri.parse(url!)),
      ),
    );
  }
}

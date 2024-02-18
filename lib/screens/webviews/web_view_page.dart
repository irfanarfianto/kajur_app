import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url),
      );

    controller
      ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) => setState(
                () => loadingPercentage = 100,
              )))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Snackbar', onMessageReceived: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.message),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: () async {
              if (await controller.canGoBack()) {
                await controller.goBack();
              } else {
                // Tidak ada yang kembali, tombol dinonaktifkan
                Navigator.pop(context);
                return;
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Col.primaryColor,
          foregroundColor: Col.whiteColor,
          actions: [
            Row(children: [
              IconButton(
                tooltip: 'Kembali',
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  } else {
                    // Tidak ada yang kembali, tombol dinonaktifkan
                    return;
                  }
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              IconButton(
                tooltip: 'Lanjut',
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (await controller.canGoForward()) {
                    await controller.goForward();
                  } else {
                    // Tidak ada yang maju, tombol dinonaktifkan
                    return;
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ])
          ],
          title: SizedBox(
            height: 36.0,
            child: TextField(
              controller: TextEditingController()..text = widget.url,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Col.whiteColor.withOpacity(0.1),
                  contentPadding: const EdgeInsets.all(8.0),
                  hintText: 'Cari',
                  hintStyle: TextStyle(
                    color: Col.whiteColor.withOpacity(.50),
                    fontSize: 14.0,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Refresh',
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      controller.reload();
                    },
                    icon: const Icon(Icons.replay_outlined),
                  ),
                  suffixIconColor: Col.whiteColor.withOpacity(.50),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100),
                      ),
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Col.whiteColor.withOpacity(0.5),
                      ))),
              style: const TextStyle(
                color: Col.whiteColor,
              ),
            ),
          ),
        ),
        body: Stack(children: [
          WebViewWidget(
            layoutDirection: Directionality.of(context),
            controller: controller,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            )
        ]),
      ),
    );
  }
}

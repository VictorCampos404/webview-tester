import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

// import 'package:window_manager/window_manager.dart';]

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final _controller = WebviewController();

  String url = "";

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    await _controller.initialize();

    _controller.addScriptToExecuteOnDocumentCreated(
      """
      function applyStyle() {
          if (!window.location.href.includes('login')) return;

          document.body.style.transform = 'scale(2)';

          var containerElements = document.getElementsByClassName('container');
          if (containerElements.length > 0) {
              var container = containerElements[0];
              var asideElement = container.querySelector('aside');
              if (asideElement) {
              asideElement.remove();
              }

              var mainElementPassword = document.querySelector('main');
              if (mainElementPassword) {
              mainElementPassword.style.marginTop = '350px';
              }
          }

          document.addEventListener('focusin', function(e) {
            if (e.target.tagName.toLowerCase() === 'input' || e.target.tagName.toLowerCase() === 'textarea') {
              window.chrome.webview.postMessage(JSON.stringify({
                type: 'focus',
                tag: e.target.tagName.toLowerCase(),
                id: e.target.id || null,
                name: e.target.name || null,
                value: e.target.value || null
              }));
            }
          });

          document.addEventListener('focusout', function(e) {
            if (e.target.tagName.toLowerCase() === 'input' || e.target.tagName.toLowerCase() === 'textarea') {
              window.chrome.webview.postMessage(JSON.stringify({
                type: 'blur',
                tag: e.target.tagName.toLowerCase(),
                id: e.target.id || null,
                name: e.target.name || null,
                value: e.target.value || null
              }));
            }
          });
      }

      if (document.readyState === "loading") {
          document.addEventListener("DOMContentLoaded", applyStyle);
      } else {
          applyStyle();
      }

      const observer = new MutationObserver(() => {
          applyStyle();
      });

      observer.observe(document.body, {
          childList: true,
          subtree: true,
      });

      

      """,
    );

    _controller.urlOnNavigationStarting.listen((value) {
      setState(() {
        url = value;
      });
    });

    _controller.inputFocus.listen((value) {
      if (value.hasFocus) {
        print('FOCADO');
      }
      if (!value.hasFocus) {
        print('DESFOCADO');
      }
    });

    await _controller.loadUrl(
      'https://portal.idp.homol.proderj.rj.gov.br/auth/realms/rj/protocol/openid-connect/auth?response_type=code&client_id=apprjdigital&redirect_uri=comexamplesdcapp:/&scope=openid',
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                url,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: Webview(
                _controller,
                permissionRequested:
                    (url, permissionKind, isUserInitiated) async {
                  return WebviewPermissionDecision.allow;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String text = "1";
          await _controller.executeScript(
            """
            if (document.activeElement && 
              (document.activeElement.tagName.toLowerCase() === 'input' || 
                document.activeElement.tagName.toLowerCase() === 'textarea')) {
                let el = document.activeElement;
                let start = el.selectionStart || el.value.length;
                let end = el.selectionEnd || el.value.length;
                el.value = el.value.substring(0, start) + "$text" + el.value.substring(end);
                el.selectionStart = el.selectionEnd = start + "$text".length;
                el.dispatchEvent(new Event('input', { bubbles: true }));
            }
            """,
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

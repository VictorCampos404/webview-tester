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

    _controller.url.listen((value) {
      setState(() {
        url = value;
      });
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
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

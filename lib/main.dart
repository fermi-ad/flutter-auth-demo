import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import 'openid_io.dart' if (dart.library.html) 'openid_browser.dart';

import 'dart:developer' as dev;

const keycloakUri = 'https://adkube-auth.fnal.gov/realms/acsys/';
const scopes = <String>[];

Credential? credential;

late final Client client;

Future<Client> getClient() async {
  var uri = Uri.parse(keycloakUri);

  var clientId = 'auth-demo';
  var issuer = await Issuer.discover(uri);

  return Client(issuer, clientId,
      clientSecret: "vPL2PWccDhFfbsUJjRsv5qdzJpWAhx4K");
}

Future<void> main() async {
  try {
    dev.log("waiting for client");
    client = await getClient();
    dev.log("waiting for redirection");
    credential = await getRedirectResult(client, scopes: scopes);
    dev.log("running app");
    runApp(const MyApp());
  } catch (e) {
    dev.log("exception: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'openid_client demo',
      home: MyHomePage(title: 'openid_client Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserInfo? userInfo;

  @override
  void initState() {
    if (credential != null) {
      credential!.getUserInfo().then((userInfo) {
        setState(() {
          this.userInfo = userInfo;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (userInfo != null) ...[
              Text('Hello ${userInfo!.name}'),
              Text(userInfo!.email ?? ''),
              OutlinedButton(
                  child: const Text('Logout'),
                  onPressed: () async {
                    setState(() {
                      userInfo = null;
                    });
                  })
            ],
            if (userInfo == null)
              OutlinedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    var credential = await authenticate(client, scopes: scopes);
                    var userInfo = await credential.getUserInfo();

                    setState(() {
                      this.userInfo = userInfo;
                    });
                  }),
          ],
        ),
      ),
    );
  }
}

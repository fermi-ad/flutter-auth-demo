import 'dart:io';

import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openid_client/openid_client_io.dart' as io;

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  // create a function to open a browser with an url
  urlLauncher(String url) async {
    var uri = Uri.parse(url);

    if (await canLaunchUrl(uri) || Platform.isAndroid) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // create an authenticator
  final authenticator = io.Authenticator(client,
      scopes: scopes, port: 4000, urlLancher: urlLauncher);

  try {
    // starts the authentication
    return (await authenticator.authorize());
  } finally {
    // close the webview when finished
    if (Platform.isAndroid || Platform.isIOS) {
      closeInAppWebView();
    }
  }
}

Future<Credential?> getRedirectResult(Client client,
        {List<String> scopes = const []}) async =>
    null;

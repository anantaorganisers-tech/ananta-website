import 'package:web/web.dart' as web;

/// Opens an internal Flutter Web route in a separate browser tab.
void openRouteInNewTab(String route) {
  web.window.open(route, '_blank');
}

/// Opens an external URL in a separate browser tab.
void openExternalUrl(String url) {
  web.window.open(url, '_blank');
}

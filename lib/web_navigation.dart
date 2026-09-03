import 'package:web/web.dart' as web;

/// Opens an internal Flutter Web route in a separate browser tab.
void openRouteInNewTab(String route) {
  web.window.open(route, '_blank');
}

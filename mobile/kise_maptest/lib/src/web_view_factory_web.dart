// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerHtmlViewFactory(String viewTypeId, html.Element Function(int) factory) {
  ui_web.platformViewRegistry.registerViewFactory(viewTypeId, factory);
}



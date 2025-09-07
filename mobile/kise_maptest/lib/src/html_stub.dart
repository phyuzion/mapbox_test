class Event {
  final dynamic data;
  const Event([this.data]);
}

class WindowStub {
  const WindowStub();
  Stream<Event> get onMessage => const Stream<Event>.empty();
  void postMessage(dynamic message, String targetOrigin) {}
}

class IFrameElement {
  IFrameElement();
  final style = _Style();
  set width(String v) {}
  set height(String v) {}
  set src(String v) {}
  WindowStub? get contentWindow => const WindowStub();
}

class _Style {
  String pointerEvents = 'auto';
  String border = '0';
}

final window = const WindowStub();

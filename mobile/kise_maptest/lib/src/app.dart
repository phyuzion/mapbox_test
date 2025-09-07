import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kise_maptest/src/glb_list/glb_list.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Web HTML types via conditional import (stubbed on non-web)
import 'html_stub.dart' if (dart.library.html) 'dart:html' as html;
import 'web_view_factory.dart';
import 'dart:convert';
import 'permission_controller.dart';
import 'spot_list/spot_list.dart';

class KiseMapTestApp extends StatelessWidget {
  const KiseMapTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KISE-MAPTEST',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = '초기화 중...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (!mounted) return;
      if (kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
        return;
      }
      setState(() { _status = '권한 확인 중'; });
      final ok = await const PermissionController().ensureLocationWhenInUse();
      if (!ok) {
        // 거부 시에도 맵은 열되, 위치 기능만 비활성로 간주
      }
      _goNext();
    } catch (e) {
      _goNext();
    }
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _MapScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('KISE-MAPTEST', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ),
      ),
    );
  }
}

class _MapScaffold extends StatefulWidget {
  const _MapScaffold();
  @override
  State<_MapScaffold> createState() => _MapScaffoldState();
}

class _MapScaffoldState extends State<_MapScaffold> {
  WebViewController? _controller;
  bool _ready = false;
  bool _tokenSent = false;
  html.IFrameElement? _iframe; // web only
  String? _viewTypeId; // web only
  StreamSubscription<html.Event>? _messageSub; // web only

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _setupWebIFrame();
    } else {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) { _setToken(); },
          onWebResourceError: (err) {},
          onNavigationRequest: (req) { return NavigationDecision.navigate; },
        ))
        ..addJavaScriptChannel('flutter', onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message);
            if (data is Map) {
              final event = data['event'];
              if (event == 'mapReady') {
                setState(() { _ready = true; });
                if (!_tokenSent) _setToken();
              } else if (event == 'mapClick') {
                final arr = (data['lngLat'] as List?);
                if (arr != null && arr.length == 2) {
                  final lng = (arr[0] as num).toDouble();
                  final lat = (arr[1] as num).toDouble();
                  _showModelPickerAt(lng, lat);
                }
              }
            }
          } catch (_) {}
        })
        ..loadFlutterAsset('assets/map/index.html');
      _controller = controller;
    }
  }
  Future<void> _showModelPickerAt(double lng, double lat) async {
    if (!mounted) return;
    final scaleController = TextEditingController(text: '50');
    String? selectedUrl;
    final ok = await _withIframeInputPaused<bool?>(() => showDialog<bool>(
      context: context,
      builder: (ctx){
        final size = MediaQuery.of(ctx).size;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: AlertDialog(
              title: const Text('모델 선택 및 스케일'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '모델 선택'),
                    items: glbList.map((e) => DropdownMenuItem<String>(
                      value: e['url'] as String,
                      child: Text((e['name'] as String?) ?? 'model'),
                    )).toList(),
                    onChanged: (v){ selectedUrl = v; },
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: scaleController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '스케일(기본 50)')),
                ],
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('취소')),
                FilledButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('추가')),
              ],
            ),
          ),
        );
      }
    ));
    if (ok == true && selectedUrl != null && selectedUrl!.isNotEmpty) {
      final id = 'model_${DateTime.now().millisecondsSinceEpoch}';
      final scale = double.tryParse(scaleController.text) ?? 50.0;
      await _send({
        'v':1,
        'type':'addModel',
        'id': id,
        'lngLatAlt':[lng, lat, 0],
        'model': {'kind':'url','value': selectedUrl, 'scale': scale},
      });
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _messageSub = null;
    _iframe = null;
    super.dispose();
  }

  Future<void> _send(Map<String, dynamic> cmd) async {
    final json = jsonEncode(cmd);
    if (kIsWeb) {
      _iframe?.contentWindow?.postMessage(cmd, '*');
    } else {
      try {
        await _controller?.runJavaScript('window.mapview.receive($json)');
      } catch (e) {
        debugPrint('[App] runJavaScript error: $e');
      }
    }
  }

  Future<void> _setToken() async {
    if (!mounted || _tokenSent) return;
    _tokenSent = true;
    debugPrint('[App] setToken dispatch');
    await _send({'v':1,'type':'setToken','token':'pk.eyJ1IjoicGh5dXppb24iLCJhIjoiY21mOTFnYTg5MGQ4cDJrbzlrNG50c2Z2dyJ9.bQ9adwhAmshtzEuk60R8hA'});
  }

  Future<void> _addMarkerDialog() async {
    final lngController = TextEditingController(text: '126.9769');
    final latController = TextEditingController(text: '37.5759');
    final urlController = TextEditingController();
    final textController = TextEditingController(text: '광화문');
    final ok = await _withIframeInputPaused<bool?>(() => showDialog<bool>(
      context: context,
      builder: (ctx){
        final size = MediaQuery.of(ctx).size;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: AlertDialog(
              title: const Text('마커 추가'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: lngController, decoration: const InputDecoration(labelText: '경도(lng)')),
                  TextField(controller: latController, decoration: const InputDecoration(labelText: '위도(lat)')),
                  TextField(controller: urlController, decoration: const InputDecoration(labelText: '이미지 URL')),
                  TextField(controller: textController, decoration: const InputDecoration(labelText: '텍스트(선택)')),
                ],
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('취소')),
                FilledButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('추가')),
              ],
            ),
          ),
        );
      }
    ));
    if (ok != true) return;
    if (!mounted) return;
    final id = 'marker_${DateTime.now().millisecondsSinceEpoch}';
    await _send({
      'v':1,'type':'addMarker','id':id,
      'lngLat':[double.tryParse(lngController.text)??126.9769, double.tryParse(latController.text)??37.5759],
      'icon':{'kind':'url','value':urlController.text,'size':[56,56],'anchor':'bottom'},
      'label': textController.text,
      'popupHtml':'<b>${textController.text}</b>'
    });
  }

  Future<void> _addModelDialog() async {
    final lngController = TextEditingController(text: '126.9771');
    final latController = TextEditingController(text: '37.5647');
    final urlController = TextEditingController();
    final scaleController = TextEditingController(text: '50');
    final ok = await _withIframeInputPaused<bool?>(() => showDialog<bool>(
      context: context,
      builder: (ctx){
        final size = MediaQuery.of(ctx).size;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: AlertDialog(
              title: const Text('모델 추가 (GLB/GLTF URL)'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: lngController, decoration: const InputDecoration(labelText: '경도(lng)')),
                  TextField(controller: latController, decoration: const InputDecoration(labelText: '위도(lat)')),
                  TextField(controller: urlController, decoration: const InputDecoration(labelText: '모델 URL (https://...)')),
                  TextField(controller: scaleController, decoration: const InputDecoration(labelText: '스케일(기본 50)')),
                ],
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('취소')),
                FilledButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('추가')),
              ],
            ),
          ),
        );
      }
    ));
    if (ok != true) return;
    if (!mounted) return;
    final id = 'model_${DateTime.now().millisecondsSinceEpoch}';
    final lng = double.tryParse(lngController.text) ?? 126.9771;
    final lat = double.tryParse(latController.text) ?? 37.5647;
    final scale = double.tryParse(scaleController.text) ?? 50.0;
    await _send({
      'v':1,
      'type':'addModel',
      'id': id,
      'lngLatAlt':[lng, lat, 0],
      'model': {'kind':'url','value': urlController.text, 'scale': scale},
    });
  }

  Future<void> _addBulkMarkers() async {
    if (!_ready) return;
    int i = 0;
    for (final spot in spotList.take(50)) {
      final name = spot['name']?.toString() ?? 'spot';
      final url = spot['imageUrl']?.toString() ?? '';
      final lat = (spot['Lat'] as num).toDouble();
      final lon = (spot['Lon'] as num).toDouble();
      final id = 'spot_${i++}_${DateTime.now().millisecondsSinceEpoch}';
      await _send({
        'v':1,
        'type':'addMarker',
        'id': id,
        'lngLat':[lon, lat],
        'icon':{'kind':'url','value':url,'size':[56,56],'anchor':'bottom'},
        'label': name,
        'popupHtml':'<b>$name</b>'
      });
    }
  }

  Future<void> _clearAllMarkers() async {
    if (!_ready) return;
    await _send({'v':1,'type':'clearMarkers'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('KISE-MAPTEST')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilledButton(
                    onPressed: _ready? _addMarkerDialog : null,
                    child: const Text('마커 생성'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _ready? _addModelDialog : null,
                    child: const Text('모델 생성'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _ready? _addBulkMarkers : null,
                    child: const Text('마커 50개 생성'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _ready? _clearAllMarkers : null,
                    child: const Text('전체 삭제'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (kIsWeb) {
                  if (_viewTypeId == null) return const SizedBox();
                  return HtmlElementView(viewType: _viewTypeId!);
                }
                return _controller==null? const SizedBox() : WebViewWidget(controller: _controller!);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setupWebIFrame() {
    final id = 'map-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _viewTypeId = id;
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = '0'
      ..src = 'assets/map/index.html?token=pk.eyJ1IjoicGh5dXppb24iLCJhIjoiY21mOTFnYTg5MGQ4cDJrbzlrNG50c2Z2dyJ9.bQ9adwhAmshtzEuk60R8hA';
    _iframe = iframe;
    // Register view factory for HtmlElementView (Web only)
    registerHtmlViewFactory(id, (int viewId) => iframe);

    _messageSub = html.window.onMessage.listen((event) {
      if (!mounted) return;
      final data = event.data;
      if (data is Map) {
        final eventName = data['event'];
        if (eventName == 'mapReady') {
          if (!mounted) return;
          setState(() { _ready = true; });
          _setToken();
        } else if (eventName == 'mapClick') {
          final arr = (data['lngLat'] as List?);
          if (arr != null && arr.length == 2) {
            final lng = (arr[0] as num).toDouble();
            final lat = (arr[1] as num).toDouble();
            _showModelPickerAt(lng, lat);
          }
        }
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            final eventName = decoded['event'];
            if (eventName == 'mapReady') {
              if (!mounted) return;
              setState(() { _ready = true; });
              _setToken();
            } else if (eventName == 'mapClick') {
              final arr = (decoded['lngLat'] as List?);
              if (arr != null && arr.length == 2) {
                final lng = (arr[0] as num).toDouble();
                final lat = (arr[1] as num).toDouble();
                _showModelPickerAt(lng, lat);
              }
            }
          }
        } catch (_) {}
      }
    });
  }

  Future<T?> _withIframeInputPaused<T>(Future<T?> Function() action) async {
    if (kIsWeb && _iframe != null) {
      try {
        _iframe!.style.pointerEvents = 'none';
        return await action();
      } finally {
        if (_iframe != null) {
          _iframe!.style.pointerEvents = 'auto';
        }
      }
    }
    return await action();
  }
}



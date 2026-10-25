import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum CustomPageRenderMode { adaptiveMobile, originalDesktop }

class CustomPageHtmlView extends StatefulWidget {
  const CustomPageHtmlView({
    super.key,
    required this.page,
    this.standaloneLayout = false,
    this.renderMode = CustomPageRenderMode.adaptiveMobile,
    this.fillViewport = false,
  });

  final CustomPage page;
  final bool standaloneLayout;
  final CustomPageRenderMode renderMode;
  final bool fillViewport;

  @override
  State<CustomPageHtmlView> createState() => _CustomPageHtmlViewState();
}

class _CustomPageHtmlViewState extends State<CustomPageHtmlView> {
  static const double _standaloneViewportWidth = 1200;

  late final WebViewController _controller;
  double _height = 480;
  double _contentWidth = _standaloneViewportWidth;
  bool _loading = true;
  bool _htmlLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'AnkiBlob',
        onMessageReceived: (message) =>
            unawaited(_handleBlobDownloadMessage(message)),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _resizeToContent(),
          onNavigationRequest: _handleNavigationRequest,
        ),
      );
    unawaited(_configureAndroidFileSelector());
  }

  Future<void> _configureAndroidFileSelector() async {
    final platformController = _controller.platform;
    if (platformController is! AndroidWebViewController) return;

    await platformController.setOnShowFileSelector(_handleAndroidFileSelector);
  }

  Future<List<String>> _handleAndroidFileSelector(
    FileSelectorParams params,
  ) async {
    if (!mounted || params.mode == FileSelectorMode.save) return <String>[];
    if (!_acceptsImages(params)) {
      _showFileSelectorMessage('当前页面仅支持从相册选择图片。');
      return <String>[];
    }

    final picker = ImagePicker();
    try {
      if (params.isCaptureEnabled) {
        final picked = await picker.pickImage(source: ImageSource.camera);
        return picked == null ? <String>[] : <String>[_toFileUri(picked.path)];
      }

      if (params.mode == FileSelectorMode.openMultiple) {
        final picked = await picker.pickMultiImage();
        return picked
            .map((file) => file.path)
            .where((path) => path.isNotEmpty)
            .map(_toFileUri)
            .toList();
      }

      final picked = await picker.pickImage(source: ImageSource.gallery);
      return picked == null ? <String>[] : <String>[_toFileUri(picked.path)];
    } catch (_) {
      _showFileSelectorMessage('无法打开相册，请检查应用权限后重试。');
      return <String>[];
    }
  }

  String _toFileUri(String path) => Uri.file(path).toString();

  Future<void> _handleBlobDownloadMessage(JavaScriptMessage message) async {
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is! Map<String, dynamic>) return;

      final dataUrl = decoded['dataUrl'] as String?;
      if (dataUrl == null || !dataUrl.startsWith('data:')) return;

      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex <= 0) return;

      final metadata = dataUrl.substring(0, commaIndex);
      final payload = dataUrl.substring(commaIndex + 1);
      final bytes = metadata.contains(';base64')
          ? base64Decode(payload)
          : utf8.encode(Uri.decodeComponent(payload));
      final fileName = _sanitizeDownloadFileName(
        decoded['fileName'] as String?,
        metadata,
      );
      final directory = await _downloadDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text('已保存：$fileName')));
    } catch (_) {
      _showFileSelectorMessage('保存图片失败，请重试。');
    }
  }

  Future<Directory> _downloadDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {
      // Fall back to app documents on platforms without a public downloads dir.
    }
    return getApplicationDocumentsDirectory();
  }

  String _sanitizeDownloadFileName(String? rawName, String metadata) {
    final fallbackExtension = metadata.contains('image/jpeg') ? 'jpg' : 'png';
    final fallbackName = 'jirai-export.$fallbackExtension';
    final fileName = rawName == null || rawName.trim().isEmpty
        ? fallbackName
        : rawName.trim();
    return fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  bool _acceptsImages(FileSelectorParams params) {
    if (params.acceptTypes.isEmpty) return true;
    return params.acceptTypes.any((type) {
      final normalized = type.trim().toLowerCase();
      return normalized.isEmpty ||
          normalized == '*/*' ||
          normalized.startsWith('image/') ||
          normalized == '.jpg' ||
          normalized == '.jpeg' ||
          normalized == '.png' ||
          normalized == '.webp' ||
          normalized == '.gif';
    });
  }

  void _showFileSelectorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_htmlLoaded) {
      _htmlLoaded = true;
      unawaited(_loadHtml());
    }
  }

  @override
  void didUpdateWidget(covariant CustomPageHtmlView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id ||
        oldWidget.page.content != widget.page.content ||
        oldWidget.page.customCss != widget.page.customCss ||
        oldWidget.page.customJs != widget.page.customJs ||
        oldWidget.standaloneLayout != widget.standaloneLayout ||
        oldWidget.renderMode != widget.renderMode ||
        oldWidget.fillViewport != widget.fillViewport) {
      setState(() {
        _height = 480;
        _contentWidth = _standaloneViewportWidth;
        _loading = true;
      });
      unawaited(_loadHtml());
    }
  }

  Future<void> _loadHtml() async {
    await _controller.loadHtmlString(_buildHtml());
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _resizeToContent() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final result = await _controller.runJavaScriptReturningResult('''
        JSON.stringify({
          height: Math.max(
            document.body ? document.body.scrollHeight : 0,
            document.documentElement ? document.documentElement.scrollHeight : 0,
            document.body ? document.body.offsetHeight : 0,
            document.documentElement ? document.documentElement.offsetHeight : 0
          ),
          width: Math.max(
            document.body ? document.body.scrollWidth : 0,
            document.documentElement ? document.documentElement.scrollWidth : 0,
            document.body ? document.body.offsetWidth : 0,
            document.documentElement ? document.documentElement.offsetWidth : 0
          )
        });
      ''');
      final size = _parseDocumentSize(result);
      if (!mounted) return;
      setState(() {
        _height = (size.height ?? _height).clamp(260, 8000).toDouble();
        if (widget.renderMode == CustomPageRenderMode.originalDesktop) {
          _contentWidth = (size.width ?? _contentWidth)
              .clamp(_standaloneViewportWidth, 4800)
              .toDouble();
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _buildHtml() {
    final content = widget.page.content;
    final style = _buildStyle();
    final lateStyle = _buildLateStyle();
    final script = _buildScript();
    final viewport = _buildViewportMeta();
    final hasFullDocument = RegExp(
      r'<html[\s>]',
      caseSensitive: false,
    ).hasMatch(content);

    if (hasFullDocument) {
      return _injectIntoFullDocument(
        content,
        viewport,
        style,
        lateStyle,
        script,
      );
    }

    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  $viewport
  <style>$style</style>
</head>
<body>
  <main class="custom-page-mobile-root">
    $content
  </main>
  $lateStyle
  $script
</body>
</html>
''';
  }

  String _injectIntoFullDocument(
    String html,
    String viewport,
    String style,
    String lateStyle,
    String script,
  ) {
    const headEndPattern = '</head>';
    const bodyEndPattern = '</body>';
    final headInjection =
        '''
$viewport
<style>$style</style>
''';
    var result = _stripViewportMeta(html);
    if (result.toLowerCase().contains(headEndPattern)) {
      result = result.replaceFirst(
        RegExp(r'</head>', caseSensitive: false),
        '$headInjection</head>',
      );
    } else {
      result = '$headInjection$result';
    }

    final bodyInjection = '$lateStyle$script';
    if (bodyInjection.isNotEmpty &&
        result.toLowerCase().contains(bodyEndPattern)) {
      result = result.replaceFirst(
        RegExp(r'</body>', caseSensitive: false),
        '$bodyInjection</body>',
      );
    } else if (bodyInjection.isNotEmpty) {
      result = '$result$bodyInjection';
    }
    return result;
  }

  String _buildViewportMeta() {
    if (widget.renderMode == CustomPageRenderMode.originalDesktop) {
      return '<meta name="viewport" content="width=${_standaloneViewportWidth.toInt()}, initial-scale=1, user-scalable=yes">';
    }
    return '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">';
  }

  String _buildStyle() {
    final primary = _hex(Theme.of(context).colorScheme.primary);
    final onSurface = _hex(Theme.of(context).colorScheme.onSurface);
    final customCss = _sanitizeStyle(widget.page.customCss ?? '');
    if (widget.renderMode == CustomPageRenderMode.originalDesktop) {
      return '''
html, body {
  margin: 0;
  padding: 0;
  min-width: ${_standaloneViewportWidth}px;
  min-height: 100%;
  background: transparent;
  color: $onSurface;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-size: 16px;
  line-height: 1.6;
  overflow-x: visible;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}
* { box-sizing: border-box; }
.custom-page-mobile-root { min-width: ${_standaloneViewportWidth}px; }
table { border-collapse: collapse; }
th, td { border: 1px solid rgba(128, 128, 128, 0.28); padding: 8px; }
a { color: $primary; }
$customCss
''';
    }

    return '''
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  min-height: 100%;
  background: transparent;
  color: $onSurface;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-size: 16px;
  line-height: 1.72;
  word-break: break-word;
  overflow-wrap: anywhere;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}
* { box-sizing: border-box; }
.custom-page-mobile-root { width: 100%; }
img, video, iframe, canvas, svg { max-width: 100%; height: auto; }
iframe.jirai-editor-frame,
iframe[data-anki-embedded-tool="jirai-editor"] {
  width: 100%;
  height: max(620px, calc(100dvh - 72px));
  min-height: 620px;
}
pre, code { white-space: pre-wrap; overflow-wrap: anywhere; }
table { max-width: 100%; border-collapse: collapse; display: block; overflow-x: auto; }
th, td { border: 1px solid rgba(128, 128, 128, 0.28); padding: 8px; }
a { color: $primary; }
$customCss
''';
  }

  String _buildLateStyle() {
    if (!widget.standaloneLayout ||
        widget.renderMode != CustomPageRenderMode.adaptiveMobile) {
      return '';
    }
    return '''
<style>
html,
body {
  width: 100% !important;
  min-width: 0 !important;
  max-width: 100% !important;
  overflow-x: hidden !important;
}

body {
  padding-left: env(safe-area-inset-left) !important;
  padding-right: env(safe-area-inset-right) !important;
  overflow-y: auto !important;
  -webkit-overflow-scrolling: touch;
}

.custom-page-mobile-root,
body > *,
main,
section,
article,
header,
footer,
nav,
aside,
.container,
.wrapper,
.page,
.content,
.card,
.panel {
  width: 100% !important;
  min-width: 0 !important;
  max-width: 100% !important;
}

.custom-page-mobile-root * {
  min-width: 0 !important;
  max-width: 100% !important;
}

img,
picture,
video,
iframe:not(.jirai-editor-frame):not([data-anki-embedded-tool="jirai-editor"]),
embed,
object,
svg,
canvas {
  max-width: 100% !important;
  height: auto !important;
}

iframe.jirai-editor-frame,
iframe[data-anki-embedded-tool="jirai-editor"] {
  width: 100% !important;
  max-width: 100% !important;
  height: max(620px, calc(100dvh - 72px)) !important;
  min-height: 620px !important;
}

table {
  width: 100% !important;
  max-width: 100% !important;
  display: block !important;
  overflow-x: auto !important;
  -webkit-overflow-scrolling: touch;
}

pre,
code {
  max-width: 100% !important;
  white-space: pre-wrap !important;
  overflow-wrap: anywhere !important;
}

[style*="width"],
[style*="min-width"] {
  max-width: 100% !important;
}

[style*="min-width"] {
  min-width: 0 !important;
}

[style*="position: fixed"],
[style*="position:fixed"] {
  position: absolute !important;
}
</style>
''';
  }

  String _buildScript() {
    final customJs = widget.page.customJs;
    final scripts = [_buildDownloadBridgeScript()];
    if (customJs != null && customJs.trim().isNotEmpty) {
      scripts.add(_sanitizeJavaScript(customJs));
    }
    return scripts.map((script) => '<script>$script</script>').join();
  }

  String _buildDownloadBridgeScript() {
    return r'''
(function () {
  if (window.__ankiBlobBridgeInstalled) return;
  window.__ankiBlobBridgeInstalled = true;

  window.addEventListener('message', function (event) {
    var data = event.data;
    if (typeof data === 'string') {
      try {
        data = JSON.parse(data);
      } catch (_) {
        return;
      }
    }

    if (!data || typeof data !== 'object') return;

    if (data.__ankiBlobProbe === true) {
      try {
        event.source && event.source.postMessage({ __ankiBlobBridgeReady: true }, '*');
      } catch (_) {}
      return;
    }

    if (
      data.__ankiBlobDownload === true &&
      data.dataUrl &&
      window.AnkiBlob &&
      typeof window.AnkiBlob.postMessage === 'function'
    ) {
      window.AnkiBlob.postMessage(JSON.stringify({
        fileName: data.fileName,
        dataUrl: data.dataUrl
      }));
    }
  });
})();
''';
  }

  String _stripViewportMeta(String html) {
    return html.replaceAll(
      RegExp(
        r'''<meta\s+[^>]*name=["']viewport["'][^>]*>''',
        caseSensitive: false,
      ),
      '',
    );
  }

  ({double? height, double? width}) _parseDocumentSize(Object result) {
    try {
      var raw = result.toString();
      if (raw.startsWith('"') && raw.endsWith('"')) {
        raw = jsonDecode(raw) as String;
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return (
          height: _toDouble(decoded['height']),
          width: _toDouble(decoded['width']),
        );
      }
    } catch (_) {
      final parsed = double.tryParse(result.toString().replaceAll('"', ''));
      return (height: parsed, width: null);
    }
    return (height: null, width: null);
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double _effectiveHeight(BuildContext context, BoxConstraints constraints) {
    if (widget.fillViewport && constraints.hasBoundedHeight) {
      return constraints.maxHeight.clamp(260.0, 8000.0).toDouble();
    }

    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height -
        media.padding.top -
        media.padding.bottom -
        kToolbarHeight -
        88;
    final maxHeight = availableHeight.clamp(420.0, 760.0).toDouble();
    return _height.clamp(260.0, maxHeight).toDouble();
  }

  String _sanitizeJavaScript(String js) {
    final patterns = [
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'document\.write', caseSensitive: false),
      RegExp(r'innerHTML\s*=', caseSensitive: false),
      RegExp(r'outerHTML\s*=', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
    ];
    var safeJs = js;
    for (final pattern in patterns) {
      safeJs = safeJs.replaceAll(pattern, '/* BLOCKED */');
    }
    return safeJs.replaceAll('</script', '<\\/script');
  }

  String _sanitizeStyle(String css) {
    return css.replaceAll('</style', '<\\/style');
  }

  String _hex(Color color) {
    final value = color.toARGB32() & 0x00ffffff;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final useDesktopCanvas =
        widget.renderMode == CustomPageRenderMode.originalDesktop;
    return LayoutBuilder(
      builder: (context, constraints) {
        final webView = SizedBox(
          height: _effectiveHeight(context, constraints),
          width: useDesktopCanvas ? _contentWidth : double.infinity,
          child: WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
        );

        return Stack(
          children: [
            if (useDesktopCanvas)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: webView,
              )
            else
              webView,
            if (_loading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}

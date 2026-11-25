// Локальный предпросмотр сайта: dart tools/serve.dart [порт]
import 'dart:io';

const _types = {
  'html': 'text/html; charset=utf-8',
  'css': 'text/css',
  'js': 'text/javascript',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'svg': 'image/svg+xml',
  'woff2': 'font/woff2',
  'txt': 'text/plain; charset=utf-8',
};

Future<void> main(List<String> args) async {
  final root = Directory(Platform.script.resolve('..').toFilePath()).absolute.path;
  final port = args.isEmpty ? 8643 : int.parse(args.first);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('http://localhost:$port');
  await for (final req in server) {
    var path = Uri.decodeComponent(req.uri.path);
    if (path.endsWith('/')) path += 'index.html';
    final file = File('$root${path.replaceAll('/', Platform.pathSeparator)}');
    if (path.contains('..') || !file.existsSync()) {
      req.response.statusCode = 404;
      await req.response.close();
      continue;
    }
    req.response.headers.contentType = ContentType.parse(
      _types[path.split('.').last] ?? 'application/octet-stream',
    );
    await req.response.addStream(file.openRead());
    await req.response.close();
  }
}

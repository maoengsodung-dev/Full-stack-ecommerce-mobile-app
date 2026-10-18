import 'dart:io';
import 'package:architecture_getx/flavor.dart';

class MediaUrlResolver {
  MediaUrlResolver._();

  /// Resolves relative URLs (/storage/...) and local dev addresses (localhost / 127.0.0.1)
  /// so that mobile devices and emulators connect to the correct host.
  static String resolve(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    String url = rawUrl.trim();

    final baseUri = Uri.tryParse(F.baseUrl);
    final serverRoot = baseUri != null
        ? '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}'
        : 'http://10.0.2.2:8000';

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
      if (!cleanUrl.startsWith('storage/')) {
        url = '$serverRoot/storage/$cleanUrl';
      } else {
        url = '$serverRoot/$cleanUrl';
      }
    } else {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        url = uri.replace(
          scheme: baseUri?.scheme ?? uri.scheme,
          host: baseUri?.host ?? (Platform.isAndroid ? '10.0.2.2' : 'localhost'),
          port: baseUri?.hasPort == true ? baseUri!.port : uri.port,
        ).toString();
      }
    }
    // Append version cache-buster if not present
    if (!url.contains('?v=')) {
      url = '$url?v=lux1';
    }
    return url;
  }
}

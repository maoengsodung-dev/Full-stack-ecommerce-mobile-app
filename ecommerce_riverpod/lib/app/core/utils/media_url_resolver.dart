import 'dart:io';
import '../config/flavor_config.dart';

class MediaUrlResolver {
  MediaUrlResolver._();

  static String resolve(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    String url = rawUrl.trim();

    final baseUri = Uri.tryParse(FlavorConfig.baseUrl);
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

    if (!url.contains('?v=')) {
      url = '$url?v=lux1';
    }
    return url;
  }
}

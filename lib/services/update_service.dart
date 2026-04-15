import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:convert';

class UpdateInfo {
  final int buildNumber;
  final String tagName;
  final String apkUrl;

  const UpdateInfo({
    required this.buildNumber,
    required this.tagName,
    required this.apkUrl,
  });
}

class UpdateService extends ChangeNotifier {
  static const String _owner = 'JeremyPF';
  static const String _repo = 'mibiblia';
  static const String _apiBase = 'https://api.github.com/repos/$_owner/$_repo';

  UpdateInfo? _availableUpdate;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  bool _isReady = false; // APK descargado listo para instalar
  String? _apkPath;

  UpdateInfo? get availableUpdate => _availableUpdate;
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;
  bool get isReady => _isReady;

  /// Consulta la última release y compara con la versión instalada
  Future<void> checkForUpdates() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final response = await http
          .get(
            Uri.parse('$_apiBase/releases/latest'),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';

      // Tag format: "build-N"
      final buildMatch = RegExp(r'build-(\d+)').firstMatch(tagName);
      if (buildMatch == null) return;
      final remoteBuild = int.parse(buildMatch.group(1)!);

      if (remoteBuild <= currentBuild) return;

      // Buscar el APK en los assets
      final assets = data['assets'] as List<dynamic>? ?? [];
      final apkAsset = assets.firstWhere(
        (a) => (a['name'] as String).endsWith('.apk'),
        orElse: () => null,
      );
      if (apkAsset == null) return;

      _availableUpdate = UpdateInfo(
        buildNumber: remoteBuild,
        tagName: tagName,
        apkUrl: apkAsset['browser_download_url'] as String,
      );
      notifyListeners();
    } catch (_) {
      // Silencioso — no interrumpir la experiencia de lectura
    }
  }

  /// Descarga el APK en background
  Future<void> downloadUpdate() async {
    if (_availableUpdate == null || _isDownloading) return;

    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      final dir = await getTemporaryDirectory();
      final apkFile = File('${dir.path}/mibiblia-update.apk');

      final request = http.Request('GET', Uri.parse(_availableUpdate!.apkUrl));
      final response = await request.send();
      final total = response.contentLength ?? 0;
      int received = 0;

      final sink = apkFile.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          _downloadProgress = received / total;
          notifyListeners();
        }
      }
      await sink.close();

      _apkPath = apkFile.path;
      _isDownloading = false;
      _isReady = true;
      notifyListeners();
    } catch (_) {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Lanza el instalador del sistema usando FileProvider (Android 7+)
  Future<void> installUpdate() async {
    if (_apkPath == null) return;
    if (!Platform.isAndroid) return;

    // Construir el content:// URI via FileProvider
    // La autoridad debe coincidir con AndroidManifest.xml
    const authority = 'com.personal.mi_biblia.fileprovider';
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'content://$authority/cache/${_apkPath!.split('/').last}',
      type: 'application/vnd.android.package-archive',
      flags: [
        Flag.FLAG_ACTIVITY_NEW_TASK,
        Flag.FLAG_GRANT_READ_URI_PERMISSION,
      ],
    );
    await intent.launch();
  }

  void dismiss() {
    _availableUpdate = null;
    _isReady = false;
    _apkPath = null;
    notifyListeners();
  }
}

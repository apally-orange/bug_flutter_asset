import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MyAssetBundle extends StatefulWidget {
  const MyAssetBundle({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MyAssetBundle> createState() => _MyAssetBundleState();
}

class _MyAssetBundleState extends State<MyAssetBundle> {
  late CachingAssetBundle assetBundle;

  @override
  void initState() {
    super.initState();
    assetBundle = AppCachingAssetBundle();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultAssetBundle(
      bundle: assetBundle,
      child: widget.child,
    );
  }
}

class AppCachingAssetBundle extends CachingAssetBundle {
  AppCachingAssetBundle();

  @override
  Future<ByteData> load(String key) async {
    ByteData? asset = await _getAssetsFromKey(key);
    const darkFolder = '/dark/';
    if (asset == null && key.contains(darkFolder)) {
      final lightKey = key.replaceAll(darkFolder, '/light/');
      asset = await _getAssetsFromKey(lightKey);
    }

    if (asset == null) {
      throw FlutterError('Unable to load asset: $key');
    }

    return asset;
  }

  Future<ByteData?> _getAssetsFromKey(String key) async {
    final Uint8List encoded = utf8.encoder.convert(
      Uri(
        path: Uri.encodeFull(key),
      ).path,
    );

    return await ServicesBinding.instance.defaultBinaryMessenger.send(
      'flutter/assets',
      encoded.buffer.asByteData(),
    );
  }
}

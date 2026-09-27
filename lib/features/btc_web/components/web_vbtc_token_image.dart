import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
// Transitive dependency of cached_network_image 3.2.3, which doesn't re-export the enum.
// ignore: depend_on_referenced_packages
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';

/// Renders a vBTC token image decoded at its on-screen size.
///
/// The default token image is a 1080x1080, ~120-frame animated GIF. Decoding
/// it at full size (once per list tile) exhausted the web renderer's memory
/// (QA MTI#5), so the image is always decoded at [size] x devicePixelRatio.
///
/// On web the network image is fetched as bytes ([ImageRenderMethodForWeb.HttpGet])
/// because the default HtmlImage path ignores the requested decode size.
/// Both a width and a height are passed, as the browser's ImageDecoder only
/// honours a target size when both are given, so non-square images are
/// scaled to a square.
///
/// With [animate] false only the first frame is decoded, which is what list
/// rows use.
class WebVbtcTokenImage extends StatelessWidget {
  const WebVbtcTokenImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.animate = true,
  });

  final String imageUrl;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
    final decodeSize = (size * dpr).round();

    ImageProvider<Object> sized(ImageProvider<Object> provider) {
      final ImageProvider<Object> resized = ResizeImage(provider, width: decodeSize, height: decodeSize);
      if (animate) return resized;
      return FirstFrameImage(resized);
    }

    final network = CachedNetworkImageProvider(
      imageUrl,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
    );

    return Image(
      image: sized(network),
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, _, __) => Image(
        image: sized(AssetImage(Assets.images.vbtcPng.path)),
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Wraps [imageProvider] so that only its first frame is decoded and shown.
///
/// Animated images (GIF/WebP) otherwise keep decoding a new frame every few
/// milliseconds for as long as they are on screen.
@immutable
class FirstFrameImage extends ImageProvider<FirstFrameImageKey> {
  const FirstFrameImage(this.imageProvider);

  final ImageProvider<Object> imageProvider;

  @override
  Future<FirstFrameImageKey> obtainKey(ImageConfiguration configuration) async {
    final innerKey = await imageProvider.obtainKey(configuration);
    return FirstFrameImageKey(innerKey);
  }

  @override
  ImageStreamCompleter loadBuffer(FirstFrameImageKey key, DecoderBufferCallback decode) {
    Future<ui.Codec> decodeFirstFrame(
      ui.ImmutableBuffer buffer, {
      int? cacheWidth,
      int? cacheHeight,
      bool allowUpscaling = false,
    }) async {
      final codec = await decode(
        buffer,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        allowUpscaling: allowUpscaling,
      );
      return _FirstFrameCodec(codec);
    }

    return imageProvider.loadBuffer(key.providerKey, decodeFirstFrame);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FirstFrameImage && other.imageProvider == imageProvider;
  }

  @override
  int get hashCode => imageProvider.hashCode;
}

@immutable
class FirstFrameImageKey {
  const FirstFrameImageKey(this.providerKey);

  final Object providerKey;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FirstFrameImageKey && other.providerKey == providerKey;
  }

  @override
  int get hashCode => Object.hash(FirstFrameImageKey, providerKey);
}

/// Reports a single frame so [MultiFrameImageStreamCompleter] emits it once
/// and never schedules another decode.
class _FirstFrameCodec implements ui.Codec {
  _FirstFrameCodec(this._codec);

  final ui.Codec _codec;

  @override
  int get frameCount => 1;

  @override
  int get repetitionCount => 0;

  @override
  Future<ui.FrameInfo> getNextFrame() => _codec.getNextFrame();

  @override
  void dispose() => _codec.dispose();
}

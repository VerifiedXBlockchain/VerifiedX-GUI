import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
// Transitive dependency of cached_network_image 3.2.3, which doesn't re-export the enum.
// ignore: depend_on_referenced_packages
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;
import 'package:flutter/material.dart';


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

  /// The image Spyglass returns for every vBTC token without a custom one.
  static const defaultImageUrl = 'https://vfx-resources.s3.amazonaws.com/defaultvBTC.gif';

  /// Bundled 256 px first frame of [defaultImageUrl], and a 256 px copy of the
  /// fallback logo. Chrome's ImageDecoder ignores the requested size for GIFs,
  /// so resizing the network image still decoded it at 1080x1080 per tile and
  /// the renderer still crashed (QA MTI#5 retest, 2026-09-27 20:31). List rows
  /// therefore never decode the default GIF at all.
  static const _defaultThumbAsset = 'assets/images/vbtc_default_thumb.png';
  static const _defaultLargeAsset = 'assets/images/vbtc_default_512.png';
  static const _fallbackThumbAsset = 'assets/images/vbtc_thumb.png';

  @override
  Widget build(BuildContext context) {
    // The default GIF is never decoded, not even on the detail screen: one
    // animated 1080x1080 GIF there still swung the renderer between 0.3 and
    // 1.1 GB and crashed it (QA MTI#5 retest, 20:31 and 20:36-20:43), because
    // every frame is decoded at full size. Show its first frame from a bundled
    // file sized for the widget instead.
    if (imageUrl == defaultImageUrl) {
      final asset = size * (MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0) > 256 ? _defaultLargeAsset : _defaultThumbAsset;
      return Image.asset(asset, width: size, height: size, fit: BoxFit.cover);
    }

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
      // The byte fetch above needs the image host to allow cross-origin
      // requests. When it can't load (no CORS headers, or not an image), try
      // the browser's own <img> element, which doesn't need CORS but decodes
      // at full size, and only then fall back to the logo.
      errorBuilder: (context, _, __) => CachedNetworkImage(
        imageUrl: imageUrl,
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (context, _, __) => Image(
          image: sized(const AssetImage(_fallbackThumbAsset)),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
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

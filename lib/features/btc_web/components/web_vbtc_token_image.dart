import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
// Transitive dependency of cached_network_image 3.2.3, which doesn't re-export the enum.
// ignore: depend_on_referenced_packages
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart' show ImageRenderMethodForWeb;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_metadata;

/// Renders a vBTC token image decoded at its on-screen size.
///
/// The default token image is a 1080x1080, ~120-frame animated GIF. Decoding
/// it at full size (once per list tile) exhausted the web renderer's memory
/// (QA MTI#5), so it is replaced with bundled stills.
///
/// On web the network image is fetched as bytes ([ImageRenderMethodForWeb.HttpGet])
/// because the default HtmlImage path ignores the requested decode size.
/// Custom images use their encoded dimensions to request a proportional decode
/// at [size] x devicePixelRatio wide. Both dimensions are supplied because the
/// browser's ImageDecoder can ignore a width-only target.
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

    final network = CachedNetworkImageProvider(
      imageUrl,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
    );

    return Image(
      image: vbtcTokenImageProvider(network, decodeWidth: decodeSize, animate: animate),
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
          image: vbtcTokenImageProvider(const AssetImage(_fallbackThumbAsset), decodeWidth: decodeSize, animate: animate),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Applies the same proportional sizing and animation policy to custom images
/// and the fallback logo. A square decode target would stretch non-square art
/// before [BoxFit.cover] has a chance to crop it.
ImageProvider<Object> vbtcTokenImageProvider(ImageProvider<Object> provider, {required int decodeWidth, bool animate = true}) {
  final ImageProvider<Object> resized = _ProportionalResizeImage(provider, decodeWidth);
  return animate ? resized : FirstFrameImage(resized);
}

/// Reads image headers without decoding pixels or animation frames. Flutter
/// 3.7's web ImageDescriptor does not expose encoded width/height, so metadata
/// is read from the bytes before handing the actual decode to the engine.
@immutable
class _ProportionalResizeImage extends ImageProvider<_ProportionalResizeImageKey> {
  const _ProportionalResizeImage(this.provider, this.width);

  final ImageProvider<Object> provider;
  final int width;

  @override
  Future<_ProportionalResizeImageKey> obtainKey(ImageConfiguration configuration) async {
    return _ProportionalResizeImageKey(await provider.obtainKey(configuration), width);
  }

  @override
  ImageStreamCompleter loadBuffer(_ProportionalResizeImageKey key, DecoderBufferCallback decode) {
    Future<ui.Codec> decodeProportionally(Uint8List bytes, {int? cacheWidth, int? cacheHeight, bool allowUpscaling = false}) async {
      int? targetWidth;
      int? targetHeight;
      try {
        final size = _encodedImageSize(bytes);
        if (size != null && size.width > 0 && size.height > 0) {
          targetWidth = math.min(width, size.width.toInt());
          targetHeight = math.max(1, (size.height * targetWidth / size.width).round());
        }
      } catch (_) {
        // If metadata is unreadable, let the engine try its supported formats
        // at natural size instead of guessing a ratio or rejecting the image.
      }
      return decode(
        await ui.ImmutableBuffer.fromUint8List(bytes),
        cacheWidth: targetWidth,
        cacheHeight: targetHeight,
        allowUpscaling: false,
      );
    }

    // The bytes callback is needed for headers; ImmutableBuffer cannot expose
    // its bytes on this Flutter version. CachedNetworkImage supports both APIs.
    // ignore: deprecated_member_use
    return provider.load(key.providerKey, decodeProportionally);
  }

  @override
  bool operator ==(Object other) => other is _ProportionalResizeImage && other.provider == provider && other.width == width;

  @override
  int get hashCode => Object.hash(provider, width);
}

@immutable
class _ProportionalResizeImageKey {
  const _ProportionalResizeImageKey(this.providerKey, this.width);

  final Object providerKey;
  final int width;

  @override
  bool operator ==(Object other) => other is _ProportionalResizeImageKey && other.providerKey == providerKey && other.width == width;

  @override
  int get hashCode => Object.hash(_ProportionalResizeImageKey, providerKey, width);
}

Size? _encodedImageSize(Uint8List bytes) {
  if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xd8) {
    // image 4.0's JPEG startDecode allocates full-resolution coefficient arrays
    // even for metadata. Read the SOF dimensions directly to avoid that cost.
    final size = _jpegSize(bytes);
    if (size == null) return null;
    final orientation = image_metadata.decodeJpgExif(bytes)?.imageIfd.orientation ?? 1;
    return orientation >= 5 && orientation <= 8 ? Size(size.height, size.width) : size;
  }
  final info = image_metadata.findDecoderForData(bytes)?.startDecode(bytes);
  return info == null ? null : Size(info.width.toDouble(), info.height.toDouble());
}

Size? _jpegSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  var offset = 2; // SOI
  while (offset < bytes.length) {
    if (bytes[offset] != 0xff) return null;
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset++;
    }
    if (offset >= bytes.length) return null;
    final marker = bytes[offset++];
    if (marker == 0xda || marker == 0xd9) return null; // SOS / EOI
    if (marker == 0x01 || (marker >= 0xd0 && marker <= 0xd8)) continue;
    if (offset + 2 > bytes.length) return null;
    final length = data.getUint16(offset);
    if (length < 2 || offset + length > bytes.length) return null;
    if (marker >= 0xc0 && marker <= 0xcf && marker != 0xc4 && marker != 0xc8 && marker != 0xcc) {
      if (length < 8) return null;
      return Size(data.getUint16(offset + 5).toDouble(), data.getUint16(offset + 3).toDouble());
    }
    offset += length;
  }
  return null;
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

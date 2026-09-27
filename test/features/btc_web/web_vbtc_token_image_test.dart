import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/components/web_vbtc_token_image.dart';

// 20x20, 3-frame animated GIF (red, blue, green), looping forever.
const _animatedGifB64 =
    'R0lGODlhFAAUAIEAAP8AAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQAAgAAACwAAAAAFAAUAAAIIgABCBxIsKDBgwgTKlzIsKHDhxAjSpxIsaLFixgzatxoMSAAIfkEAQIAAQAsAAAAABQAFACBAAD/AAAAAAAAAAAACCIAAQgcSLCgwYMIEypcyLChw4cQI0qcSLGixYsYM2rcaDEgACH5BAECAAEALAAAAAAUABQAgQD/AAAAAAAAAAAAAAgiAAEIHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNq3GgxIAA7';

// 20x20 single-frame PNG.
const _pngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAIAAAAC64paAAAAKUlEQVR4nGP8z0A+YKJAL8OoZhIBE6kakMGoZhIBE6kakMGoZhIBRZoBIpwBJy3phGMAAAAASUVORK5CYII=';

/// Resolves [provider] and pumps for a while, returning every frame emitted.
/// Animated frames are delivered on scheduler frames, so decoding (real async)
/// and pumping (fake time) are interleaved.
Future<List<ui.Image>> _collectFrames(WidgetTester tester, ImageProvider provider) async {
  final frames = <ui.Image>[];
  Object? error;
  final listener = ImageStreamListener(
    (info, _) => frames.add(info.image),
    onError: (e, _) => error = e,
  );
  final stream = provider.resolve(ImageConfiguration.empty);
  stream.addListener(listener);
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  stream.removeListener(listener);
  expect(error, isNull);
  return frames;
}

void main() {
  final gifBytes = base64Decode(_animatedGifB64);

  setUp(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });

  testWidgets('FirstFrameImage emits a single frame of an animated GIF', (tester) async {
    final animatedFrames = await _collectFrames(tester, MemoryImage(gifBytes));
    expect(animatedFrames.length, greaterThan(1), reason: 'sanity check: the fixture animates');

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final staticFrames = await _collectFrames(tester, FirstFrameImage(MemoryImage(gifBytes)));
    expect(staticFrames, hasLength(1));
  });

  testWidgets('FirstFrameImage keeps the ResizeImage decode size', (tester) async {
    // The native test engine ignores target sizes for multi-frame images (the
    // web ImageDecoder honours them), so check the size pass-through on a PNG.
    final frames = await _collectFrames(
      tester,
      FirstFrameImage(ResizeImage(MemoryImage(base64Decode(_pngB64)), width: 8, height: 8)),
    );
    expect(frames, hasLength(1));
    expect(frames.single.width, 8);
    expect(frames.single.height, 8);
  });

  test('FirstFrameImage equality follows the wrapped provider', () {
    final a = FirstFrameImage(const AssetImage('a.gif'));
    final b = FirstFrameImage(const AssetImage('a.gif'));
    final c = FirstFrameImage(const AssetImage('b.gif'));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, isFalse);
    expect(const FirstFrameImageKey('k'), const FirstFrameImageKey('k'));
  });
}

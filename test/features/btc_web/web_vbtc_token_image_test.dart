import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_fixture;
import 'package:rbx_wallet/features/btc_web/components/web_vbtc_token_image.dart';

// 20x20, 3-frame animated GIF (red, blue, green), looping forever.
const _animatedGifB64 =
    'R0lGODlhFAAUAIEAAP8AAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQAAgAAACwAAAAAFAAUAAAIIgABCBxIsKDBgwgTKlzIsKHDhxAjSpxIsaLFixgzatxoMSAAIfkEAQIAAQAsAAAAABQAFACBAAD/AAAAAAAAAAAACCIAAQgcSLCgwYMIEypcyLChw4cQI0qcSLGixYsYM2rcaDEgACH5BAECAAEALAAAAAAUABQAgQD/AAAAAAAAAAAAAAgiAAEIHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNq3GgxIAA7';

// 20x20 single-frame PNG.
const _pngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAIAAAAC64paAAAAKUlEQVR4nGP8z0A+YKJAL8OoZhIBE6kakMGoZhIBE6kakMGoZhIBRZoBIpwBJy3phGMAAAAASUVORK5CYII=';

// Non-square PNGs catch a square decode target stretching custom artwork.
const _landscapePngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAACgAAAAUCAIAAABwJOjsAAAAJElEQVR4nO3NMQ0AAAwEofdvupVxCwk7uy3RrGKxWCwWi8WJB336HQ594lo5AAAAAElFTkSuQmCC';
const _portraitPngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAABQAAAAoCAIAAABxU02MAAAAJElEQVR4nGP4z8BANiJf56jmUc2jmkc1j2oe1TyqeVTziNcMAKCfHQ6SlAp5AAAAAElFTkSuQmCC';

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
  // CanvasKit's browser codec has a real-time expiry clock. Start its async
  // work outside fake time so its cleanup timer does not leak from the test.
  final stream = (await tester.runAsync(() async {
    final stream = provider.resolve(ImageConfiguration.empty);
    stream.addListener(listener);
    return stream;
  }))!;
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
    // GIF decoders can ignore target sizes; check size pass-through on a PNG.
    final frames = await _collectFrames(
      tester,
      FirstFrameImage(ResizeImage(MemoryImage(base64Decode(_pngB64)), width: 8, height: 8)),
    );
    expect(frames, hasLength(1));
    // Chrome may ignore PNG decode targets even when both are supplied.
    expect(frames.single.width, kIsWeb ? anyOf(8, 20) : 8);
    expect(frames.single.height, frames.single.width);
  });

  for (final animate in [false, true]) {
    for (final landscape in [false, true]) {
      testWidgets('custom ${landscape ? 'landscape' : 'portrait'} image keeps its aspect ratio (animate: $animate)', (tester) async {
        final frames = await _collectFrames(
          tester,
          vbtcTokenImageProvider(
            MemoryImage(base64Decode(landscape ? _landscapePngB64 : _portraitPngB64)),
            decodeWidth: 8,
            animate: animate,
          ),
        );
        expect(frames, hasLength(1));
        expect(frames.single.width / frames.single.height, landscape ? 2.0 : 0.5);
        expect(frames.single.width, kIsWeb ? anyOf(8, landscape ? 40 : 20) : 8);
      });
    }
  }

  testWidgets('custom JPEG orientation is preserved while resizing', (tester) async {
    final source = image_fixture.Image(width: 40, height: 20);
    source.exif.imageIfd.orientation = 6;
    final frames = await _collectFrames(
      tester,
      vbtcTokenImageProvider(MemoryImage(image_fixture.encodeJpg(source)), decodeWidth: 8),
    );
    expect(frames.single.width, 8);
    // JPEG decoders may round their native downsampling by one pixel.
    expect(frames.single.height, closeTo(16, 1));
  });

  testWidgets('custom list GIF still emits only the first frame', (tester) async {
    final frames = await _collectFrames(tester, vbtcTokenImageProvider(MemoryImage(gifBytes), decodeWidth: 8, animate: false));
    expect(frames, hasLength(1));
  });

  testWidgets('default list and detail images use bundled stills', (tester) async {
    for (final size in [100.0, 200.0]) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 2),
          child: WebVbtcTokenImage(imageUrl: WebVbtcTokenImage.defaultImageUrl, size: size, animate: size == 200),
        ),
      ));
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName,
          size == 100 ? 'assets/images/vbtc_default_thumb.png' : 'assets/images/vbtc_default_512.png');
    }
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

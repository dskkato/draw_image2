import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Draw sample2'),
        ),
        body: DrawingArea());
  }
}

class DrawingArea extends StatefulWidget {
  @override
  _DrawingAreaState createState() => _DrawingAreaState();
}

Future<ui.FrameInfo> _loadImage(AssetBundle bundle, String path) async {
  final data = await bundle.load(path);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  return codec.getNextFrame();
}

class _DrawingAreaState extends State<DrawingArea> {
  double _scale = 1.0;
  double _scalePrev = 1.0;
  late Offset _start;
  Offset _delta = Offset.zero;
  Offset _deltaPrev = Offset.zero;
  int devicePointerCount = 0;
  @override
  void initState() {
    super.initState();

    if (Platform.isIOS || Platform.isAndroid) {
      devicePointerCount = 2;
    } else {
      devicePointerCount = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    return FutureBuilder<ui.FrameInfo>(
      future: _loadImage(bundle, 'assets/fruit.jpg'),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasData) {
          var image = snapshot.data!.image;
          child = Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final nextScale = _scale + 0.01 * pointerSignal.scrollDelta.dy;
                setState(() {
                  if (nextScale > 0.3) {
                    _scale = nextScale;
                    _scalePrev = _scale;
                  }
                });
              } else if (pointerSignal is PointerMoveEvent) {}
            },
            child: GestureDetector(
              onScaleStart: (details) {
                setState(() {
                  _start = details.localFocalPoint;
                });
              },
              onScaleUpdate: (details) {
                setState(() {
                  if (details.pointerCount == devicePointerCount) {
                    final offset = details.localFocalPoint - _start;
                    _delta = offset / _scale + _deltaPrev;
                    _scale = _scalePrev * details.scale;
                  }
                });
              },
              onScaleEnd: (details) {
                setState(() {
                  _scalePrev = _scale;
                  _deltaPrev = _delta;
                });
              },
              child: Container(
                width: image.width.toDouble(),
                height: image.height.toDouble(),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Transform.translate(
                  offset: _delta,
                  child: Transform.scale(
                    scale: _scale,
                    origin: -_delta,
                    child: CustomPaint(
                      painter: DrawingPainter(image),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          child = Text('error occurred');
        } else {
          child = Text('waiting...');
        }
        return child;
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final ui.Image _image;
  DrawingPainter(this._image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(_image, Offset.zero, new Paint());
  }

  @override
  bool shouldRepaint(DrawingPainter old) {
    return old._image != this._image;
  }
}

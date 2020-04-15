import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double _scaleProgress = 0.0;
  Animation<double> scaleProgress;
  AnimationController controller;
  List<Circle> circles = <Circle>[];
  double ITEM_SIZE = 10.0;
  bool updateFlag = false;
  ui.Image maskImage;

  final _random = new Random();

  void generateItems() {
    double screenWidth = ui.window.physicalSize.width;
    double screenHeight = ui.window.physicalSize.height;

    double columns = (screenWidth / ITEM_SIZE).ceilToDouble() + 1;
    double rows = (screenHeight / ITEM_SIZE).ceilToDouble() + 1;
    int amount = (columns * rows).ceil();
    for (var i = 0; i < amount; i++) {
      double column = i % columns;
      double row = (i / columns).floorToDouble();
      // Paint paint = Paint()..color = Color(0xffaecbf7);
      Paint paint = Paint()..color = Color(0xff000000);

      circles.add(Circle(
          position: Offset(column * ITEM_SIZE, row * ITEM_SIZE),
          radius: (ITEM_SIZE / 30) * _random.nextDouble(),
          paint: paint));
    }

    setState(() {
      updateFlag = !updateFlag;
    });
  }

  Completer<ImageInfo> completer = Completer();
  Future<ui.Image> getImage() async {
    String path =
        'https://oyebesmartest.com/public/uploads/preview/vivo-u20-mobile-wallpaper-full-hd-original-(1)l9kwmpro8e.png';
    var img = new NetworkImage(path);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;

    setState(() {
      maskImage = imageInfo.image;
    });
  }

  @override
  void initState() {
    super.initState();

    getImage();

    generateItems();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000));

    controller.forward();

    scaleProgress = Tween(begin: 1.0, end: 50.0).animate(controller)
      ..addListener(() {
        setState(() {
          _scaleProgress = scaleProgress.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ui.window.physicalSize.width;
    double screenHeight = ui.window.physicalSize.height;

    return Scaffold(
      body: CustomPaint(
        size: Size(screenWidth, screenHeight),
        painter: Painter1(
            scaleProgress: _scaleProgress,
            circles: circles,
            maskImage: maskImage),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class Painter1 extends CustomPainter {
  double scaleProgress;
  List<Circle> circles;
  ui.Image maskImage;

  Painter1({this.circles, this.scaleProgress, this.maskImage});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint bgPaint = Paint()..color = Color(0xffaecbf7);
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    Path path = Path();

    for (var i = 0; i < circles.length; i++) {
      circles[i].update(canvas, path, scaleProgress);
    }

    // Paint paint = Paint()..color = Color(0xff000000);
    // canvas.drawPath(path, paint);

    canvas.clipPath(path);

    canvas.drawImageRect(
        maskImage,
        Rect.fromLTRB(
            0.0, 0.0, maskImage.width.toDouble(), maskImage.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Circle {
  Offset position;
  double radius;
  Paint paint;

  Circle({this.position, this.radius, this.paint});

  void update(Canvas canvas, Path path, double scale) {
    // canvas.drawCircle(position, radius * scale, paint);
    path.addOval(Rect.fromCircle(center: position, radius: radius * scale));
  }
}

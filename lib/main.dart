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
  double ITEM_SIZE = 30.0;
  bool updateFlag = false;
  ui.Image maskImage;
  Offset currentPosition;

  final _random = new Random();

  void generateItems() {
    double screenWidth = ui.window.physicalSize.width / 2;
    double screenHeight = ui.window.physicalSize.height / 2;

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
          radius: 1,
          paint: paint));
    }

    setState(() {
      updateFlag = !updateFlag;
    });
  }

  Completer<ImageInfo> completer = Completer();

  Future<void> getImage() async {
    String path =
        'https://camo.githubusercontent.com/439826448be7909f3d90757596c7d9f2d4aacc56/68747470733a2f2f6c68362e676f6f676c6575736572636f6e74656e742e636f6d2f2d334c69462d4d426c364f452f554f3554585a37323461492f41414141414141414535302f4a574c716465454d3951592f73323536302f436f6c6f7261646f253242526976657225324253756e7365742e6a7067';
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

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    Tween(begin: 0.0, end: 1.0).animate(controller).addListener(() {
      setState(() {
        updateFlag = !updateFlag;
      });
    });

    controller.repeat();

    getImage();
    generateItems();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ui.window.physicalSize.width / 2;
    double screenHeight = ui.window.physicalSize.height / 2;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
//          setState(() {
            currentPosition = dragUpdateDetails.globalPosition;
//          });
        },
        child: CustomPaint(
          size: Size(screenWidth, screenHeight),
          painter: Painter1(
              currentPosition: currentPosition,
              circles: circles,
              maskImage: maskImage),
        ),
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
  Offset currentPosition;
  List<Circle> circles;
  ui.Image maskImage;

  Painter1({this.circles, this.currentPosition, this.maskImage});

  @override
  void paint(Canvas canvas, Size size) {
     Paint bgPaint = Paint()..color = Color(0xffe0dad5);
     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    Path path = Path();

    for (var i = 0; i < circles.length; i++) {
      circles[i].update(currentPosition);
      circles[i].draw(canvas, path);
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

  double _radius;
  double growthValue = 0.0;

  Circle({this.position, this.radius, this.paint}){
    _radius = radius;
  }

  double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
  }
  double interpolate(double value, double min, double max) {
    return min + (max - min) * value;
  }
  double map(double value, double min1, double max1, double min2, double max2) {
    return interpolate(normalize(value, min1, max1), min2, max2);
  }

  void draw(Canvas canvas, Path path) {
    radius += ((_radius + growthValue) - (radius)) * 0.075;

    // canvas.drawCircle(position, d, paint);
    path.addOval(Rect.fromCircle(center: position, radius: radius));
  }

  void update(Offset currentPosition) {
    double distance = (currentPosition - position).distance;
    double d = map(distance, radius, radius + 120, 50, 0);
    if (d < 1) d = 0.1;

    growthValue = d;
  }
}

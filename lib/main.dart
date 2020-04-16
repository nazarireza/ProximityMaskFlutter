import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import 'circlePainter.dart';
import 'circle.dart';
import 'constants.dart';

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
  Ticker _ticker;
  List<Circle> circles = <Circle>[];
  bool updateFlag = false;
  ui.Image maskImage;
  Offset currentPosition;

  void generateItems() {
    double screenWidth = ui.window.physicalSize.width / 2;
    double screenHeight = ui.window.physicalSize.height / 2;
    currentPosition = Offset(screenWidth / 2, screenHeight / 2);

    double columns = (screenWidth / ITEM_CONTAINER_SIZE).ceilToDouble() + 1;
    double rows = (screenHeight / ITEM_CONTAINER_SIZE).ceilToDouble() + 1;
    int amount = (columns * rows).ceil();
    for (var i = 0; i < amount; i++) {
      double column = i % columns;
      double row = (i / columns).floorToDouble();
      circles.add(Circle(
          position:
              Offset(column * ITEM_CONTAINER_SIZE, row * ITEM_CONTAINER_SIZE),
          radius: ITEM_SIZE));
    }
  }

  Future<void> getImage() async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(IMAGE_PATH);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    maskImage = imageInfo.image;
  }

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((Duration duration) {
      setState(() => updateFlag = !updateFlag);
    })
      ..start();

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
          currentPosition = dragUpdateDetails.globalPosition;
        },
        child: Container(
          color: const Color(0xffe0dad5),
          child: CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: CirclePainter(
                currentPosition: currentPosition,
                circles: circles,
                maskImage: maskImage),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

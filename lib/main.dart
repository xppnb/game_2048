import 'dart:math';

import 'package:flutter/material.dart';
import 'package:last_2048_2/Tile.dart';
import 'package:last_2048_2/grid-properties.dart';

enum Direction { Left, Right, Up, Down }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameHome(),
    );
  }
}

class GameHome extends StatefulWidget {
  const GameHome({Key key}) : super(key: key);

  @override
  _GameHomeState createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  List<List<Tile>> rowTile =
      List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));

  List<List<Tile>> get colTile =>
      List.generate(4, (x) => List.generate(4, (y) => rowTile[y][x]));

  Iterable<Tile> get expends => rowTile.expand((element) => element);

  List<Tile> newTile = [];

  AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Random().nextInt(100) < 50) {
      rowTile[Random().nextInt(4)][Random().nextInt(4)].val = 2;
    } else {
      rowTile[Random().nextInt(4)][Random().nextInt(4)].val = 4;
    }

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        expends.forEach((element) {
          element.resetAnimation();
        });
      }
    });

    expends.forEach((element) {
      element.resetAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16 * 2;
    double tileSize = (gridSize - 4 * 2) / 4;

    List<Widget> stackItems = [];

    stackItems.addAll(expends.map((e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4 * 2,
              height: tileSize - 4 * 2,
              decoration: BoxDecoration(
                  color: lightBrown, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        )));

    stackItems.addAll(expends.map((e) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => e.animationValue.value == 0
            ? SizedBox()
            : Positioned(
                left: e.animationX.value * tileSize,
                top: e.animationY.value * tileSize,
                width: tileSize,
                height: tileSize,
                child: Center(
                  child: Container(
                    width: (tileSize - 4 * 2) * e.scale.value,
                    height: (tileSize - 4 * 2) * e.scale.value,
                    decoration: BoxDecoration(
                        color: numTileColor[e.animationValue.value],
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        e.animationValue.value.toString(),
                        style: TextStyle(
                            color: numTextColor[e.animationValue.value],
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                  ),
                ),
              ))));

    return Scaffold(
      backgroundColor: tan,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(4),
          width: gridSize,
          height: gridSize,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: darkBrown),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 250 &&
                  canSwipeDirection(Direction.Right)) {
                doSwipe(Direction.Right);
              } else if (details.velocity.pixelsPerSecond.dx < -250 &&
                  canSwipeDirection(Direction.Left)) {
                doSwipe(Direction.Left);
              }
            },
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 250 &&
                  canSwipeDirection(Direction.Down)) {
                doSwipe(Direction.Down);
              } else if (details.velocity.pixelsPerSecond.dy < -250 &&
                  canSwipeDirection(Direction.Up)) {
                doSwipe(Direction.Up);
              }
            },
            child: Stack(
              children: stackItems,
            ),
          ),
        ),
      ),
    );
  }

  bool canSwipeDirection(Direction direction) {
    switch (direction) {
      case Direction.Left:
        // TODO: Handle this case.
        return rowTile.any(canSwipe);
        break;
      case Direction.Right:
        // TODO: Handle this case.
        return rowTile.map((e) => e.reversed.toList()).any(canSwipe);
        break;
      case Direction.Up:
        // TODO: Handle this case.
        return colTile.any(canSwipe);
        break;
      case Direction.Down:
        // TODO: Handle this case.
        return colTile.map((e) => e.reversed.toList()).any(canSwipe);
        break;
    }
    return false;
  }

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((element) => element.val != 0)) {
          return true;
        }
      } else {
        Tile nextTile = tiles
            .skip(i + 1)
            .firstWhere((element) => element.val != 0, orElse: () => null);
        if (nextTile != null && nextTile.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void doSwipe(Direction direction) {
    switch (direction) {
      case Direction.Left:
        // TODO: Handle this case.
        rowTile.forEach(swipe);
        break;
      case Direction.Right:
        rowTile.map((e) => e.reversed.toList()).forEach(swipe);
        // TODO: Handle this case.
        break;
      case Direction.Up:
        colTile.forEach(swipe);
        // TODO: Handle this case.
        break;
      case Direction.Down:
        colTile.map((e) => e.reversed.toList()).forEach(swipe);
        // TODO: Handle this case.
        break;
    }
    addNewTile();
    controller.forward(from: 0);
  }

  void swipe(List<Tile> tiles) {
    setState(() {
      for (int i = 0; i < tiles.length; i++) {
        Iterable<Tile> toCheck =
            tiles.skip(i).skipWhile((value) => value.val == 0);
        if (toCheck.isNotEmpty) {
          Tile t = toCheck.first;
          Tile merge = toCheck
              .skip(1)
              .firstWhere((element) => element.val != 0, orElse: () => null);
          if (merge != null && merge.val != t.val) {
            merge = null;
          }
          if (tiles[i] != t || merge != null) {
            int changeValue = t.val;
            t.moveTo(controller, tiles[i].x, tiles[i].y);
            if (merge != null) {
              changeValue += t.val;

              merge.moveTo(controller, tiles[i].x, tiles[i].y);
              merge.bounce(controller);
              merge.changeNumber(controller, changeValue);

              merge.val = 0;
              t.changeNumber(controller, 0);
            }
            t.val = 0;
            tiles[i].val = changeValue;
          }
        }
      }
    });
  }

  void addNewTile() {
    List<Tile> emptyTiles =
        expends.where((element) => element.val == 0).toList();
    emptyTiles.shuffle();
    if (Random().nextInt(100) < 50) {
      newTile.add(new Tile(emptyTiles.first.x, emptyTiles.first.y, 2));
    } else {
      newTile.add(new Tile(emptyTiles.first.x, emptyTiles.first.y, 4));
    }
    setState(() {
      newTile.forEach((element) {
        rowTile[element.y][element.x].val = element.val;
      });
      newTile.clear();
    });
  }
}

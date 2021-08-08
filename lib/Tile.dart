import 'package:flutter/material.dart';

class Tile {
  int x;
  int y;
  int val;

  Animation<double> animationX;
  Animation<double> animationY;
  Animation<int> animationValue;
  Animation<double> scale;

  Tile(this.x, this.y, this.val) {
    resetAnimation();
  }

  void resetAnimation() {
    animationX = AlwaysStoppedAnimation(this.x.toDouble());
    animationY = AlwaysStoppedAnimation(this.y.toDouble());
    animationValue = AlwaysStoppedAnimation(this.val);
    scale = AlwaysStoppedAnimation(1);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animationX = Tween(begin: this.x.toDouble(), end: x.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: Interval(0, .5)));
    animationY = Tween(begin: this.y.toDouble(), end: y.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: Interval(0, .5)));
  }

  void bounce(Animation<double> parent) {
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1.0)
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1.0)));
  }

  void appear(Animation<double> parent) {
    scale = Tween(begin: 0, end: 1.0)
        .animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1.0)));
  }

  void changeNumber(Animation<double> parent, int changeVal) {
    animationValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(this.val), weight: 1.0),
      TweenSequenceItem(tween: ConstantTween(changeVal), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1.0)));
  }
}

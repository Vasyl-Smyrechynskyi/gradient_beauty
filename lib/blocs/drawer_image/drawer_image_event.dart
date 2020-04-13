import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DrawerImageEvent extends Equatable {
  DrawerImageEvent([List props = const []]) : super(props);
}

class LoadDrawerImage extends DrawerImageEvent {
  @override
  String toString() => 'LoadDrawerImage';
}

class CameraShow extends DrawerImageEvent {
  final BuildContext context;

  CameraShow(this.context) : super([context]);

  @override
  String toString() => 'CameraShow';
}

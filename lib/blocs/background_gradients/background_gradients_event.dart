import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BackgroundGradientsEvent extends Equatable {
  BackgroundGradientsEvent([List props = const []]) : super(props);
}

class LoadAppGradientsData extends BackgroundGradientsEvent {
  @override
  String toString() => 'LoadAppGradientsData';
}

class SetRandomAppGradientsData extends BackgroundGradientsEvent {
  @override
  String toString() => 'SetAppGradientsData';
}

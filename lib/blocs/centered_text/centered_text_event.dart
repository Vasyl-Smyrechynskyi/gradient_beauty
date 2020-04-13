import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CenteredTextEvent extends Equatable {
  CenteredTextEvent([List props = const []]) : super(props);
}

class LoadCenteredTextData extends CenteredTextEvent {
  @override
  String toString() => 'LoadCenteredTextData';
}

class DecreaseCenteredTextFontSize extends CenteredTextEvent {
  final double decreaseValue;

  DecreaseCenteredTextFontSize([this.decreaseValue]) : super([decreaseValue]);

  @override
  String toString() =>
      'DecreaseCenteredTextFontSize { decreaseValue: $decreaseValue }';
}

class IncreaseCenteredTextFontSize extends CenteredTextEvent {
  final double increaseValue;

  IncreaseCenteredTextFontSize([this.increaseValue]) : super([increaseValue]);

  @override
  String toString() =>
      'IncreaseCenteredTextFontSize { increaseValue: $increaseValue }';
}

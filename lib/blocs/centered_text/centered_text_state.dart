import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CenteredTextState extends Equatable {
  CenteredTextState([List props = const []]) : super(props);
}

class CenteredTextDataLoading extends CenteredTextState {
  @override
  String toString() => 'CenteredTextDataLoading';
}

class CenteredTextDataLoaded extends CenteredTextState {
  final double fontSize;

  CenteredTextDataLoaded([this.fontSize]) : super([fontSize]);

  @override
  String toString() => 'CenteredTextDataLoaded { fontSize: $fontSize }';
}

class CenteredTextDataLoadingFailed extends CenteredTextState {
  @override
  String toString() => 'CenteredTextDataLoadingFailed';
}

class CenteredTextDataSet extends CenteredTextState {
  final double fontSize;

  CenteredTextDataSet([this.fontSize]) : super([fontSize]);

  @override
  String toString() => 'CenteredTextDataSet { fontSize: $fontSize }';
}

class CenteredTextMinFontSizeReached extends CenteredTextState {
  final double fontSize;

  CenteredTextMinFontSizeReached([this.fontSize]) : super([fontSize]);

  @override
  String toString() => 'CenteredTextMinFontSizeReached { fontSize: $fontSize }';
}

class CenteredTextMaxFontSizeReached extends CenteredTextState {
  final double fontSize;

  CenteredTextMaxFontSizeReached([this.fontSize]) : super([fontSize]);

  @override
  String toString() => 'CenteredTextMaxFontSizeReached { fontSize: $fontSize }';
}

class CenteredTextDataSetFailed extends CenteredTextState {
  @override
  String toString() => 'CenteredTextDataSetFailed';
}

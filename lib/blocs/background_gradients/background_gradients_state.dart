import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../models/models.dart';

@immutable
abstract class BackgroundGradientsState extends Equatable {
  BackgroundGradientsState([List props = const []]) : super(props);
}

class PreferencesLoading extends BackgroundGradientsState {
  @override
  String toString() => 'PreferencesLoading';
}

class AppGradientsDataLoading extends BackgroundGradientsState {
  @override
  String toString() => 'AppGradientsDataLoading';
}

class AppGradientsDataLoaded extends BackgroundGradientsState {
  final GradientData appBackgroundGradientData;
  final GradientData appBarGradientData;

  AppGradientsDataLoaded(
      [this.appBackgroundGradientData, this.appBarGradientData])
      : super([appBackgroundGradientData, appBackgroundGradientData]);

  @override
  String toString() =>
      'AppGradientsDataLoaded { appBackgroundGradientData: $appBackgroundGradientData, appBarGradientData: $appBarGradientData }';
}

class AppGradientsLoadingFailed extends BackgroundGradientsState {
  @override
  String toString() => 'AppGradientsLoadingFailed';
}

class AppGradientsDataSet extends BackgroundGradientsState {
  @override
  String toString() => 'AppGradientsDataSet';
}

class AppGradientsDataSetFailed extends BackgroundGradientsState {
  @override
  String toString() => 'AppGradientsDataSetFailed';
}

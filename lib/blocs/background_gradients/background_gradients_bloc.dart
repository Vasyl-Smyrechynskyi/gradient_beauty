import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../service_locator.dart';
import '../../services/services.dart';
import '../blocs.dart';

class BackgroundGradientsBloc
    extends Bloc<BackgroundGradientsEvent, BackgroundGradientsState> {
  @override
  BackgroundGradientsState get initialState => PreferencesLoading();
  final settingStorageService = locator<SettingsStorageService>();

  @override
  Stream<BackgroundGradientsState> mapEventToState(
      BackgroundGradientsEvent event) async* {
    if (event is LoadAppGradientsData)
      yield* _mapLoadGradientsDataToState(event);

    if (event is SetRandomAppGradientsData)
      yield* _mapSetRandomGradientsDataToState(event);
  }

  Stream<BackgroundGradientsState> _mapLoadGradientsDataToState(
    LoadAppGradientsData event,
  ) async* {
    try {
      final appBackgroundGradientData =
        settingStorageService.getAppBackgroundGradient();
      final appBarGradientData =
        settingStorageService.getAppBarGradient();

      yield AppGradientsDataLoaded(
          appBackgroundGradientData, appBarGradientData);
    } catch (_) {
      yield AppGradientsLoadingFailed();
    }
  }

  Stream<BackgroundGradientsState> _mapSetRandomGradientsDataToState(
    SetRandomAppGradientsData event,
  ) async* {
    try {
      await settingStorageService.setRandomAppBarGradient();
      await settingStorageService.setRandomAppBackgroundGradient();

      yield AppGradientsDataSet();
    } catch (_) {
      yield AppGradientsDataSetFailed();
    }
  }
}

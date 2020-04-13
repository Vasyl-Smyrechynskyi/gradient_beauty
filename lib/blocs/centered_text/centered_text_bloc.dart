import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../service_locator.dart';
import '../../services/services.dart';
import '../blocs.dart';

class CenteredTextBloc extends Bloc<CenteredTextEvent, CenteredTextState> {
  final double minFontSize = 10.0;
  final double maxFontSize = 80.0;
  final double defaultFontSize = 20.0;

  @override
  CenteredTextState get initialState => CenteredTextDataLoading();

  @override
  Stream<CenteredTextState> mapEventToState(CenteredTextEvent event) async* {
    if (event is LoadCenteredTextData)
      yield* _mapLoadCenteredTextDataToState(event);

    if (event is DecreaseCenteredTextFontSize)
      yield* _mapDecreaseCenteredTextFontSizeToState(event);

    if (event is IncreaseCenteredTextFontSize)
      yield* _mapIncreaseCenteredTextFontSizeToState(event);
  }

  Stream<CenteredTextState> _mapLoadCenteredTextDataToState(
    LoadCenteredTextData event,
  ) async* {
    try {
      final fontSize = _getFontSize();
      yield CenteredTextDataLoaded(fontSize);
    } catch (_) {
      yield CenteredTextDataLoadingFailed();
    }
  }

  Stream<CenteredTextState> _mapDecreaseCenteredTextFontSizeToState(
    DecreaseCenteredTextFontSize event,
  ) async* {
    try {
      final fontSize = _getFontSize();
      final resultFontSize = fontSize - event.decreaseValue;
      if (resultFontSize < minFontSize) {
        await _setFontSize(minFontSize);
        yield CenteredTextMinFontSizeReached(minFontSize);
      } else {
        await _setFontSize(resultFontSize);
        yield CenteredTextDataSet(resultFontSize);
      }
    } catch (_) {
      yield CenteredTextDataSetFailed();
    }
  }

  Stream<CenteredTextState> _mapIncreaseCenteredTextFontSizeToState(
    IncreaseCenteredTextFontSize event,
  ) async* {
    try {
      final fontSize = _getFontSize();
      final resultFontSize = fontSize + event.increaseValue;
      if (resultFontSize > maxFontSize) {
        await _setFontSize(maxFontSize);
        yield CenteredTextMaxFontSizeReached(maxFontSize);
      } else {
        _setFontSize(resultFontSize);
        yield CenteredTextDataSet(resultFontSize);
      }
    } catch (_) {
      yield CenteredTextDataSetFailed();
    }
  }

  _setFontSize(double size) async {
    await locator<SettingsStorageService>().setCenteredTextFontSize(size);
  }

  double _getFontSize() {
    return locator<SettingsStorageService>().getCenteredTextFontSize() ??
        defaultFontSize;
  }
}

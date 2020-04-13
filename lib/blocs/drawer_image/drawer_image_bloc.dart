import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:camera_camera/page/camera.dart';

import '../../service_locator.dart';
import '../../services/services.dart';
import '../blocs.dart';

class DrawerImageBloc extends Bloc<DrawerImageEvent, DrawerImageState> {
  final _settingsService = locator<SettingsStorageService>();

  @override
  DrawerImageState get initialState {
    return DrawerImageLoading();
  }

  @override
  Stream<DrawerImageState> mapEventToState(DrawerImageEvent event) async* {
    if (event is LoadDrawerImage) yield* _mapLoadDrawerImageToState(event);
    if (event is CameraShow) yield* _mapCameraShowToState(event);
  }

  Stream<DrawerImageState> _mapLoadDrawerImageToState(
    LoadDrawerImage event,
  ) async* {
    try {
      final imageFilePath = _settingsService.getCurrentDrawerImagePath();
      if (imageFilePath != null) {
        yield DrawerImageLoaded(imageFilePath);
      } else {
        yield DrawerImageNotLoaded();
      }
    } catch (_) {
      yield DrawerImageNotLoaded();
    }
  }

  Stream<DrawerImageState> _mapCameraShowToState(CameraShow event) async* {
    File file = await Navigator.push(
        event.context,
        MaterialPageRoute(
          builder: (context) => Camera(),
        ));
    if (file == null) {
      add(LoadDrawerImage());
    } else {
      _settingsService.setCurrentDrawerImagePath(file.path);
      add(LoadDrawerImage());
    }
  }
}

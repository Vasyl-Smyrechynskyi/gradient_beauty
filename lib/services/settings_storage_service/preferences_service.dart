import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/settings_storage_service/settings_storage_service_interface.dart';
import '../../helpers/helpers.dart';
import '../../models/gradient_data.dart';

class PreferencesService extends SettingsStorageService {
  SharedPreferences _preferences;
  final _random = Random();
  final List<double> _possibleDirectionXYValues = [-1.0, 0.0, 1.0];

  Future<SettingsStorageService> init() async {
    _preferences ??= await SharedPreferences.getInstance();
    return this;
  }

  Future<void> setRandomAppBackgroundGradient() async {
    await _preferences.setInt(
        'startBackgroundGradientColor', _random.nextInt(0xffffffff));
    await _preferences.setInt(
        'endBackgroundGradientColor', _random.nextInt(0xffffffff));
    await _preferences.setDouble('beginGradientDirectionFirstArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('beginGradientDirectionSecondArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('endGradientDirectionFirstArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('endGradientDirectionSecondArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    return;
  }

  Future<void> setRandomAppBarGradient() async {
    await _preferences.setInt(
        'startAppBarGradientColor', _random.nextInt(0xffffffff));
    await _preferences.setInt(
        'endAppBarGradientColor', _random.nextInt(0xffffffff));
    await _preferences.setDouble('beginAppBarGradientDirectionFirstArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('beginAppBarGradientDirectionSecondArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('endAppBarGradientDirectionFirstArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    await _preferences.setDouble('endAppBarGradientDirectionSecondArg',
        RandomValuePicker().pick(_possibleDirectionXYValues));
    return;
  }

  GradientData getAppBackgroundGradient() {
    return GradientData(
      Color(_preferences.getInt('startBackgroundGradientColor')).withAlpha(255),
      Color(_preferences.getInt('endBackgroundGradientColor')).withAlpha(255),
      Alignment(_preferences.getDouble('beginGradientDirectionFirstArg'),
          _preferences.getDouble('beginGradientDirectionSecondArg')),
      Alignment(_preferences.getDouble('endGradientDirectionFirstArg'),
          _preferences.getDouble('endGradientDirectionSecondArg')),
    );
  }

  GradientData getAppBarGradient() {
    return GradientData(
      Color(_preferences.getInt('startAppBarGradientColor')),
      Color(_preferences.getInt('endAppBarGradientColor')),
      Alignment(_preferences.getDouble('beginAppBarGradientDirectionFirstArg'),
          _preferences.getDouble('beginAppBarGradientDirectionSecondArg')),
      Alignment(_preferences.getDouble('endAppBarGradientDirectionFirstArg'),
          _preferences.getDouble('endAppBarGradientDirectionSecondArg')),
    );
  }

  Future<void> setCenteredTextFontSize(double fontSize) async {
    await _preferences.setDouble('centeredTextFontSize', fontSize);
  }

  double getCenteredTextFontSize() {
    return _preferences.getDouble('centeredTextFontSize');
  }

  setCurrentDrawerImagePath(String path) async {
    await _preferences.setString('curentDrawerImageFontSize', path);
  }

  String getCurrentDrawerImagePath() {
    return _preferences.getString('curentDrawerImageFontSize');
  }
}

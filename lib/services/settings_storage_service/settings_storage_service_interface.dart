import '../../models/gradient_data.dart';

abstract class SettingsStorageService {

  Future<SettingsStorageService> init();

  setRandomAppBackgroundGradient();

  setRandomAppBarGradient();

  GradientData getAppBackgroundGradient();

  GradientData getAppBarGradient();

  setCenteredTextFontSize(double fontSize);

  double getCenteredTextFontSize();

  setCurrentDrawerImagePath(String path);

  String getCurrentDrawerImagePath();
}
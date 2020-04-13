import 'dart:math';

class RandomValuePicker {
  static final RandomValuePicker _instance = RandomValuePicker._internal();
  final Random _random = Random();

  factory RandomValuePicker() => _instance;

  RandomValuePicker._internal();

  dynamic pick(List<dynamic> values) {
    final int valuesCount = values.length;

    return values[_random.nextInt(valuesCount)];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class GradientData {
  final Color startGradientColor;
  final Color endGradientColor;
  final Alignment beginDirection;
  final Alignment endDirection;

  const GradientData(
      this.startGradientColor,
      this.endGradientColor,
      this.beginDirection,
      this.endDirection);
}

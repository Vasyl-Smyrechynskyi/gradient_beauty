import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../models/models.dart';
import '../widgets/base_background.dart';

class AppBackground extends StatelessWidget {
  final child;

  AppBackground({this.child});

  @override
  Widget build(BuildContext context) {
    var appBackgroundGradientData;
    return BlocBuilder<BackgroundGradientsBloc, BackgroundGradientsState>(
        builder: (context, state) {
      if (state is AppGradientsLoadingFailed) {
        return _backgroundedContainer(appBackgroundGradientData);
      } else if (state is AppGradientsDataLoaded) {
        state.appBackgroundGradientData != null
            ? appBackgroundGradientData = state.appBackgroundGradientData
            : appBackgroundGradientData = appBackgroundGradientData;
        return _backgroundedContainer(state.appBackgroundGradientData);
      } else if (state is AppGradientsDataSet) {
        BlocProvider.of<BackgroundGradientsBloc>(context)
          ..add(LoadAppGradientsData());
        return _backgroundedContainer(appBackgroundGradientData);
      } else {
        return Container();
      }
    });
  }

  Widget _backgroundedContainer(GradientData gradientData) {
    if (gradientData != null &&
        gradientData.endGradientColor != null &&
        gradientData.startGradientColor != null &&
        gradientData.endDirection != null &&
        gradientData.beginDirection != null) {
      return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: gradientData.beginDirection,
              end: gradientData.endDirection,
              colors: <Color>[
                gradientData.startGradientColor,
                gradientData.endGradientColor
              ],
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: this.child);
    } else {
      return BaseBackground(
        child: this.child,
      );
    }
  }
}

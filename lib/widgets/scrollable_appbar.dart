import 'dart:math';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../blocs/blocs.dart';
import '../models/models.dart';

class ScrollableAppBar extends StatefulWidget {
  final String title;
  final double verticalOffset;
  final IconData rightIcon;
  final IconData leftIcon;
  final double opacity;
  final Gradient backgroundGradient;
  final bool scrollToStatusBar;
  final void Function() onRightIconPressed;
  final void Function() onLeftIconPressed;

  const ScrollableAppBar(
      {@required this.title,
      this.verticalOffset = 0.0,
      this.rightIcon = FontAwesomeIcons.camera,
      this.leftIcon = Icons.menu,
      this.opacity = 1.0,
      this.backgroundGradient,
      this.scrollToStatusBar = true,
      this.onRightIconPressed,
      this.onLeftIconPressed});

  @override
  _ScrollableAppBarState createState() => _ScrollableAppBarState();
}

class _ScrollableAppBarState extends State<ScrollableAppBar> {
  double previousVerticalOffset = 0.0;
  double appBarHeight = 76.0;
  double appBarPositionFromTop = 0.0;
  double appBarOpacity = 1.0;
  Color backgroundColor;
  double factor;
  double topAppBarTopPadding = 24.0;
  double screenWidth;
  MediaQueryData queryData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    queryData = MediaQuery.of(context);
    screenWidth = queryData.size.width;

    if (widget.backgroundGradient == null) {
      backgroundColor = Theme.of(context).appBarTheme.color;
    }
    factor = widget.scrollToStatusBar ? 24.0 : 0;
  }

  @override
  Widget build(BuildContext context) {
    var appBarGradientData;

    return Positioned.directional(
      top: _toolbarPosition(appBarHeight),
      width: screenWidth,
      textDirection: TextDirection.rtl,
      child: Column(children: <Widget>[
        Stack(children: <Widget>[
          Column(children: <Widget>[
            Opacity(
                opacity: appBarOpacity,
                child: BlocBuilder<BackgroundGradientsBloc,
                    BackgroundGradientsState>(builder: (context, state) {
                  if (state is AppGradientsLoadingFailed) {
                    return Container();
                  } else if (state is AppGradientsDataLoaded) {
                    state.appBarGradientData != null
                        ? appBarGradientData = state.appBarGradientData
                        : appBarGradientData = appBarGradientData;
                    return _backgroundedContainer(appBarGradientData);
                  } else if (state is AppGradientsDataSet) {
                    return _backgroundedContainer(appBarGradientData);
                  } else {
                    return _backgroundedContainer(appBarGradientData);
                  }
                })),
            Container(
                height: 10.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent],
                )))
          ]),
          Padding(
            padding: EdgeInsets.only(
                left: 4.0, right: 4.0, top: topAppBarTopPadding),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      icon: Icon(widget.leftIcon,
                          size: 24.0, color: Colors.white),
                      onPressed: () {
                        widget.onLeftIconPressed();
                      }),
                  Expanded(
                    child: Text(widget.title,
                        textAlign: _appBarTitleAlignment(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Montserrat",
                            fontStyle: FontStyle.normal,
                            fontSize: 22.0)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        icon: Icon(
                          widget.rightIcon,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.onRightIconPressed();
                        }),
                  )
                ]),
          ),
        ]),
      ]),
    );
  }

//  Widget _backgroundedContainer(GradientData data) => Container(
//        height: appBarHeight,
//        decoration: BoxDecoration(
//          color: backgroundColor,
//          gradient: LinearGradient(
//              begin: data.beginDirection,
//              end: data.endDirection,
//              colors: <Color>[data.startGradientColor, data.endGradientColor]),
//        ),
//      );

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
          height: appBarHeight,
          width: double.infinity);
    } else {
      return Container(
          height: appBarHeight,
          width: double.infinity,
          color: backgroundColor ?? Colors.transparent);
    }
  }

  _toolbarPosition(double toolbarHeight) {
    if (widget.verticalOffset == null ||
        toolbarHeight == null ||
        widget.verticalOffset < 0.0) return 0.0;

    var previousOffset = previousVerticalOffset;
    var isScrollDirectionUp = widget.verticalOffset > previousVerticalOffset;
    previousVerticalOffset = widget.verticalOffset;

    if (isScrollDirectionUp) {
      if (appBarPositionFromTop <= -toolbarHeight + factor) {
        if (widget.scrollToStatusBar) {
          var padding = factor + (appBarPositionFromTop - toolbarHeight);
          topAppBarTopPadding = padding >= 0.0 ? padding : 0.0;
        }
        return -toolbarHeight + factor;
      }
      var toolbarPosition = (widget.verticalOffset < toolbarHeight - factor)
          ? -widget.verticalOffset
          : max(
              (appBarPositionFromTop +
                  (previousOffset - widget.verticalOffset)),
              -52.0);
      appBarPositionFromTop = toolbarPosition;
      return toolbarPosition;
    } else {
      if (widget.scrollToStatusBar && -appBarPositionFromTop >= factor) {
        var padding = factor + (appBarPositionFromTop + toolbarHeight);
        topAppBarTopPadding =
            padding >= 0.0 && padding <= 24.0 ? padding : 24.0;
      }
      if (appBarPositionFromTop >= 0.0) return 0.0;

      var toolbarPosition =
          previousOffset - widget.verticalOffset + appBarPositionFromTop;
      toolbarPosition = (toolbarPosition > 0.0) ? 0.0 : toolbarPosition;
      appBarPositionFromTop = toolbarPosition;
      return toolbarPosition;
    }
  }

  _appBarTitleAlignment() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return TextAlign.start;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return TextAlign.center;
    }
  }
}

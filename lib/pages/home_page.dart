import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final appBarHeight = 76.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  var _scrollController = ScrollController();
  var _bottomNavigationBarIndex = 0;
  double _singleChildScrollViewOffset;
  BuildContext _buildContext;

  @override
  void initState() {
    super.initState();
    _scrollController
      ..addListener(() {
        setState(() {
          _singleChildScrollViewOffset = _scrollController.offset;
        });
      });
  }

  double get _extendedGlowingOverscrollIndicatorLeadingOffset {
    return (_singleChildScrollViewOffset != null)
        ? -_singleChildScrollViewOffset + appBarHeight
        : appBarHeight;
  }

  _onRightAppBarIconPressed() {
    BlocProvider.of<DrawerImageBloc>(_buildContext)
      ..add(CameraShow(_buildContext));
  }

  _onLeftAppBarIconPressed() {
    _scaffoldKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: AppBackground(
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            drawer: Drawer(
              child: BlocBuilder<DrawerImageBloc, DrawerImageState>(
                  builder: (context, state) {
                if (state is DrawerImageLoaded) {
                  return Image.file(
                    File(state.imagePath),
                    fit: BoxFit.fill,
                  );
                } else {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Your photo here',
                        style: TextStyle(color: Colors.black38, fontSize: 34.0),
                      ),
                    ),
                  );
                }
              }),
            ),
            body: AppBackground(
              child: Builder(
                builder: (BuildContext context) => MultiBlocListener(
                  listeners: [
                    BlocListener<CenteredTextBloc, CenteredTextState>(
                      listener: (context, state) {
                        if (state is CenteredTextMaxFontSizeReached) {
                          Scaffold.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Maximum text font size has been reached'),
                                    Icon(Icons.error)
                                  ],
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                        }
                        if (state is CenteredTextMinFontSizeReached) {
                          Scaffold.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Minimum text font size has been reached'),
                                    Icon(Icons.error)
                                  ],
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                        }
                      },
                    ),
                    BlocListener<DrawerImageBloc, DrawerImageState>(
                        listener: (context, state) {
                      if (state is DrawerImageLoaded) {
                        Scaffold.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Now your photo on the drower'),
                                  Icon(Icons.assignment_ind)
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                      }
                    })
                  ],
                  child: Stack(children: <Widget>[
                    ScrollConfiguration(
                        behavior: WithoutGlowingBehavior(),
                        child: ExtendedGlowingOverscrollIndicator(
                            startOpacity: 0.2,
                            maxOpacity: 0.35,
                            leadingOffset:
                                _extendedGlowingOverscrollIndicatorLeadingOffset,
                            axisDirection: AxisDirection.down,
                            child: InkWell(
                              onTap: () {
                                BlocProvider.of<BackgroundGradientsBloc>(
                                    context)
                                  ..add(SetRandomAppGradientsData());
                              },
                              child: ListView(
                                  addAutomaticKeepAlives: true,
                                  controller: _scrollController,
                                  children: <Widget>[
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                appBarHeight,
                                        width: double.infinity,
                                        child: Center(child: BlocBuilder<
                                                CenteredTextBloc,
                                                CenteredTextState>(
                                            builder: (context, state) {
                                          if (state
                                                  is CenteredTextDataLoading ||
                                              state
                                                  is CenteredTextDataLoadingFailed) {
                                            return Container();
                                          } else {
                                            return Text('Hey there',
                                                style: TextStyle(
                                                    fontSize: state.props[0],
                                                    color: Colors.white));
                                          }
                                        }))),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height),
                                  ]),
                            ))),
                    ScrollableAppBar(
                        opacity: 0.7,
                        verticalOffset: _singleChildScrollViewOffset,
                        title: "Gradient beauty",
                        onLeftIconPressed: _onLeftAppBarIconPressed,
                        onRightIconPressed: _onRightAppBarIconPressed)
                  ]),
                ),
              ),
            ),
            bottomNavigationBar: _indexBottom(),
          ),
        ));
  }

  Widget _indexBottom() => BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Column(children: <Widget>[
              Icon(Icons.add, size: 30.0, color: Colors.white38),
            ]),
            title: Container(),
            activeIcon: Icon(
              Icons.add,
              size: 30.0,
              color: Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.minus,
              size: 20,
              color: Colors.white38,
              //color: Colors.transparent,
            ),
            title: Container(),
            activeIcon: Icon(
              FontAwesomeIcons.minus,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: _bottomNavigationBarIndex,
        onTap: (index) {
          setState(() {
            _bottomNavigationBarIndex = index;
            switch (_bottomNavigationBarIndex) {
              case 0:
                BlocProvider.of<CenteredTextBloc>(context)
                  ..add(IncreaseCenteredTextFontSize(2.0));
                break;
              case 1:
                BlocProvider.of<CenteredTextBloc>(context)
                  ..add(DecreaseCenteredTextFontSize(1.5));
                break;
            }
          });
        },
      );
}

class WithoutGlowingBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

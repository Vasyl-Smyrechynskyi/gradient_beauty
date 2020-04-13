import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './blocs/blocs.dart';
import './pages/pages.dart';
import './service_locator.dart';
import './widgets/base_background.dart';

void main() {
  setupLocator();
  runApp(MyApp());

  BlocSupervisor.delegate = SimpleBlocDelegate();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: locator.allReady(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return MultiBlocProvider(
                providers: [
                  BlocProvider<BackgroundGradientsBloc>(
                    create: (context) {
                      return BackgroundGradientsBloc()
                        ..add(LoadAppGradientsData());
                    },
                  ),
                  BlocProvider<CenteredTextBloc>(
                    create: (context) {
                      return CenteredTextBloc()..add(LoadCenteredTextData());
                    },
                  ),
                  BlocProvider<DrawerImageBloc>(
                    create: (context) {
                      return DrawerImageBloc()..add(LoadDrawerImage());
                    },
                  ),
                ],
                child: MaterialApp(
                  home: BaseBackground(child: HomePage()),
                  debugShowCheckedModeBanner: false,
                ));
          } else {
            return BaseBackground();
          }
        });
  }
}

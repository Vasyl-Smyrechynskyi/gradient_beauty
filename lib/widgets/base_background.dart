import 'package:flutter/widgets.dart';

class BaseBackground extends StatelessWidget {
  final Widget child;

  BaseBackground({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color.fromARGB(255, 85, 255, 95),
            Color.fromARGB(255, 246, 111, 196),
            Color.fromARGB(255, 85, 187, 255)
          ],
        )),
        child: this.child);
  }
}

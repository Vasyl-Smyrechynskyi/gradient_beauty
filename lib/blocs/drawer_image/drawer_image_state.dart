import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DrawerImageState extends Equatable {
  DrawerImageState([List props = const []]) : super(props);
}

class DrawerImageLoading extends DrawerImageState {
  @override
  String toString() => 'DrawerImageLoading';
}

class DrawerImageLoaded extends DrawerImageState {
  final String imagePath;

  DrawerImageLoaded([this.imagePath]) : super([imagePath]);

  @override
  String toString() => 'DrawerImageLoaded { imagePath: $imagePath }';
}

class DrawerImageNotLoaded extends DrawerImageState {
  @override
  String toString() => 'DrawerImageNotLoaded';
}

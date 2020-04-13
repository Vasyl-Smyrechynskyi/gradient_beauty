import 'dart:async' show Timer;
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class ExtendedGlowingOverscrollIndicator extends StatefulWidget {
  const ExtendedGlowingOverscrollIndicator({
    Key key,
    this.startOpacity,
    this.recedeEndOpacity,
    this.maxOpacity,
    this.heightFactor,
    this.cutOffSides = false,
    this.leadingOffset = 0.0,
    this.trailingOffset = 0.0,
    this.showLeading = true,
    this.showTrailing = true,
    @required this.axisDirection,
    this.color,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.child,
  })  : assert(leadingOffset != null),
        assert(trailingOffset != null),
        assert(showLeading != null),
        assert(showTrailing != null),
        assert(axisDirection != null),
        assert(notificationPredicate != null),
        super(key: key);

  final double startOpacity;
  final double recedeEndOpacity;
  final double maxOpacity;
  final double heightFactor;
  final bool cutOffSides;
  final double leadingOffset;
  final double trailingOffset;
  final bool showLeading;
  final bool showTrailing;
  final AxisDirection axisDirection;
  Axis get axis => axisDirectionToAxis(axisDirection);
  final Color color;
  final ScrollNotificationPredicate notificationPredicate;
  final Widget child;

  @override
  _ExtendedGlowingOverscrollIndicatorState createState() =>
      _ExtendedGlowingOverscrollIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<AxisDirection>('axisDirection', axisDirection));
    String showDescription;
    if (showLeading && showTrailing) {
      showDescription = 'both sides';
    } else if (showLeading) {
      showDescription = 'leading side only';
    } else if (showTrailing) {
      showDescription = 'trailing side only';
    } else {
      showDescription = 'neither side (!)';
    }
    properties..add(MessageProperty('show', showDescription));
    properties..add(ColorProperty('color', color, showName: false));
  }
}

class _ExtendedGlowingOverscrollIndicatorState
    extends State<ExtendedGlowingOverscrollIndicator>
    with TickerProviderStateMixin {
  _ExtendedGlowController _leadingController;
  _ExtendedGlowController _trailingController;
  Listenable _leadingAndTrailingListener;

  @override
  void didUpdateWidget(ExtendedGlowingOverscrollIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _leadingController = _ExtendedGlowController(
        vsync: this,
        color: _color,
        axis: widget.axis,
        cutOffSides: widget.cutOffSides,
        heightFactor: widget.heightFactor,
        maxOpacity: widget.maxOpacity,
        recedeEndOpacity: widget.recedeEndOpacity,
        startOpacity: widget.startOpacity);
    _trailingController = _ExtendedGlowController(
        vsync: this,
        color: _color,
        axis: widget.axis,
        cutOffSides: widget.cutOffSides,
        heightFactor: widget.heightFactor,
        maxOpacity: widget.maxOpacity,
        recedeEndOpacity: widget.recedeEndOpacity,
        startOpacity: widget.startOpacity);
    _leadingAndTrailingListener =
        Listenable.merge(<Listenable>[_leadingController, _trailingController]);

    if (oldWidget.color != widget.color || oldWidget.axis != widget.axis) {
      _leadingController
        ..color = _color
        ..axis = widget.axis;
      _trailingController
        ..color = _color
        ..axis = widget.axis;
    }
  }

  Type _lastNotificationType;
  final Map<bool, bool> _accepted = <bool, bool>{false: true, true: true};

  Color get _color {
    return widget.color == null ? Theme.of(context).accentColor : widget.color;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    if (notification is OverscrollNotification) {
      _ExtendedGlowController controller;
      if (notification.overscroll < 0.0) {
        controller = _leadingController;
      } else if (notification.overscroll > 0.0) {
        controller = _trailingController;
      } else {
        assert(false);
      }
      final bool isLeading = controller == _leadingController;
      if (_lastNotificationType != OverscrollNotification) {
        final PositionedOverscrollIndicatorNotification
            confirmationNotification =
            PositionedOverscrollIndicatorNotification(leading: isLeading);
        confirmationNotification..dispatch(context);
        _accepted[isLeading] = confirmationNotification._accepted;
      }
      assert(controller != null);
      assert(notification.metrics.axis == widget.axis);
      if (_accepted[isLeading]) {
        if (notification.velocity != 0.0) {
          assert(notification.dragDetails == null);
          controller..absorbImpact(notification.velocity.abs());
        } else {
          assert(notification.overscroll != 0.0);
          if (notification.dragDetails != null) {
            assert(notification.dragDetails.globalPosition != null);
            final RenderBox renderer = notification.context.findRenderObject();
            assert(renderer != null);
            assert(renderer.hasSize);
            final Size size = renderer.size;
            final Offset position =
                renderer.globalToLocal(notification.dragDetails.globalPosition);
            switch (notification.metrics.axis) {
              case Axis.horizontal:
                controller
                  ..pull(notification.overscroll.abs(), size.width,
                      position.dy.clamp(0.0, size.height), size.height);
                break;
              case Axis.vertical:
                controller
                  ..pull(notification.overscroll.abs(), size.height,
                      position.dx.clamp(0.0, size.width), size.width);
                break;
            }
          }
        }
      }
    } else if (notification is ScrollEndNotification ||
        notification is ScrollUpdateNotification) {
      if ((notification as dynamic).dragDetails != null) {
        _leadingController?.scrollEnd();
        _trailingController?.scrollEnd();
      }
    }
    _lastNotificationType = notification.runtimeType;
    return false;
  }

  @override
  void dispose() {
    _leadingController?.dispose();
    _trailingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: CustomPaint(
          foregroundPainter: _PositionedGlowingOverscrollIndicatorPainter(
            leadingOffset: widget.leadingOffset,
            trailingOffset: widget.trailingOffset,
            leadingController: widget.showLeading ? _leadingController : null,
            trailingController:
                widget.showTrailing ? _trailingController : null,
            axisDirection: widget.axisDirection,
            repaint: _leadingAndTrailingListener,
          ),
          child: RepaintBoundary(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

enum _GlowState { idle, absorb, pull, recede }

class _ExtendedGlowController extends ChangeNotifier {
  _ExtendedGlowController({
    @required TickerProvider vsync,
    @required Color color,
    @required Axis axis,
    @required bool cutOffSides,
    double heightFactor,
    double maxOpacity,
    double recedeEndOpacity,
    double startOpacity,
  })  : assert(vsync != null),
        assert(color != null),
        assert(axis != null),
        assert(cutOffSides != null),
        _cutOffSides = cutOffSides,
        _color = color,
        _axis = axis {
    var _heightFactor = heightFactor == null ? 0.75 : heightFactor;
    _widthToHeightFactor = _heightFactor * (2.0 - _sqrt3);
    _displacementTicker = vsync.createTicker(_tickDisplacement);
    _recedeEndOpacity = recedeEndOpacity == null
        ? 0.0
        : math.max(math.min(recedeEndOpacity, 1.0), 0.0);
    _startOpacity =
        startOpacity == null ? 0.0 : math.max(math.min(startOpacity, 1.0), 0.0);
    _maxOpacity =
        maxOpacity == null ? 0.5 : math.max(math.min(maxOpacity, 1.0), 0.0);
    _glowOpacityTween = Tween<double>(begin: _startOpacity, end: 1.0);
    _glowController = AnimationController(vsync: vsync)
      ..addStatusListener(_changePhase);
    final Animation<double> decelerator = CurvedAnimation(
      parent: _glowController,
      curve: Curves.decelerate,
    )..addListener(notifyListeners);
    _glowOpacity = decelerator.drive(_glowOpacityTween);
    _glowSize = decelerator.drive(_glowSizeTween);
  }

  // extended opacity
  Tween<double> _glowOpacityTween;
  double _startOpacity;
  double _recedeEndOpacity;

  // extended relative height
  double _widthToHeightFactor;

  // extended - define whether cut glowing indicator sides or not
  bool _cutOffSides;

  // animation of the main axis direction
  _GlowState _state = _GlowState.idle;
  AnimationController _glowController;
  Timer _pullRecedeTimer;

  // animation values
  Animation<double> _glowOpacity;
  final Tween<double> _glowSizeTween = Tween<double>(begin: 0.0, end: 0.0);
  Animation<double> _glowSize;

  // animation of the cross axis position
  Ticker _displacementTicker;
  Duration _displacementTickerLastElapsed;
  double _displacementTarget = 0.5;
  double _displacement = 0.5;

  // tracking the pull distance
  double _pullDistance = 0.0;

  Color get color => _color;
  Color _color;
  set color(Color value) {
    assert(color != null);
    if (color == value) return;
    _color = value;
    notifyListeners();
  }

  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    assert(axis != null);
    if (axis == value) return;
    _axis = value;
    notifyListeners();
  }

  static const Duration _recedeTime = Duration(milliseconds: 600);
  static const Duration _pullTime = Duration(milliseconds: 167);
  static const Duration _pullHoldTime = Duration(milliseconds: 167);
  static const Duration _pullDecayTime = Duration(milliseconds: 2000);
  static final Duration _crossAxisHalfTime =
      Duration(microseconds: (Duration.microsecondsPerSecond / 60.0).round());

  double _maxOpacity;
  static const double _pullOpacityGlowFactor = 0.8;
  static const double _velocityGlowFactor = 0.00006;
  static const double _sqrt3 = 1.73205080757; // const math.sqrt(3)

  // absorbed velocities are clamped to the range _minVelocity.._maxVelocity
  static const double _minVelocity = 100.0; // logical pixels per second
  static const double _maxVelocity = 10000.0; // logical pixels per second

  @override
  void dispose() {
    _glowController.dispose();
    _displacementTicker.dispose();
    _pullRecedeTimer?.cancel();
    super.dispose();
  }

  void absorbImpact(double velocity) {
    assert(velocity >= 0.0);
    _pullRecedeTimer?.cancel();
    _pullRecedeTimer = null;
    velocity = velocity.clamp(_minVelocity, _maxVelocity);
    _glowOpacityTween
      ..begin = _state == _GlowState.idle ? 0.3 : _glowOpacity.value
      ..end = (velocity * _velocityGlowFactor)
          .clamp(_glowOpacityTween.begin, _maxOpacity);
    _glowSizeTween
      ..begin = _glowSize.value
      ..end = math.min(0.025 + 7.5e-7 * velocity * velocity, 1.0);
    _glowController
      ..duration = Duration(milliseconds: (0.15 + velocity * 0.02).round())
      ..forward(from: 0.0);
    _displacement = 0.5;
    _state = _GlowState.absorb;
  }

  void pull(double overscroll, double extent, double crossAxisOffset,
      double crossExtent) {
    _pullRecedeTimer?.cancel();
    _pullDistance += overscroll /
        200.0; // This factor is magic. Not clear why we need it to match Android.
    _glowOpacityTween
      ..begin = _glowOpacity.value
      ..end = math.min(
          (_glowOpacity.value < _startOpacity
                  ? _startOpacity
                  : _glowOpacity.value) +
              overscroll / extent * _pullOpacityGlowFactor,
          _maxOpacity);
    final double height = math.min(extent, crossExtent * _widthToHeightFactor);
    _glowSizeTween
      ..begin = _glowSize.value
      ..end = math.max(1.0 - 1.0 / (0.7 * math.sqrt(_pullDistance * height)),
          _glowSize.value);
    _displacementTarget = crossAxisOffset / crossExtent;
    if (_displacementTarget != _displacement) {
      if (!_displacementTicker.isTicking) {
        assert(_displacementTickerLastElapsed == null);
        _displacementTicker.start();
      }
    } else {
      _displacementTicker.stop();
      _displacementTickerLastElapsed = null;
    }
    _glowController.duration = _pullTime;
    if (_state != _GlowState.pull) {
      _glowController.forward(from: 0.0);
      _state = _GlowState.pull;
    } else {
      if (!_glowController.isAnimating) {
        assert(_glowController.value == 1.0);
        notifyListeners();
      }
    }
    _pullRecedeTimer = Timer(_pullHoldTime, () => _recede(_pullDecayTime));
  }

  void scrollEnd() {
    if (_state == _GlowState.pull) _recede(_recedeTime);
  }

  void _changePhase(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    switch (_state) {
      case _GlowState.absorb:
        _recede(_recedeTime);
        break;
      case _GlowState.recede:
        _state = _GlowState.idle;
        _pullDistance = 0.0;
        break;
      case _GlowState.pull:
      case _GlowState.idle:
        break;
    }
  }

  void _recede(Duration duration) {
    if (_state == _GlowState.recede || _state == _GlowState.idle) return;
    _pullRecedeTimer?.cancel();
    _pullRecedeTimer = null;
    _glowOpacityTween
      ..begin = _glowOpacity.value
      ..end = _recedeEndOpacity;
    _glowSizeTween
      ..begin = _glowSize.value
      ..end = 0.0;
    _glowController
      ..duration = duration
      ..forward(from: 0.0);
    _state = _GlowState.recede;
  }

  void _tickDisplacement(Duration elapsed) {
    if (_displacementTickerLastElapsed != null) {
      final double t = (elapsed.inMicroseconds -
              _displacementTickerLastElapsed.inMicroseconds)
          .toDouble();
      _displacement = _displacementTarget -
          (_displacementTarget - _displacement) *
              math.pow(2.0, -t / _crossAxisHalfTime.inMicroseconds);
      notifyListeners();
    }
    if (nearEqual(_displacementTarget, _displacement,
        Tolerance.defaultTolerance.distance)) {
      _displacementTicker.stop();
      _displacementTickerLastElapsed = null;
    } else {
      _displacementTickerLastElapsed = elapsed;
    }
  }

  void paint(Canvas canvas, Size size) {
    if (_glowOpacity.value == 0.0) return;
    final double baseGlowScale =
        size.width > size.height ? size.height / size.width : 1.0;
    final double radius = size.width * 3.0 / 2.0;
    final double height =
        math.min(size.height, size.width * _widthToHeightFactor);
    final double scaleY = _glowSize.value * baseGlowScale;
    final double rectWidth = _cutOffSides ? radius * 2 : size.width;
    final double rectLeft = _cutOffSides ? -radius * 0.5 : 0.0;
    final Rect rect = Rect.fromLTWH(rectLeft, 0.0, rectWidth, height);
    final Offset center =
        Offset((size.width / 2.0) * (0.5 + _displacement), height - radius);
    final Paint paint = Paint()..color = color.withOpacity(_glowOpacity.value);
    canvas
      ..save()
      ..scale(1.0, scaleY)
      ..clipRect(rect)
      ..drawCircle(center, radius, paint)
      ..restore();
  }
}

class _PositionedGlowingOverscrollIndicatorPainter extends CustomPainter {
  _PositionedGlowingOverscrollIndicatorPainter({
    this.leadingOffset = 0.0,
    this.trailingOffset = 0.0,
    this.leadingController,
    this.trailingController,
    this.axisDirection,
    Listenable repaint,
  }) : super(
          repaint: repaint,
        );

  final double leadingOffset;
  final double trailingOffset;
  final _ExtendedGlowController leadingController;
  final _ExtendedGlowController trailingController;
  final AxisDirection axisDirection;

  static const double piOver2 = math.pi / 2.0;

  void _paintSide(Canvas canvas, Size size, _ExtendedGlowController controller,
      AxisDirection axisDirection, GrowthDirection growthDirection) {
    if (controller == null) return;
    switch (
        applyGrowthDirectionToAxisDirection(axisDirection, growthDirection)) {
      case AxisDirection.up:
        canvas
          ..save()
          ..translate(0.0, leadingOffset)
          ..scale(1.0, 1.0); //grow
        controller.paint(canvas, size);
        canvas.restore();
        break;
      case AxisDirection.down:
        canvas
          ..save()
          ..translate(0.0, size.height - trailingOffset)
          ..scale(1.0, -1.0); //Grow
        controller.paint(canvas, size);
        canvas.restore();
        break;
      case AxisDirection.left:
        canvas
          ..save()
          ..rotate(piOver2)
          ..scale(1.0, -1.0)
          ..translate(0.0, trailingOffset);
        controller.paint(canvas, Size(size.height, size.width));
        canvas.restore();
        break;
      case AxisDirection.right:
        canvas
          ..save()
          ..translate(size.width - leadingOffset, 0.0)
          ..rotate(piOver2);
        controller.paint(canvas, Size(size.height, size.width));
        canvas.restore();
        break;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintSide(canvas, size, leadingController, axisDirection,
        GrowthDirection.reverse);
    _paintSide(canvas, size, trailingController, axisDirection,
        GrowthDirection.forward);
  }

  @override
  bool shouldRepaint(_PositionedGlowingOverscrollIndicatorPainter oldDelegate) {
    return oldDelegate.leadingController != leadingController ||
        oldDelegate.trailingController != trailingController;
  }
}

class PositionedOverscrollIndicatorNotification extends Notification
    with ViewportNotificationMixin {
  PositionedOverscrollIndicatorNotification({
    @required this.leading,
  });

  final bool leading;
  bool _accepted = true;

  void disallowGlow() {
    _accepted = false;
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('side: ${leading ? "leading edge" : "trailing edge"}');
  }
}

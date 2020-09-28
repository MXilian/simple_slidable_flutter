import 'package:flutter/material.dart';
import 'package:simple_slidable/slide_controller.dart';

class Slidable extends StatefulWidget {
  final Widget child;
  /// Slide menu
  final Widget actions;
  /// Minimum shift percentage (from 0 to 1) at which the slide will be completed
  /// (default - 0.3)
  final double minShiftPercent;
  /// Maximum possible slide percentage (from 0 to 1).
  /// Default value: 0.9 (i.e. 10% of the parent will remain visible at full shift)
  final double percentageBias;
  final SlideController controller;
  /// Duration of slide animation
  final int animationDuration;
  final Function onPress;
  /// If true, the slide menu will automatically close when the parent scrolls
  final bool closeOnScroll;

  Slidable({
    @required this.child,
    @required this.actions,
    this.minShiftPercent = 0.3,
    this.percentageBias = 0.9,
    this.controller,
    this.animationDuration = 100,
    this.onPress,
    this.closeOnScroll = true,
  });

  @override
  _SlidableState createState() => _SlidableState();
}

class _SlidableState extends State<Slidable> with TickerProviderStateMixin {
  double offsetPercent = 1.0;
  bool isAnimationOn = false;
  Animation animation;
  SlideController slideController;
  AnimationController animationController;
  ScrollPosition _scrollPosition;

  bool get isShifted => slideController.isOpened;

  @override
  void initState() {
    slideController = widget.controller ?? SlideController();
    animationController = AnimationController(vsync: this,
        duration: Duration(milliseconds: widget.animationDuration));
    slideController.setOpen = _open;
    slideController.setClose = _close;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    removeScrollListener();
    addScrollListener();
    super.didChangeDependencies();
  }

  /// Open slide menu
  void _open() {
    animationController.reset();
    setState(() {
      animation = Tween(
        begin: offsetPercent != 0.0 ? offsetPercent : 1.0,
        end: 0.0,
      ).animate(animationController);
      isAnimationOn = true;
    });
    animationController.forward();
  }

  /// Close slide menu
  void _close() {
    animationController.reset();
    setState(() {
      animation = Tween(
        begin: offsetPercent != 1.0 ? offsetPercent : 0.0,
        end: 1.0,
      ).animate(animationController);
      isAnimationOn = true;
    });
    animationController.forward();
  }

  void addScrollListener() {
    if (widget.closeOnScroll) {
      _scrollPosition = Scrollable.of(context)?.position;
      if (_scrollPosition != null)
        _scrollPosition.isScrollingNotifier.addListener(scrollListener);
    }
  }

  void scrollListener() {
    if (widget.closeOnScroll == false || _scrollPosition == null)
      return;
    if (_scrollPosition.isScrollingNotifier.value && slideController.isOpened) {
      slideController.close();
    }
  }

  void removeScrollListener() {
    if (_scrollPosition != null) {
      _scrollPosition.isScrollingNotifier.removeListener(scrollListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double _maxWidth = constraints.maxWidth + constraints.maxWidth * widget.percentageBias;

        return GestureDetector(
          onTap: widget.onPress ?? () {},
          onHorizontalDragStart: (DragStartDetails details) {
            isAnimationOn = false;
            animationController.reset();
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (details.localPosition.dx < constraints.maxWidth &&
                details.localPosition.dx > 0) {
              setState(() {
                offsetPercent =
                    details.localPosition.dx / constraints.maxWidth;
              });
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if ((offsetPercent >= 1.0 - widget.minShiftPercent && isShifted == false) ||
                (offsetPercent >= widget.minShiftPercent && isShifted == true))
                slideController.close();
            else
                slideController.open();
          },
          child: ClipRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: OverflowBox(
              alignment: Alignment.centerRight,
              maxHeight: constraints.maxHeight,
              maxWidth: _maxWidth,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) => Transform.translate(
                  offset: Offset(isAnimationOn
                      ? constraints.maxWidth * widget.percentageBias * animation.value
                      : constraints.maxWidth * widget.percentageBias * offsetPercent, 0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 100,
                        child: widget.child,
                      ),
                      Expanded(
                        flex: (widget.percentageBias * 100).toInt(),
                        child: widget.actions,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    removeScrollListener();
    super.dispose();
  }
}
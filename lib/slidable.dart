import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:simple_slidable/cubit/slidecontroller_cubit.dart';
import 'package:supercharged/supercharged.dart';

class Slidable extends StatelessWidget {
  final Widget child;

  /// Slide menu on the left
  // Если null, значит slideMenuL == slideMenuR
  // Если slideMenuL отсутствует, можно передать пустой SizedBox()
  final Widget slideMenuL;

  /// Slide menu on the right
  // Если null, значит slideMenuR == slideMenuL
  // Если slideMenuR отсутствует, можно передать пустой SizedBox()
  final Widget slideMenuR;

  /// Minimum shift percentage (from 0 to 1) at which the slide will be completed
  /// (default - 0.3)
  final double minShiftPercent;

  /// Maximum possible slide percentage (from 0 to 1).
  /// Default value: 0.9 (i.e. 10% of the parent will remain visible at full shift)
  final double percentageBias;

  /// Duration of slide animation (in milliseconds)
  final int animationDuration;
  final Function onPressed;

  /// If true, the slide menu will automatically close when the parent scrolls.
  /// Required scrollController!
  final bool closeOnScroll;

  /// If the widget does not respond to the parent scrollable
  /// (this happens if the scrollable is not a direct parent),
  /// then you should additionally give access to scrollController
  final ScrollController scrollController;

  /// The factor at which the widget shift is ahead of the cursor/finger shift
  ///  (relieves the user of having to shift the widget over a long distance
  ///  to see the slide menu)
  final double cursorOvertaking;
  final Function onSlideCallback;

  /// The millisecond`s count after which the slide menu will automatically close
  /// (if 0, then the automatic closing will not occur)
  final int millisecondsToClose;

  Slidable({
    @required this.child,
    this.slideMenuL,
    this.slideMenuR,
    this.minShiftPercent = 0.2,
    this.percentageBias = 0.9,
    SlideControllerCubit controller,
    this.animationDuration = 200,
    this.onPressed,
    this.closeOnScroll = true,
    this.scrollController,
    this.cursorOvertaking = 1.4,
    this.onSlideCallback,
    this.millisecondsToClose = 0,
    Key key,
  }) : super(key: key) {
    controller?.reinitCubit(
      animationDuration: animationDuration,
      leftSlideMenu: slideMenuL,
      rightSlideMenu: slideMenuR,
      millisecondsToClose: millisecondsToClose,
      onSlideCallback: onSlideCallback,
      closeOnScroll: closeOnScroll,
      scrollController: scrollController,
      cursorOvertaking: cursorOvertaking,
      minShiftPercent: minShiftPercent,
    );
    _controllersBox.add(controller ??
        SlideControllerCubit(
          animationDuration: animationDuration,
          leftSlideMenu: slideMenuL,
          rightSlideMenu: slideMenuR,
          millisecondsToClose: millisecondsToClose,
          onSlideCallback: onSlideCallback,
          closeOnScroll: closeOnScroll,
          scrollController: scrollController,
          cursorOvertaking: cursorOvertaking,
          minShiftPercent: minShiftPercent,
        ));
  }

  final List<SlideControllerCubit> _controllersBox = [];

  SlideControllerCubit get controller => _controllersBox[0];

  /// If true, then "slideMenuL" will be equal to "slideMenuR"
  bool get isLeftEqualsRight => slideMenuL == null || slideMenuR == null;

  bool get isShifted => isOpenedLeftMenu || isOpenedRightMenu;
  bool get isOpenedLeftMenu => controller.state.isOpenedLeftMenu;
  bool get isOpenedRightMenu => controller.state.isOpenedRightMenu;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SlideControllerCubit>(
      create: (context) => controller,
      child: BlocBuilder<SlideControllerCubit, SlideControllerState>(
        builder: (context, state) {
          if (state.isReady != true)
            return Container(
              key: state.globalKey,
              child: child,
            );
          else
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.0,
                  key: state.globalKey,
                  child: child,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onPressed ?? () {},
                  onHorizontalDragStart: controller.onHorizontalDragStart,
                  onHorizontalDragUpdate: controller.onHorizontalDragUpdate,
                  onHorizontalDragEnd: controller.onHorizontalDragEnd,
                  child: SizedBox(
                    width: state.widgetWidthVisible,
                    height: state.widgetHeight,
                    // Обрезаем виджет, чтобы был виден только child (без слайд меню)
                    child: ClipRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      // Добавиаемся, чтобы обрезанные slide-меню были поверх основного контента
                      // (т.е., чтобы не смещали его)
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        maxHeight: state.widgetHeight,
                        maxWidth: state.widgetWidthFull,
                        child: CustomAnimation<double>(
                          control: state.animationControl,
                          duration: Duration(milliseconds: animationDuration),
                          tween: (state.animBegin).tweenTo(state.animEnd),
                          builder: (context, child, value) {
                            if (state.animationControl !=
                                CustomAnimationControl.STOP)
                            return Transform.translate(
                              offset: Offset(
                                state.offsetBase + value,
                                0,
                              ),
                              child: child,
                            );
                            else
                              return Transform.translate(
                                offset: Offset(
                                  state.offsetBase + state.offsetXActual,
                                  0,
                                ),
                                child: child,
                              );
                          },
                          child: Row(
                            children: [
                              if (state.leftSlideMenu != null)
                                Expanded(
                                  flex: (percentageBias * 100).toInt(),
                                  child: state.leftSlideMenu,
                                ),
                              Expanded(
                                flex: 100,
                                child: child,
                              ),
                              if (state.rightSlideMenu != null)
                                Expanded(
                                  flex: (percentageBias * 100).toInt(),
                                  child: state.rightSlideMenu,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
        },
      ),
    );
  }
}

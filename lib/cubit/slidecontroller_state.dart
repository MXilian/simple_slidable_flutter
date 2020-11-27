part of 'slidecontroller_cubit.dart';

class SlideControllerState {
  final bool isOpenedLeftMenu;
  final bool isOpenedRightMenu;
  final Widget leftSlideMenu;
  final Widget rightSlideMenu;
  final bool rightMenuIsDefault;
  final ScrollPosition scrollPosition;
  final CustomAnimationControl animationControl;
  final double animBegin;
  final double animEnd;
  final int animationDuration;
  final double dragStart;
  final double dragDelta;
  final double offsetBase;
  final double offsetXSaved;
  final double offsetXActual;
  final double maxDragForRightMenu;
  final double maxDragForLeftMenu;
  final GlobalKey globalKey;
  final bool isReady;
  final double widgetWidthVisible;
  final double widgetWidthFull;
  final double widgetHeight;

  SlideControllerState({
    this.isOpenedLeftMenu = false,
    this.isOpenedRightMenu = false,
    this.leftSlideMenu,
    this.rightSlideMenu,
    this.rightMenuIsDefault = true,
    this.scrollPosition,
    this.animationControl = CustomAnimationControl.STOP,
    this.animationDuration = 0,
    this.animBegin = 0,
    this.animEnd = 0,
    this.dragStart = 0,
    this.dragDelta = 0,
    this.offsetBase = 0,
    this.offsetXSaved = 0,
    this.offsetXActual = 0,
    this.maxDragForRightMenu = 0,
    this.maxDragForLeftMenu = 0,
    this.globalKey,
    this.isReady = false,
    this.widgetWidthVisible = 0,
    this.widgetWidthFull = 0,
    this.widgetHeight = 0,
  });

  bool get isShifted => isOpenedLeftMenu || isOpenedRightMenu;

  SlideControllerState _update({
    bool isOpenedLeftMenu,
    bool isOpenedRightMenu,
    Widget leftSlideMenu,
    Widget rightSlideMenu,
    bool rightMenuIsDefault,
    ScrollPosition scrollPosition,
    CustomAnimationControl animationControl,
    int animationDuration,
    double animBegin,
    double animEnd,
    double dragStart,
    double dragDelta,
    double offsetBase,
    double offsetXSaved,
    double offsetXActual,
    double maxDragForRightMenu,
    double maxDragForLeftMenu,
    GlobalKey globalKey,
    bool isReady,
    double widgetWidthVisible,
    double widgetWidthFull,
    double widgetHeight,
  }) =>
      SlideControllerState(
        isOpenedLeftMenu: isOpenedLeftMenu ?? this.isOpenedLeftMenu,
        isOpenedRightMenu: isOpenedRightMenu ?? this.isOpenedRightMenu,
        leftSlideMenu: leftSlideMenu ?? this.leftSlideMenu,
        rightSlideMenu: rightSlideMenu ?? this.rightSlideMenu,
        rightMenuIsDefault: rightMenuIsDefault ?? this.rightMenuIsDefault,
        scrollPosition: scrollPosition ?? this.scrollPosition,
        animationControl: animationControl ?? this.animationControl,
        animationDuration: animationDuration ?? this.animationDuration,
        animBegin: animBegin ?? this.animBegin,
        animEnd: animEnd ?? this.animEnd,
        dragStart: dragStart ?? this.dragStart,
        dragDelta: dragDelta ?? this.dragDelta,
        offsetBase: offsetBase ?? this.offsetBase,
        offsetXSaved: offsetXSaved ?? this.offsetXSaved,
        offsetXActual: offsetXActual ?? this.offsetXActual,
        maxDragForRightMenu: maxDragForRightMenu ?? this.maxDragForRightMenu,
        maxDragForLeftMenu: maxDragForLeftMenu ?? this.maxDragForLeftMenu,
        globalKey: globalKey ?? this.globalKey,
        isReady: isReady ?? this.isReady,
        widgetWidthVisible: widgetWidthVisible ?? this.widgetWidthVisible,
        widgetWidthFull: widgetWidthFull ?? this.widgetWidthFull,
        widgetHeight: widgetHeight ?? this.widgetHeight,
      );
}

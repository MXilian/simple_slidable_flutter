import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:simple_slidable/utils.dart'; 

part 'slidecontroller_state.dart';

class SlideControllerCubit extends Cubit<SlideControllerState> {
  SlideControllerCubit({
    int animationDuration = 0,
    Widget leftSlideMenu,
    Widget rightSlideMenu,
    int millisecondsToClose = 0,
    Function() onSlideCallback,
    bool closeOnScroll = true,
    ScrollController scrollController,
    double percentageBias = 0.9,
    double cursorOvertaking = 1.4,
    double minShiftPercent = 0.2,
  }) : super(SlideControllerState()) {
    reinitCubit(
      animationDuration: animationDuration,
      leftSlideMenu: leftSlideMenu,
      rightSlideMenu: rightSlideMenu,
      millisecondsToClose: millisecondsToClose,
      onSlideCallback: onSlideCallback,
      closeOnScroll: closeOnScroll,
      scrollController: scrollController,
      percentageBias: percentageBias,
      cursorOvertaking: cursorOvertaking,
      minShiftPercent: minShiftPercent,
    );
  }

  int _millisecondsToClose;
  Function() _onSlideCallback;
  bool _closeOnScroll;
  ScrollController _scrollController;
  double _percentageBias;
  double _cursorOvertaking;
  double _minShiftPercent;

  bool get isShifted => state.isShifted;

  final GlobalKey _globalKey = GlobalKey();

  DebounceAction _debounce;
  final DebounceAction _debounceRebuild = DebounceAction(milliseconds: 50);

  void reinitCubit({
    int animationDuration = 0,
    Widget leftSlideMenu,
    Widget rightSlideMenu,
    int millisecondsToClose = 0,
    Function() onSlideCallback,
    bool closeOnScroll = true,
    ScrollController scrollController,
    double percentageBias = 0.9,
    double cursorOvertaking = 1.4,
    double minShiftPercent = 0.2,
  }) {
    print('reinitCubit');
    _millisecondsToClose = millisecondsToClose;
    _onSlideCallback = onSlideCallback;
    _closeOnScroll = closeOnScroll;
    _scrollController = scrollController;
    _percentageBias = percentageBias;
    _cursorOvertaking = cursorOvertaking;
    _minShiftPercent = minShiftPercent;
    if (_SlideControllerManager().all.contains(this) == false)
      _SlideControllerManager().all.add(this);
    emit(state._update(
      rightMenuIsDefault: rightSlideMenu != null,
      leftSlideMenu: leftSlideMenu ?? rightSlideMenu ?? SizedBox(),
      rightSlideMenu: rightSlideMenu ?? leftSlideMenu ?? SizedBox(),
      animationDuration: animationDuration,
      globalKey: _globalKey,
    ));
    _debounce = DebounceAction(milliseconds: millisecondsToClose);
    rebuildState();
  }

  void rebuildState() {
    print('rebuildState');
    _debounceRebuild?.destroyTimer();
    _debounceRebuild.run(() {
      removeScrollListener();
      addScrollListener();

      RenderBox renderBox = _globalKey.currentContext?.findRenderObject();
      double width = renderBox?.size?.width ?? 0;
      double fullWidth = renderBox?.size?.width ?? 0;
      double height = renderBox?.size?.height ?? 0;
      double maxDragForRightMenu = 0.0;
      double maxDragForLeftMenu = 0.0;
      double offsetBase = 0.0;

      // Если правое слайд-меню не пустое, тогда увеличиваем ширину виджета
      // на размер правого слайд-меню, а также устанавливаем новое значение для
      // максимального сдвига вправо.
      if (state.rightSlideMenu != null) {
        fullWidth += width * _percentageBias;
        maxDragForRightMenu = 0.0 - width * _percentageBias;
      }

      // Если левое слайд-меню не пустое, тогда увеличиваем ширину виджета
      // на размер левого слайд-меню, а также устанавливаем новые значения для
      // максимального сдвига вправо и начального смещения виджета.
      if (state.leftSlideMenu != null) {
        fullWidth += width * _percentageBias;
        maxDragForLeftMenu = width * _percentageBias;
        offsetBase = 0.0 - maxDragForLeftMenu;
      }

      emit(state._update(
        widgetWidthFull: fullWidth,
        widgetWidthVisible: width,
        widgetHeight: height,
        maxDragForRightMenu: maxDragForRightMenu,
        maxDragForLeftMenu: maxDragForLeftMenu,
        offsetBase: offsetBase,
        isReady: true,
      ));
    });
  }

  void openSlideMenu() =>
      state.rightMenuIsDefault ? openRightSlideMenu() : openLeftSlideMenu();

  void openLeftSlideMenu() {
    emit(state._update(
      isOpenedLeftMenu: true,
      isOpenedRightMenu: false,
      animationControl: CustomAnimationControl.PLAY_FROM_START,
      animBegin: state.offsetXSaved,
      animEnd: state.maxDragForLeftMenu,
      offsetXSaved: state.maxDragForLeftMenu,
    ));
    _SlideControllerManager().all.forEach((element) {
      if (element.state.isShifted == true && element.hashCode != this.hashCode)
        element.closeSlideMenu();
    });
    _onSlideCallback?.call();
    if (_millisecondsToClose > 0) _autoClose();
  }

  void openRightSlideMenu() {
    emit(state._update(
      isOpenedLeftMenu: false,
      isOpenedRightMenu: true,
      animationControl: CustomAnimationControl.PLAY_FROM_START,
      animBegin: state.offsetXSaved,
      animEnd: state.maxDragForRightMenu,
      offsetXSaved: state.maxDragForRightMenu,
    ));
    _SlideControllerManager().all.forEach((element) {
      if (element.state.isShifted == true && element.hashCode != this.hashCode)
        element.closeSlideMenu();
    });
    _onSlideCallback?.call();
    if (_millisecondsToClose > 0) _autoClose();
  }

  void closeSlideMenu() {
    emit(state._update(
      isOpenedLeftMenu: false,
      isOpenedRightMenu: false,
      animationControl: CustomAnimationControl.PLAY_FROM_START,
      animBegin: state.offsetXSaved,
      animEnd: 0.0,
      offsetXSaved: 0.0,
    ));
  }

  void _autoClose() {
    _debounce?.destroyTimer();
    _debounce.run(() {
      closeSlideMenu();
    });
  }

  /// Closing all slide menus at screen scrolling
  void _scrollListener() {
    if (_closeOnScroll == false || state.scrollPosition == null) return;
    if (state.scrollPosition.isScrollingNotifier.value && state.isShifted) {
      closeSlideMenu();
    }
  }

  void addScrollListener() {
    if (_closeOnScroll) {
      if (_scrollController != null)
        emit(state._update(scrollPosition: _scrollController.position));
      if (state.scrollPosition != null)
        state.scrollPosition.isScrollingNotifier.addListener(_scrollListener);
    }
  }

  void removeScrollListener() {
    if (state.scrollPosition != null) {
      state.scrollPosition.isScrollingNotifier.removeListener(_scrollListener);
    }
  }

  void onHorizontalDragStart(DragStartDetails details) {
    emit(state._update(
      animationControl: CustomAnimationControl.STOP,
      dragStart: details.localPosition.dx,
      offsetXActual: state.offsetXSaved,
    ));
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    // Определяем текущую позицию курсора
    double dragCurrent = details.localPosition.dx;
    // Вычисляем, на сколько пикселей произошло отклонение относительно
    // начальной позиции курсора
    double dragDelta = dragCurrent - state.dragStart;
    // Смещение виджета опережает смещение курсора (для удобства пользователя)
    double offsetXActual = state.offsetXSaved + dragDelta * _cursorOvertaking;
    // Не даем виджету выйти за пределы минимального и максимального
    // смещений, установленных ранее
    if (offsetXActual > state.maxDragForLeftMenu)
      offsetXActual = state.maxDragForLeftMenu;
    if (offsetXActual < state.maxDragForRightMenu)
      offsetXActual = state.maxDragForRightMenu;
    emit(state._update(
      dragDelta: dragDelta,
      offsetXActual: offsetXActual,
    ));
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    // Минимальный порог сдвига в пикселях
    double minShift = state.widgetWidthVisible * _minShiftPercent;
    double offsetXSaved = state.offsetXActual;

    emit(state._update(
      offsetXSaved: offsetXSaved,
    ));

    // Если значение отрицательное, значит виджет сдвинут влево
    // (т.е. юзер видит правое слайд-меню)
    if (state.offsetXActual < 0) {
      // Если правое слайд меню закрыто, и юзер не дотянул виджет до минимального порога
      // либо правое слайд меню открыто, и юзер перетянул виджет дальше минимального порога,
      // тогда возвращаем виджет в исходное положение, а иначе - показываем правое меню
      if ((!state.isShifted && offsetXSaved.abs() < minShift) ||
          (state.isShifted &&
              state.widgetWidthVisible + offsetXSaved >= minShift))
        closeSlideMenu();
      else
        openRightSlideMenu();

      // Если значение положительное, значит виджет сдвинут вправо
      // (т.е. юзер видит левое слайд-меню)
    } else if (state.offsetXActual >= 0) {
      // Если левое слайд меню закрыто, и юзер не дотянул виджет до минимального порога
      // либо левое слайд меню открыто, и юзер перетянул виджет дальше минимального порога,
      // тогда возвращаем виджет в исходное положение, а иначе - показываем левое меню
      if ((!state.isShifted && offsetXSaved.abs() < minShift) ||
          (state.isShifted &&
              state.widgetWidthVisible - offsetXSaved >= minShift))
        closeSlideMenu();
      else
        openLeftSlideMenu();
    }
  }

  @override
  Future<void> close() {
    if (_SlideControllerManager().all.contains(this))
      _SlideControllerManager().all.remove(this);
    _debounce?.destroyTimer();
    _debounceRebuild?.destroyTimer();
    removeScrollListener();
    return super.close();
  }
}

/// Class to store current controllers
/// (to close all other slidables when you open one)
class _SlideControllerManager {
  _SlideControllerManager._internal();
  static final _SlideControllerManager _instance =
      _SlideControllerManager._internal();

  factory _SlideControllerManager() {
    return _instance;
  }

  final List<SlideControllerCubit> all = [];
}

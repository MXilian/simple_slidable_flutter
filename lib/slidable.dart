import 'package:flutter/material.dart';
import 'package:simple_slidable/slide_controller.dart';
import 'package:simple_slidable/utils.dart';

// Sorry for my English :)

class Slidable extends StatefulWidget {
  final Widget child;

  /// Slide menu on the left
  final Widget slideMenuL;

  /// Slide menu on the right
  final Widget slideMenuR;

  /// If true, then "slideMenuL" will be equal to "slideMenuR"
  /// (and then you can transfer one of these parameters only)
  final bool isLeftEqualsRight;

  /// Minimum shift percentage (from 0 to 1) at which the slide will be completed
  /// (default - 0.3)
  final double minShiftPercent;

  /// Maximum possible slide percentage (from 0 to 1).
  /// Default value: 0.9 (i.e. 10% of the parent will remain visible at full shift)
  final double percentageBias;
  final SlideController controller;

  /// Duration of slide animation (in milliseconds)
  final int animationDuration;
  final Function onPressed;

  /// If true, the slide menu will automatically close when the parent scrolls
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
    this.isLeftEqualsRight = false,
    this.minShiftPercent = 0.2,
    this.percentageBias = 0.9,
    this.controller,
    this.animationDuration = 200,
    this.onPressed,
    this.closeOnScroll = true,
    this.scrollController,
    this.cursorOvertaking = 1.4,
    this.onSlideCallback,
    this.millisecondsToClose = 0,
    Key key,
  }) : super(key: key);

  @override
  _SlidableState createState() => _SlidableState();
}

class _SlidableState extends State<Slidable> with TickerProviderStateMixin {
  SlideController slideController;
  ScrollPosition _scrollPosition;
  bool isAnimationOn = false;
  Animation animation;
  AnimationController animationController;

  /// Left slide-menu
  Widget leftMenu;

  /// Right slide-menu
  Widget rightMenu;

  /// Starting cursor/finger position when dragging
  double dragStart = 0;

  /// Cursor offset (not widget) relating of start position
  double dragDelta = 0;

  /// Widget`s start position
  double _offsetBase = 0;

  /// Saved widget offset
  double offsetXSaved = 0;

  /// Current widget offset
  double offsetXActual = 0;

  /// Maximum widget shift to the left
  double _maxDragFromRightToLeft = 0;

  /// Maximum widget shift to the right
  double _maxDragFromLeftToRight = 0;

  final GlobalKey _key = GlobalKey();
  RenderBox _box;

  @override
  void initState() {
    slideController = widget.controller ?? SlideController();
    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration));
    // Если активна опция isLeftEqualsRight, то делаем оба слайд-меню одинаковыми
    // (в противном случае активно будет только то, которое не равно null)
    if (widget.isLeftEqualsRight) {
      leftMenu = widget.slideMenuL ?? widget.slideMenuR;
      rightMenu = leftMenu;
    } else {
      leftMenu = widget.slideMenuL;
      rightMenu = widget.slideMenuR;
    }
    // Настраиваем контроллер
    slideController.setSlideToLeft = _slideToLeft;
    slideController.setSlideToRight = _slideToRight;
    slideController.setClose = _close;
    slideController.rightMenuIsDefault = rightMenu != null;
    // При первом построении виджета будет вызван коллбэк afterBuild
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    removeScrollListener();
    addScrollListener();
    super.didChangeDependencies();
  }

  /// Is slide-menu opened now
  bool get isOpened => slideController.isOpened;

  /// Open right slide menu
  void _slideToLeft() {
    animationController.reset();
    setState(() {
      animation = Tween(
        begin: offsetXSaved,
        end: _maxDragFromRightToLeft,
      ).animate(animationController);
      // Включаем анимацию, чтобы она могла быть запущена
      // (т.к. при манипуляциях юзера с виджетом она отключается)
      isAnimationOn = true;
    });
    animationController.forward();
    // Сохраняем конечную точку анимации в качестве смещения виджета
    offsetXSaved = _maxDragFromRightToLeft;
    widget.onSlideCallback?.call();
    if (widget.millisecondsToClose > 0) _autoClose();
  }

  /// Open left slide menu
  void _slideToRight() {
    animationController.reset();
    setState(() {
      animation = Tween(
        begin: offsetXSaved,
        end: _maxDragFromLeftToRight,
      ).animate(animationController);
      // Включаем анимацию, чтобы она могла быть запущена
      // (т.к. при манипуляциях юзера с виджетом она отключается)
      isAnimationOn = true;
    });
    animationController.forward();
    // Сохраняем конечную точку анимации в качестве смещения виджета
    offsetXSaved = _maxDragFromLeftToRight;
    widget.onSlideCallback?.call();
    if (widget.millisecondsToClose > 0) _autoClose();
  }

  DebounceAction _debounce;
  void _autoClose() {
    _debounce = DebounceAction(milliseconds: widget.millisecondsToClose);
    _debounce.run(() {
      slideController.close();
    });
  }

  /// Close slide menu
  void _close() {
    animationController.reset();
    setState(() {
      animation = Tween(
        begin: offsetXSaved,
        end: 0.0,
      ).animate(animationController);
      isAnimationOn = true;
    });
    animationController.forward();
    // Обнуляем сохраненное смещение виджета, т.к. он был возвращен в исходное положение
    offsetXSaved = 0.0;
  }

  void addScrollListener() {
    if (widget.closeOnScroll) {
      // Находим скролл-контроллер
      if (widget.scrollController != null)
        _scrollPosition = widget.scrollController.position;
      else
        _scrollPosition = Scrollable.of(context)?.position;
      // Ставим листенер, чтобы при скролле закрывать все slidable
      if (_scrollPosition != null)
        _scrollPosition.isScrollingNotifier.addListener(scrollListener);
    }
  }

  /// Closing all slide menus at screen scrolling
  void scrollListener() {
    if (widget.closeOnScroll == false || _scrollPosition == null) return;
    if (_scrollPosition.isScrollingNotifier.value && slideController.isOpened) {
      slideController.close();
    }
  }

  void removeScrollListener() {
    if (_scrollPosition != null) {
      _scrollPosition.isScrollingNotifier.removeListener(scrollListener);
    }
  }

  void afterBuild() {
    setState(() {
      // Сохраняем _box, из которого будут браться размеры для виджета
      // при его перестроении
      _box = _key.currentContext.findRenderObject();
    });
  }

  @override
  Widget build(BuildContext context) {
    // При первом построении виджета сохраняем key.
    // После завешения билда будет вызван коллбэк afterBuild,
    // который извлечет из ключа RenderBox и сохранит его в _box.
    if (_box == null) {
      return Container(
        key: _key,
        child: widget.child,
      );
    }

    // Общая ширина виджета (видимая часть + слайд меню)
    double _maxWidth = _box.size.width;
    // Если левое слайд-меню не пустое, тогда увеличиваем ширину виджета
    // на размер левого слайд-меню, а также устанавливаем новые значения для
    // максимального сдвига вправо и начального смещения виджета.
    if (leftMenu != null) {
      _maxWidth += _box.size.width * widget.percentageBias;
      _maxDragFromLeftToRight = _box.size.width * widget.percentageBias;
      _offsetBase = 0 - _maxDragFromLeftToRight;
    }
    // Если правое слайд-меню не пустое, тогда увеличиваем ширину виджета
    // на размер правого слайд-меню, а также устанавливаем новое значение для
    // максимального сдвига вправо.
    if (rightMenu != null) {
      _maxWidth += _box.size.width * widget.percentageBias;
      _maxDragFromRightToLeft = 0 - _box.size.width * widget.percentageBias;
    }

    return SizedBox(
      height: _box.size.height,
      width: _box.size.width,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onPressed ?? () {},
        onHorizontalDragStart: (DragStartDetails details) {
          // Деактивируем анимацию, чтобы не мешала перетаскиванию
          isAnimationOn = false;
          animationController.reset();
          // Сохраняем начальную позицию курсора
          dragStart = details.localPosition.dx;
          // Достаем сохраненное в памяти текущее смещение виджета,
          // чтобы относительно него вести дальнейшие вычисления
          offsetXActual = offsetXSaved;
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          // Определяем текущую позицию курсора
          double dragCurrent = details.localPosition.dx;
          // Вычисляем, на сколько пикселей произошло отклонение относительно
          // начальной позиции курсора
          dragDelta = dragCurrent - dragStart;
          // Обновляем текущее смещение виджета в соответствии со смещением курсора
          setState(() {
            // Смещение виджета опережает смещение курсора (для удобства пользователя)
            offsetXActual = offsetXSaved + dragDelta * widget.cursorOvertaking;
            // Не даем виджету выйти за пределы минимального и максимального
            // смещений, установленных ранее
            if (offsetXActual > _maxDragFromLeftToRight)
              offsetXActual = _maxDragFromLeftToRight;
            if (offsetXActual < _maxDragFromRightToLeft)
              offsetXActual = _maxDragFromRightToLeft;
          });
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          // Сохраняем текущее смещение виджета в памяти
          offsetXSaved = offsetXActual;
          // Минимальный порог сдвига в пикселях
          double minShift = _box.size.width * widget.minShiftPercent;

          // Если значение отрицательное, значит виджет сдвинут влево
          // (т.е. юзер видит правое слайд-меню)
          if (offsetXActual < 0) {
            // Если правое слайд меню закрыто, и юзер не дотянул виджет до минимального порога
            // либо правое слайд меню открыто, и юзер перетянул виджет дальше минимального порога,
            // тогда возвращаем виджет в исходное положение, а иначе - показываем правое меню
            if ((!isOpened && offsetXSaved.abs() < minShift) ||
                (isOpened && _box.size.width + offsetXSaved >= minShift))
              slideController.close();
            else
              slideController.slideToLeft();

            // Если значение положительное, значит виджет сдвинут вправо
            // (т.е. юзер видит левое слайд-меню)
          } else if (offsetXActual >= 0) {
            // Если левое слайд меню закрыто, и юзер не дотянул виджет до минимального порога
            // либо левое слайд меню открыто, и юзер перетянул виджет дальше минимального порога,
            // тогда возвращаем виджет в исходное положение, а иначе - показываем левое меню
            if ((!isOpened && offsetXSaved.abs() < minShift) ||
                (isOpened && _box.size.width - offsetXSaved >= minShift))
              slideController.close();
            else
              slideController.slideToRight();
          }
        },
        // Обрезаем виджет, чтобы был виден только child (без слайд меню)
        child: ClipRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          // Добавиаемся, чтобы обрезанные slide-меню были поверх основного контента
          // (т.е., чтобы не смещали его)
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxHeight: _box.size.height,
            maxWidth: _maxWidth,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                    isAnimationOn
                    // При активной анимации смещаем виджет на значение анимации
                        ? _offsetBase + animation.value
                    // При неактивной анимации смещаем виджет относительно положения курсора
                        : _offsetBase + offsetXActual,
                    0),
                child: Row(
                  children: [
                    if (leftMenu != null)
                      Expanded(
                        flex: (widget.percentageBias * 100).toInt(),
                        child: leftMenu,
                      ),
                    Expanded(
                      flex: 100,
                      child: widget.child,
                    ),
                    if (rightMenu != null)
                      Expanded(
                        flex: (widget.percentageBias * 100).toInt(),
                        child: rightMenu,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.destroyTimer();
    animationController?.dispose();
    slideController?.dispose();
    // _boxController?.close();
    removeScrollListener();
    super.dispose();
  }
}

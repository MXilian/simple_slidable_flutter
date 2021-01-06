/// Class to store current controllers
/// (to close all other slidables when you open one)
class _SlideControllerManager {
  _SlideControllerManager._internal();
  static final _SlideControllerManager _instance = _SlideControllerManager._internal();

  factory _SlideControllerManager() {
    return _instance;
  }

  final List<SlideController> all = [];
}


class SlideController {
  SlideController() {
    if (_SlideControllerManager().all.contains(this) == false)
      _SlideControllerManager().all.add(this);
  }

  Function _slideToLeft, _slideToRight, _reset;
  bool _shiftedToLeft = false;
  bool _shiftedToRight = false;
  bool _rightMenuIsDefault;

  set setSlideToLeft(Function f) => _slideToLeft = f;
  set setSlideToRight(Function f) => _slideToRight = f;
  set setClose(Function f) => _reset = f;
  /// This option determines which slide menu will open through the controller as default
  set rightMenuIsDefault(bool value) => _rightMenuIsDefault = value;

  /// Open default slide menu
  open() => _rightMenuIsDefault ? slideToLeft() : slideToRight();

  /// Close slide menu
  close() {
    _shiftedToLeft = false;
    _shiftedToRight = false;
    _reset?.call();
  }

  /// Open right slide-menu
  slideToLeft() {
    _SlideControllerManager().all.forEach((element) {
      if (element.isOpened == true && element.hashCode != this.hashCode)
        element.close();
    });
    _shiftedToLeft = true;
    _slideToLeft?.call();
  }

  /// Open left slide-menu
  slideToRight() {
    _SlideControllerManager().all.forEach((element) {
      if (element.isOpened == true && element.hashCode != this.hashCode)
        element.close();
    });
    _shiftedToRight = true;
    _slideToRight?.call();
  }

  /// Get current state (opened/closed)
  bool get isOpened => _shiftedToLeft || _shiftedToRight;

  bool get isShiftedToLeft => _shiftedToLeft;
  bool get isShiftedToRight => _shiftedToRight;

  void dispose() {
    if (_SlideControllerManager().all.contains(this))
      _SlideControllerManager().all.remove(this);
  }
}
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

  Function _toOpen, _toClose;
  bool _shifted = false;

  set setOpen(Function f) => _toOpen = f;
  set setClose(Function f) => _toClose = f;

  /// Close slide menu
  close() {
    _shifted = false;
    _toClose?.call();
  }

  /// Open slide menu
  open() {
    // send close() call to other instances of SlideController()
    _SlideControllerManager().all.forEach((element) {
      if (element.isOpened == true)
        element.close();
    });
    _shifted = true;
    _toOpen?.call();
  }

  /// Get current state (opened/closed)
  bool get isOpened => _shifted;

  void dispose() {
    if (_SlideControllerManager().all.contains(this))
      _SlideControllerManager().all.remove(this);
  }
}
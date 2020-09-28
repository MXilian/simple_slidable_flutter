class SlideController {
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
    _shifted = true;
    _toOpen?.call();
  }

  /// Get current state (opened/closed)
  bool get isOpened => _shifted;
}
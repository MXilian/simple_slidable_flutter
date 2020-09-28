class SlidableController {
  Function _toOpen, _toClose;
  bool _shifted = false;

  set setOpen(Function f) => _toOpen = f;
  set setClose(Function f) => _toClose = f;

  /// Закрыть меню slidable
  close() {
    _shifted = false;
    _toClose?.call();
  }

  /// Открыть меню slidable
  open() {
    _shifted = true;
    _toOpen?.call();
  }

  /// Получаем текущее состояние попапа (открыт/закрыт)
  bool get isOpened => _shifted;
}
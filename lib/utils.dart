import 'dart:async';

import 'package:flutter/foundation.dart';

class DebounceAction {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  DebounceAction({ this.milliseconds });

  run(VoidCallback action) {
    destroyTimer();

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  destroyTimer() {
    _timer?.cancel();
  }
}
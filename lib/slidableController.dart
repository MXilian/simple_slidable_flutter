import 'dart:async';

import 'package:flutter/widgets.dart';

class SlidableController {
  final StreamController _wgContr = StreamController<RenderBox>();
  Stream<RenderBox> get stream => _wgContr.stream;

  final GlobalKey key = GlobalKey();

  RenderBox get _currentBox => key.currentContext?.findRenderObject();

  void init() {
    stream.listen((box) {
      if (box == null) 
        _wgContr.add(_currentBox);
    });
  }
}

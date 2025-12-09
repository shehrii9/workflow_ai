import 'package:flutter/material.dart';

class CanvasController {
  final TransformationController transformationController;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;

  CanvasController() : transformationController = TransformationController();

  double get scale => _scale;
  Offset get panOffset => _panOffset;

  void updateScale(double newScale) {
    _scale = newScale.clamp(0.5, 3.0);
    _updateTransformation();
  }

  void updatePan(Offset offset) {
    _panOffset = offset;
    _updateTransformation();
  }

  void panBy(Offset delta) {
    _panOffset = _panOffset + delta;
    _updateTransformation();
  }

  void reset() {
    _scale = 1.0;
    _panOffset = Offset.zero;
    transformationController.value = Matrix4.identity();
  }

  void _updateTransformation() {
    transformationController.value = Matrix4.identity()
      ..translate(_panOffset.dx, _panOffset.dy)
      ..scale(_scale);
  }

  void dispose() {
    transformationController.dispose();
  }
}


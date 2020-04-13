import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Given a canvas and an image, determine what size the image should be to be
// contained in but not exceed the canvas while preserving its aspect ratio.
class ZoomableImage extends StatefulWidget {
  final ui.Image image;
  final double maxScale;
  final double minScale;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Widget placeholder;
  final Function(int x, int y) userTouchedImageAt;

  ZoomableImage(
    this.image, {
    Key key,
    @deprecated double scale,

    /// Maximum ratio to blow up image pixels. A value of 2.0 means that the

    /// a single device pixel will be rendered as up to 4 logical pixels.

    this.maxScale = 2.0,
    this.minScale = 0.0,
    this.onTap,
    this.backgroundColor = Colors.black,

    /// Placeholder widget to be used while [image] is being resolved.

    this.placeholder,
    this.userTouchedImageAt,
  }) : super(key: key);

  @override
  _ZoomableImageState createState() => new _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset = new Offset(0, 0); // where the top left corner of the image is drawn
  double _previousScale;
  double _scale = 1; // multiplier applied to scale the full image
  Orientation _previousOrientation;
  Size _canvasSize;

  get _image => widget.image;
  get _imageSize => new Size(_image.width.toDouble(), _image.height.toDouble());
  Function() _handleDoubleTap(BuildContext ctx) {
    return () {
      resetScaleAndPosition();
    };
  }

  void resetScaleAndPosition() {
    setState(() {
      _scale = _canvasSize.width / _imageSize.width;
      _offset = calculateOffset(new Offset(0, 0));
    });
  }

  void _handleScaleStart(ScaleStartDetails d) {
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  Offset calculateOffset(Offset offset) {
    double x = offset.dx > 0 ? 0 : offset.dx;
    x = _image.width * _scale + x < _canvasSize.width ? _canvasSize.width - _image.width * _scale : x;

    double y = offset.dy;
    if (_image.height * _scale > _canvasSize.height) {
      y = y > 0 ? 0 : y;
      y = _image.height * _scale + y < _canvasSize.height ? _canvasSize.height - _image.height * _scale : y;
    } else {
      y = (_image.height * _scale - _canvasSize.height).abs() / 2;
    }
    return new Offset(x, y);
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    double calculatedScale = _previousScale * d.scale;

    if (calculatedScale > widget.maxScale || calculatedScale < widget.minScale) {
      return;
    }

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset = (_startingFocalPoint - _previousOffset) / _previousScale;
    final Offset calculatedOffset = d.focalPoint - normalizedOffset * calculatedScale;
    _offset = calculateOffset(calculatedOffset);

    //ensure that scaled image is not smaller than canvas
    _scale = _imageSize.width * calculatedScale < _canvasSize.width ? _canvasSize.width / _imageSize.width : calculatedScale;
    _scale = _scale > 1 ? 1 : _scale;

    setState(() {});
  }

  @override
  Widget build(BuildContext ctx) {
    Widget paintWidget() {
      return new CustomPaint(
        child: new Container(color: widget.backgroundColor),
        foregroundPainter: new _ZoomableImage2Painter(
          image: _image,
          offset: _offset,
          scale: _scale,
        ),
      );
    }

    if (widget.image == null) {
      return widget.placeholder ?? Center(child: CircularProgressIndicator());
    }

    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;

      if (orientation != _previousOrientation) {
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;

        if (_image != null) {
          _scale = _canvasSize.width / _imageSize.width;
          _offset = calculateOffset(new Offset(0, 0));
        }
      }

      return new GestureDetector(
        child: paintWidget(),
        onTap: widget.onTap,
        onDoubleTap: _handleDoubleTap(ctx),
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onTapUp: _handleOnTapUp,
      );
    });
  }

  void _handleOnTapUp(TapUpDetails details) {
    if (widget.userTouchedImageAt != null) widget.userTouchedImageAt((_offset.dx.abs() + details.localPosition.dx) ~/ _scale, (_offset.dy.abs() + details.localPosition.dy) ~/ _scale);
  }
}

class _ZoomableImage2Painter extends CustomPainter {
  _ZoomableImage2Painter({ui.Image image, this.offset, this.scale}) {
    _image = image;
  }

  ui.Image _image;
  final Offset offset;
  final double scale;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Size imageSize = new Size(_image.width.toDouble(), _image.height.toDouble());

    Size targetSize = imageSize * (scale ?? 1);

    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: _image,
      fit: BoxFit.fill,
    );
  }

  @override
  bool shouldRepaint(_ZoomableImage2Painter old) {
    return old._image != _image || old.offset != offset || old.scale != scale;
  }
}

import 'package:covid19_4ro/Model/pageDescription.dart';
import 'package:flutter/cupertino.dart';

import 'Model/location.dart';

class TanslateCoordinates {
  final PageDescription _pageDescription;

  TanslateCoordinates(this._pageDescription);

  PageDescription getPageDescription(double canvasWidth, double canvasHeight) {
    var xRatio = canvasWidth / _pageDescription.canvasSize.width;
    var yRatio = canvasHeight / _pageDescription.canvasSize.height;

    var pageTopLeftLocation = new Location(_pageDescription.pageTopLeftLocation.x * xRatio, _pageDescription.pageTopLeftLocation.y * yRatio);
    var pageTopRightLocation = new Location(_pageDescription.pageTopRightLocation.x * xRatio, _pageDescription.pageTopRightLocation.y * yRatio);
    var pageBottomLeftLocation = new Location(_pageDescription.pageBottomLeftLocation.x * xRatio, _pageDescription.pageBottomLeftLocation.y * yRatio);
    var pageBottomRightLocation = new Location(_pageDescription.pageBottomRightLocation.x * xRatio, _pageDescription.pageBottomRightLocation.y * yRatio);
    var canvasSize = new Size(canvasWidth, canvasHeight);
    return new PageDescription(pageTopLeftLocation, pageTopRightLocation, pageBottomLeftLocation, pageBottomRightLocation, canvasSize, rotationAngle: _pageDescription.rotationAngle);
  }
}

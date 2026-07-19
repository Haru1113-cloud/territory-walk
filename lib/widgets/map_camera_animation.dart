// このファイルの役割:
// flutter_mapのMapControllerを、瞬間移動ではなくアニメーション付きで
// 目的地までパン/ズームさせるためのヘルパー関数。

import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

Future<void> animatedMapMove(
  MapController mapController,
  TickerProvider vsync, {
  required latlng.LatLng destination,
  required double destinationZoom,
}) {
  final camera = mapController.camera;
  final latTween = Tween<double>(
    begin: camera.center.latitude,
    end: destination.latitude,
  );
  final lngTween = Tween<double>(
    begin: camera.center.longitude,
    end: destination.longitude,
  );
  final zoomTween = Tween<double>(begin: camera.zoom, end: destinationZoom);

  final animationController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: vsync,
  );
  final animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOutCubic,
  );

  animation.addListener(() {
    mapController.move(
      latlng.LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
      zoomTween.evaluate(animation),
    );
  });

  final completer = Completer<void>();
  animationController.addStatusListener((status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      animationController.dispose();
      if (!completer.isCompleted) completer.complete();
    }
  });

  animationController.forward();
  return completer.future;
}

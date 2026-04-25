import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';

enum MapViewVariant { navigation, selectLocation }

class MapView extends StatefulWidget {
  final MapViewVariant variant;
  const MapView({super.key, this.variant = MapViewVariant.navigation});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Map<String, BitmapDescriptor> _foodPins = {};
  BitmapDescriptor? _orangeDotPin;
  BitmapDescriptor? _blueDotPin;
  Set<Marker> _markers = const {};

  static const CameraPosition _navigationCamera = CameraPosition(
    target: LatLng(37.55645, 126.92245),
    zoom: 16.35,
  );

  static const CameraPosition _selectLocationCamera = CameraPosition(
    target: LatLng(37.55600, 126.92180),
    zoom: 15.95,
  );

  @override
  void initState() {
    super.initState();
    _initializeMarkerDescriptors();
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _rebuildMarkers();
    }
  }

  Future<void> _initializeMarkerDescriptors() async {
    final foodAssets = <String>[
      'assets/images/food_jokbal.png',
      'assets/images/food_tteokbokki.png',
      'assets/images/banner_food.png',
      'assets/images/food_cafe.png',
    ];

    final descriptors = <String, BitmapDescriptor>{};
    for (final asset in foodAssets) {
      descriptors[asset] = await _buildFoodPinDescriptor(asset);
    }

    final orangeDot = await _buildSmallDotDescriptor(
      fillColor: AppColors.accentOrange,
      radius: 7.5,
    );
    final blueDot = await _buildSmallDotDescriptor(
      fillColor: const Color(0xFF46A8FF),
      radius: 6.5,
      withShadow: false,
    );

    if (!mounted) return;

    setState(() {
      _foodPins = descriptors;
      _orangeDotPin = orangeDot;
      _blueDotPin = blueDot;
    });
    _rebuildMarkers();
  }

  void _rebuildMarkers() {
    if (!mounted) return;
    if (_foodPins.isEmpty || _orangeDotPin == null || _blueDotPin == null) {
      return;
    }

    final markers = widget.variant == MapViewVariant.navigation
        ? _buildNavigationMarkers()
        : _buildSelectLocationMarkers();

    setState(() {
      _markers = markers;
    });
  }

  Set<Marker> _buildNavigationMarkers() {
    return {
      Marker(
        markerId: const MarkerId('food_1'),
        position: const LatLng(37.55588, 126.92055),
        icon: _foodPins['assets/images/food_cafe.png']!,
        anchor: const Offset(0.5, 0.96),
      ),
      Marker(
        markerId: const MarkerId('food_2'),
        position: const LatLng(37.55658, 126.92135),
        icon: _foodPins['assets/images/food_jokbal.png']!,
        anchor: const Offset(0.5, 0.96),
      ),
      Marker(
        markerId: const MarkerId('food_3'),
        position: const LatLng(37.55628, 126.92255),
        icon: _foodPins['assets/images/food_tteokbokki.png']!,
        anchor: const Offset(0.5, 0.96),
      ),
      Marker(
        markerId: const MarkerId('food_4'),
        position: const LatLng(37.55598, 126.92305),
        icon: _foodPins['assets/images/banner_food.png']!,
        anchor: const Offset(0.5, 0.96),
      ),
      Marker(
        markerId: const MarkerId('dot_orange_1'),
        position: const LatLng(37.55695, 126.92070),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('dot_orange_2'),
        position: const LatLng(37.55700, 126.92112),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('dot_blue_1'),
        position: const LatLng(37.55610, 126.92118),
        icon: _blueDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  Set<Marker> _buildSelectLocationMarkers() {
    return {
      Marker(
        markerId: const MarkerId('select_dot_1'),
        position: const LatLng(37.55655, 126.92090),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('select_dot_2'),
        position: const LatLng(37.55593, 126.92215),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('select_dot_3'),
        position: const LatLng(37.55522, 126.92142),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: widget.variant == MapViewVariant.navigation
          ? _navigationCamera
          : _selectLocationCamera,
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      myLocationEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: true,
      indoorViewEnabled: false,
      padding: EdgeInsets.zero,
    );
  }

  Future<BitmapDescriptor> _buildFoodPinDescriptor(
      String imageAssetPath) async {
    try {
      final ui.Image sourceImage = await _loadAssetImage(
        imageAssetPath,
        targetSize: 88,
      );

      const double canvasWidth = 104;
      const double canvasHeight = 124;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const center = Offset(52, 46);

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.19)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
      final pinShadowPath = _buildPinPath().shift(const Offset(0, 2));
      canvas.drawPath(pinShadowPath, shadowPaint);

      final pinPaint = Paint()..color = AppColors.accentOrange;
      canvas.drawPath(_buildPinPath(), pinPaint);

      canvas.drawCircle(center, 30.8, Paint()..color = Colors.white);
      canvas.drawCircle(center, 29.2, Paint()..color = AppColors.accentOrange);
      canvas.drawCircle(center, 27.0, Paint()..color = Colors.white);

      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: 25.7)),
      );
      paintImage(
        canvas: canvas,
        rect: Rect.fromCircle(center: center, radius: 25.7),
        image: sourceImage,
        fit: BoxFit.cover,
      );
      canvas.restore();

      final image = await recorder
          .endRecording()
          .toImage(canvasWidth.toInt(), canvasHeight.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      }
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Future<BitmapDescriptor> _buildSmallDotDescriptor({
    required Color fillColor,
    required double radius,
    bool withShadow = true,
  }) async {
    try {
      const double canvasSize = 34;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const center = Offset(canvasSize / 2, canvasSize / 2);

      if (withShadow) {
        canvas.drawCircle(
          center + const Offset(0, 1),
          radius + 1.8,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.16)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
        );
      }

      canvas.drawCircle(center, radius + 2, Paint()..color = Colors.white);
      canvas.drawCircle(center, radius, Paint()..color = fillColor);

      final image = await recorder
          .endRecording()
          .toImage(canvasSize.toInt(), canvasSize.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      }
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Path _buildPinPath() {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(12, 8, 80, 78),
          const Radius.circular(24),
        ),
      )
      ..moveTo(44, 84)
      ..lineTo(60, 84)
      ..lineTo(52, 102)
      ..close();
    return path;
  }

  Future<ui.Image> _loadAssetImage(String assetPath,
      {required int targetSize}) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize,
      targetHeight: targetSize,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

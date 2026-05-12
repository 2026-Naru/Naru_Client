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

// 마커 descriptor를 앱 생명주기 동안 한 번만 생성
class _MarkerCache {
  static Map<String, BitmapDescriptor>? foodPins;
  static BitmapDescriptor? orangeDotPin;
  static BitmapDescriptor? blueDotPin;
  static bool isLoading = false;
}

const _minimalMapStyle = '''[
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]}
]''';

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
    // 캐시가 있으면 바로 사용
    if (_MarkerCache.foodPins != null &&
        _MarkerCache.orangeDotPin != null &&
        _MarkerCache.blueDotPin != null) {
      if (!mounted) return;
      setState(() {
        _foodPins = _MarkerCache.foodPins!;
        _orangeDotPin = _MarkerCache.orangeDotPin;
        _blueDotPin = _MarkerCache.blueDotPin;
      });
      _rebuildMarkers();
      return;
    }

    if (_MarkerCache.isLoading) return;
    _MarkerCache.isLoading = true;

    const foodAssets = <String>[
      'assets/images/food_jokbal.png',
      'assets/images/food_tteokbokki.png',
      'assets/images/banner_food.png',
      'assets/images/food_cafe.png',
    ];

    // 모든 descriptor를 병렬로 생성
    final results = await Future.wait([
      ...foodAssets.map(_buildFoodPinDescriptor),
      _buildSmallDotDescriptor(fillColor: AppColors.accentOrange, radius: 7.5),
      _buildSmallDotDescriptor(
          fillColor: const Color(0xFF46A8FF), radius: 6.5),
    ]);

    _MarkerCache.isLoading = false;

    if (!mounted) return;

    final descriptors = <String, BitmapDescriptor>{};
    for (int i = 0; i < foodAssets.length; i++) {
      descriptors[foodAssets[i]] = results[i];
    }
    _MarkerCache.foodPins = descriptors;
    _MarkerCache.orangeDotPin = results[foodAssets.length];
    _MarkerCache.blueDotPin = results[foodAssets.length + 1];

    setState(() {
      _foodPins = _MarkerCache.foodPins!;
      _orangeDotPin = _MarkerCache.orangeDotPin;
      _blueDotPin = _MarkerCache.blueDotPin;
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
        anchor: const Offset(0.5, 0.93),
      ),
      Marker(
        markerId: const MarkerId('food_2'),
        position: const LatLng(37.55658, 126.92135),
        icon: _foodPins['assets/images/food_jokbal.png']!,
        anchor: const Offset(0.5, 0.93),
      ),
      Marker(
        markerId: const MarkerId('food_3'),
        position: const LatLng(37.55628, 126.92255),
        icon: _foodPins['assets/images/food_tteokbokki.png']!,
        anchor: const Offset(0.5, 0.93),
      ),
      Marker(
        markerId: const MarkerId('food_4'),
        position: const LatLng(37.55598, 126.92305),
        icon: _foodPins['assets/images/banner_food.png']!,
        anchor: const Offset(0.5, 0.93),
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
      style: _minimalMapStyle,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      myLocationEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      padding: EdgeInsets.zero,
    );
  }

  Future<BitmapDescriptor> _buildFoodPinDescriptor(String imageAssetPath) async {
    try {
      final sourceImage = await _loadAssetImage(imageAssetPath, targetSize: 56);

      const double canvasWidth = 40;
      const double canvasHeight = 52;
      const innerRect = Rect.fromLTWH(5.6, 5.6, 28.8, 28.8);
      final innerRRect =
          RRect.fromRectAndRadius(innerRect, const Radius.circular(9.4));

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final pinPath = _buildPinPath();

      canvas.drawPath(pinPath, Paint()..color = AppColors.accentOrange);
      canvas.drawRRect(innerRRect, Paint()..color = const Color(0xFFE9E9E9));

      canvas.save();
      canvas.clipRRect(innerRRect);
      paintImage(
        canvas: canvas,
        rect: innerRect,
        image: sourceImage,
        fit: BoxFit.cover,
      );
      canvas.restore();

      final image = await recorder
          .endRecording()
          .toImage(canvasWidth.toInt(), canvasHeight.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      }
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Future<BitmapDescriptor> _buildSmallDotDescriptor({
    required Color fillColor,
    required double radius,
  }) async {
    try {
      const double canvasSize = 34;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const center = Offset(canvasSize / 2, canvasSize / 2);

      canvas.drawCircle(center, radius + 2, Paint()..color = Colors.white);
      canvas.drawCircle(center, radius, Paint()..color = fillColor);

      final image = await recorder
          .endRecording()
          .toImage(canvasSize.toInt(), canvasSize.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      }
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Path _buildPinPath() {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.5, 2.5, 35, 35),
          const Radius.circular(10.8),
        ),
      )
      ..moveTo(15, 34.5)
      ..lineTo(25, 34.5)
      ..lineTo(20, 55.0)
      ..close();
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

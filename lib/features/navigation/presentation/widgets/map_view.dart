import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../likes/presentation/pages/store_detail_page.dart';

enum MapViewVariant { navigation, selectLocation, selectedStore }

class MapView extends StatefulWidget {
  final MapViewVariant variant;
  final ValueChanged<MapStorePin>? onStorePinTap;
  final String? selectedStoreImagePath;

  const MapView({
    super.key,
    this.variant = MapViewVariant.navigation,
    this.onStorePinTap,
    this.selectedStoreImagePath,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

// 마커 descriptor를 앱 생명주기 동안 한 번만 생성
class _MarkerCache {
  static Map<String, BitmapDescriptor>? foodPins;
  static BitmapDescriptor? orangeDotPin;
  static BitmapDescriptor? blueDotPin;
  static int? foodPinDesignVersion;
  static bool isLoading = false;
}

const _foodPinDesignVersion = 4;

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  Map<String, BitmapDescriptor> _foodPins = {};
  BitmapDescriptor? _orangeDotPin;
  BitmapDescriptor? _blueDotPin;
  Set<Marker> _markers = const {};
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _myLocationEnabled = false;
  bool _isResolvingLocation = false;
  int _locationRetryCount = 0;
  Timer? _locationRetryTimer;
  static const CameraPosition _navigationCamera = CameraPosition(
    target: LatLng(37.55645, 126.92245),
    zoom: 16.35,
  );

  static const CameraPosition _selectLocationCamera = CameraPosition(
    target: LatLng(37.55600, 126.92180),
    zoom: 15.95,
  );

  static const CameraPosition _selectedStoreCamera = CameraPosition(
    target: LatLng(37.55600, 126.92180),
    zoom: 15.95,
  );

  static const _navigationStorePins = [
    MapStorePin(
      markerId: 'food_cafe',
      imagePath: 'assets/navigation/szimpatikus_hero.png',
      latitudeDelta: -0.00057,
      longitudeDelta: -0.00190,
      storeName: 'SZIMPATIKUSSEOUL STATION',
      storeSubtitle: 'an atmospheric meal enjoyed by the barrel',
      preset: StoreDetailPreset.cafe,
      rating: '5.0',
      deliveryTime: '15min',
    ),
    MapStorePin(
      markerId: 'food_jokbal',
      imagePath: 'assets/images/food_jokbal.png',
      latitudeDelta: 0.00013,
      longitudeDelta: -0.00110,
      storeName: 'Simin Jokbal Bossam Sillim',
      storeSubtitle: 'Korean jokbal and bossam',
      preset: StoreDetailPreset.jokbal,
      rating: '5.0',
      deliveryTime: '40min',
    ),
    MapStorePin(
      markerId: 'food_tteokbokki',
      imagePath: 'assets/images/food_tteokbokki.png',
      latitudeDelta: -0.00017,
      longitudeDelta: 0.00010,
      storeName: 'Yupki Ddukbokki Sillim',
      storeSubtitle: 'Spicy Korean street food',
      preset: StoreDetailPreset.tteokbokki,
      rating: '4.9',
      deliveryTime: '20min',
    ),
    MapStorePin(
      markerId: 'food_jjukkumi',
      imagePath: 'assets/images/banner_food.png',
      latitudeDelta: -0.00047,
      longitudeDelta: 0.00060,
      storeName: 'Seoul Bangyidong Jjukkumi House',
      storeSubtitle: 'Bold, spicy, and full of flavor',
      preset: StoreDetailPreset.jjukkumi,
      rating: '4.8',
      deliveryTime: '30min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMarkerDescriptors();
    if (widget.variant != MapViewVariant.selectedStore) {
      _initializeCurrentLocation();
    }
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant ||
        oldWidget.selectedStoreImagePath != widget.selectedStoreImagePath) {
      _rebuildMarkers();
      _moveCameraToActiveLocation();
    }
    if (oldWidget.variant == MapViewVariant.selectedStore &&
        widget.variant != MapViewVariant.selectedStore &&
        _currentLocation == null) {
      _initializeCurrentLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationRetryTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.variant != MapViewVariant.selectedStore &&
        _currentLocation == null) {
      _initializeCurrentLocation();
    }
  }

  Future<void> _initializeCurrentLocation() async {
    if (_isResolvingLocation) return;
    _isResolvingLocation = true;

    final position = await _determineCurrentPosition();
    _isResolvingLocation = false;
    if (!mounted) return;

    if (position == null) {
      _scheduleLocationRetry();
      return;
    }

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _myLocationEnabled = true;
      _locationRetryCount = 0;
    });
    _locationRetryTimer?.cancel();
    _rebuildMarkers();
    _moveCameraToActiveLocation();
  }

  void _scheduleLocationRetry() {
    if (_locationRetryCount >= 8 || _locationRetryTimer?.isActive == true) {
      return;
    }

    _locationRetryCount += 1;
    _locationRetryTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _currentLocation == null) {
        _initializeCurrentLocation();
      }
    });
  }

  Future<Position?> _determineCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) return lastKnownPosition;

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _moveCameraToActiveLocation() async {
    if (widget.variant == MapViewVariant.selectedStore) return;

    final controller = _mapController;
    final target = _currentLocation;
    if (controller == null || target == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: widget.variant == MapViewVariant.navigation ? 16.35 : 15.95,
        ),
      ),
    );
  }

  Future<void> _initializeMarkerDescriptors() async {
    // 캐시가 있으면 바로 사용
    if (_MarkerCache.foodPins != null &&
        _MarkerCache.foodPinDesignVersion == _foodPinDesignVersion &&
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
      'assets/navigation/szimpatikus_hero.png',
    ];

    // 모든 descriptor를 병렬로 생성
    final results = await Future.wait([
      ...foodAssets.map(_buildFoodPinDescriptor),
      _buildSmallDotDescriptor(fillColor: AppColors.accentOrange, radius: 7.5),
      _buildSmallDotDescriptor(fillColor: const Color(0xFF46A8FF), radius: 6.5),
    ]);

    _MarkerCache.isLoading = false;

    if (!mounted) return;

    final descriptors = <String, BitmapDescriptor>{};
    for (int i = 0; i < foodAssets.length; i++) {
      descriptors[foodAssets[i]] = results[i];
    }
    _MarkerCache.foodPins = descriptors;
    _MarkerCache.foodPinDesignVersion = _foodPinDesignVersion;
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

    final Set<Marker> markers;
    switch (widget.variant) {
      case MapViewVariant.navigation:
        markers = _buildNavigationMarkers();
        break;
      case MapViewVariant.selectLocation:
        markers = _buildSelectLocationMarkers();
        break;
      case MapViewVariant.selectedStore:
        markers = _buildSelectedStoreMarkers();
        break;
    }

    setState(() {
      _markers = markers;
    });
  }

  Set<Marker> _buildNavigationMarkers() {
    final center = _currentLocation ?? _navigationCamera.target;

    return _navigationStorePins
        .map(
          (pin) => Marker(
            markerId: MarkerId(pin.markerId),
            position: _offset(
              center,
              pin.latitudeDelta,
              pin.longitudeDelta,
            ),
            icon: _foodPins[pin.imagePath]!,
            anchor: const Offset(0.5, 0.96),
            onTap: () => _handleStorePinTap(pin),
          ),
        )
        .toSet();
  }

  void _handleStorePinTap(MapStorePin pin) {
    final handler = widget.onStorePinTap;
    if (handler != null) {
      handler(pin);
      return;
    }
    _openStoreDetail(pin);
  }

  void _openStoreDetail(MapStorePin pin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailPage(
          storeName: pin.storeName,
          storeSubtitle: pin.storeSubtitle,
          heroImagePath: pin.imagePath,
          logoImagePath: pin.imagePath,
          preset: pin.preset,
          rating: pin.rating,
          deliveryTime: pin.deliveryTime,
          bottomNavIndex: 1,
        ),
      ),
    );
  }

  Set<Marker> _buildSelectedStoreMarkers() {
    final markerImagePath =
        widget.selectedStoreImagePath ?? _navigationStorePins.first.imagePath;
    final markerIcon = _foodPins[markerImagePath] ??
        _foodPins[_navigationStorePins.first.imagePath] ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

    return {
      Marker(
        markerId: const MarkerId('selected_store'),
        position: _offset(_selectedStoreCamera.target, -0.00016, -0.00010),
        icon: markerIcon,
        anchor: const Offset(0.5, 0.96),
      ),
    };
  }

  Set<Marker> _buildSelectLocationMarkers() {
    final center = _currentLocation ?? _selectLocationCamera.target;

    return {
      Marker(
        markerId: const MarkerId('select_dot_1'),
        position: _offset(center, 0.00055, -0.00090),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('select_dot_2'),
        position: _offset(center, -0.00007, 0.00035),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('select_dot_3'),
        position: _offset(center, -0.00078, -0.00038),
        icon: _orangeDotPin!,
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  LatLng _offset(LatLng origin, double latitudeDelta, double longitudeDelta) {
    return LatLng(
      origin.latitude + latitudeDelta,
      origin.longitude + longitudeDelta,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition(),
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      myLocationEnabled:
          widget.variant == MapViewVariant.selectLocation && _myLocationEnabled,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      trafficEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      padding: EdgeInsets.zero,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onMapCreated: (controller) {
        _mapController = controller;
        _moveCameraToActiveLocation();
      },
    );
  }

  CameraPosition _initialCameraPosition() {
    switch (widget.variant) {
      case MapViewVariant.navigation:
        return _navigationCamera;
      case MapViewVariant.selectLocation:
        return _selectLocationCamera;
      case MapViewVariant.selectedStore:
        return _selectedStoreCamera;
    }
  }

  Future<BitmapDescriptor> _buildFoodPinDescriptor(
      String imageAssetPath) async {
    try {
      final sourceImage = await _loadAssetImage(imageAssetPath, targetSize: 72);

      const double canvasWidth = 54;
      const double canvasHeight = 63;
      const innerRect = Rect.fromLTWH(10, 8, 34, 34);
      final innerRRect =
          RRect.fromRectAndRadius(innerRect, const Radius.circular(11));

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final pinPath = _buildPinPath();

      canvas.drawPath(pinPath, Paint()..color = AppColors.accentOrange);

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
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
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
          const Rect.fromLTWH(4, 3, 46, 46),
          const Radius.circular(17),
        ),
      )
      ..moveTo(18, 44)
      ..lineTo(36, 44)
      ..lineTo(27, 61)
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

class MapStorePin {
  final String markerId;
  final String imagePath;
  final double latitudeDelta;
  final double longitudeDelta;
  final String storeName;
  final String storeSubtitle;
  final StoreDetailPreset preset;
  final String rating;
  final String deliveryTime;

  const MapStorePin({
    required this.markerId,
    required this.imagePath,
    required this.latitudeDelta,
    required this.longitudeDelta,
    required this.storeName,
    required this.storeSubtitle,
    required this.preset,
    required this.rating,
    required this.deliveryTime,
  });
}

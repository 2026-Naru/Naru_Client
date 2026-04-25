import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';

// _RouteResult is passed from results page — redeclare here as a simple data class
class RouteInfo {
  final bool isBest;
  final String timeRange;
  final String transport;
  final String duration;

  const RouteInfo({
    required this.isBest,
    required this.timeRange,
    required this.transport,
    required this.duration,
  });
}

class NavigationRouteDetailPage extends StatefulWidget {
  final String from;
  final String to;
  final dynamic route; // accepts _RouteResult from results page

  const NavigationRouteDetailPage({
    super.key,
    required this.from,
    required this.to,
    required this.route,
  });

  @override
  State<NavigationRouteDetailPage> createState() =>
      _NavigationRouteDetailPageState();
}

class _NavigationRouteDetailPageState
    extends State<NavigationRouteDetailPage> {
  Set<Marker> _markers = const {};
  Set<Polyline> _polylines = const {};
  bool _liked = false;

  // Signiel Seoul & Gyeongbokgung Palace coords
  static const _fromLatLng = LatLng(37.5125, 127.1025);
  static const _toLatLng = LatLng(37.5796, 126.9770);

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    final fromPin = await _buildPin(Colors.orange);
    final toPin = await _buildPin(Colors.orange);
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('from'),
          position: _fromLatLng,
          icon: fromPin,
          infoWindow: InfoWindow(title: widget.from),
        ),
        Marker(
          markerId: const MarkerId('to'),
          position: _toLatLng,
          icon: toPin,
          infoWindow: InfoWindow(title: widget.to),
        ),
      };
      _polylines = {
        const Polyline(
          polylineId: PolylineId('route'),
          points: [_fromLatLng, _toLatLng],
          color: Colors.orange,
          width: 4,
        ),
      };
    });
  }

  Future<BitmapDescriptor> _buildPin(Color color) async {
    const size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    // Circle body
    canvas.drawCircle(const Offset(size / 2, size / 2 - 8), 18, paint);
    // Triangle tail
    final path = Path()
      ..moveTo(size / 2 - 8, size / 2 + 8)
      ..lineTo(size / 2 + 8, size / 2 + 8)
      ..lineTo(size / 2, size / 2 + 22)
      ..close();
    canvas.drawPath(path, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  String get _timeRange => widget.route.timeRange as String;
  String get _duration => widget.route.duration as String;
  bool get _isBest => widget.route.isBest as bool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Google Map top 42%
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.546, 127.040),
                zoom: 11.5,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          // Bottom sheet content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_isBest)
                          const Text(
                            'Best  ',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          _duration,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // From / To image cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LocationCard(
                            label: 'From',
                            sublabel: '4:38 PM ~',
                            placeName: widget.from,
                            imagePath: 'assets/images/sinielseoul.png',
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 64),
                          child: SizedBox(
                            width: 32,
                            child: Text(
                              '...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _LocationCard(
                            label: 'To',
                            sublabel: '~ 5:47 PM',
                            placeName: widget.to,
                            imagePath: 'assets/images/gyeongbokgungplace.png',
                          ),
                        ),
                        // Heart icon
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: GestureDetector(
                            onTap: () => setState(() => _liked = !_liked),
                            child: Icon(
                              _liked ? Icons.favorite : Icons.favorite_border,
                              color: _liked ? Colors.red : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "We've found the best route for you if you have a child and use a stroller.",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // Total Time section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Total Time',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _timeRange,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '₩1,750',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From ${widget.from}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.85,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF888888), Colors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              right: MediaQuery.of(context).size.width * 0.14,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'To ${widget.to}',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // Specification section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Specification',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SpecCard(
                            label: 'Number of people\nin your family',
                            value: '3',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SpecCard(
                            label: 'Price per\nperson',
                            value: '₩1,750',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SpecCard(
                            label: 'Total',
                            value: '₩5,250',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String placeName;
  final String imagePath;

  const _LocationCard({
    required this.label,
    required this.sublabel,
    required this.placeName,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  placeName,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final String label;
  final String value;

  const _SpecCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

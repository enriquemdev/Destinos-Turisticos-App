import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated banner shown when the device has no network connection.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final AnimationController _animController;
  late final Animation<double> _heightAnim;
  bool _offline = false;

  static bool _isOffline(List<ConnectivityResult> results) {
    return !results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    Connectivity().checkConnectivity().then((results) {
      if (!mounted) return;
      _setOffline(_isOffline(results));
    });
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      _setOffline(_isOffline(results));
    });
  }

  void _setOffline(bool value) {
    if (_offline == value) return;
    setState(() => _offline = value);
    if (value) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizeTransition(
          sizeFactor: _heightAnim,
          child: Material(
            color: const Color(0xFFB71C1C),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sin conexión — los datos guardados siguen disponibles',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

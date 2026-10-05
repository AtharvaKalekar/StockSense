import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/post_scan_sheet.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _laserController;
  bool _isTorchOn = false;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() => _isScanned = true);
      _showScanResultModal();
    }
  }

  void _simulateScan() {
    setState(() => _isScanned = true);
    _showScanResultModal();
  }

  void _showScanResultModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostScanSheet(
        onDismiss: () {
          setState(() => _isScanned = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => context.canPop() ? context.pop() : context.go("/dashboard"),
        ),
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              border: Border.all(color: const Color(0xFFA7F3D0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF4F46E5)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Viewfinder Section
            SizedBox(
              height: 380,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera / MobileScanner View
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Container(
                        color: const Color(0xFF0F172A),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Camera Feed Sim (Bay Interior)',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'JetBrains Mono'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Top Floating Controls Inside Viewfinder
                  Positioned(
                    top: 14,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF4F46E5), size: 16),
                              SizedBox(width: 6),
                              Text(
                                '1D / 2D DATAMATRIX',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _scannerController.toggleTorch();
                                setState(() => _isTorchOn = !_isTorchOn);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isTorchOn ? const Color(0xFFFEF3C7) : Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isTorchOn ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
                                      color: Colors.amber.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isTorchOn ? 'TORCH ON' : 'TORCH OFF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _isTorchOn ? Colors.amber.shade900 : const Color(0xFF334155),
                                        fontFamily: 'JetBrains Mono',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _scannerController.switchCamera(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.flip_camera_ios_rounded, size: 18, color: Color(0xFF334155)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reticle Box with Laser Sweep
                  SizedBox(
                    width: 250,
                    height: 230,
                    child: Stack(
                      children: [
                        // Reticle Corners
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF818CF8), width: 4),
                                left: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF818CF8), width: 4),
                                right: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(6)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF818CF8), width: 4),
                                left: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF818CF8), width: 4),
                                right: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(6)),
                            ),
                          ),
                        ),

                        // Animated Laser Beam
                        AnimatedBuilder(
                          animation: _laserController,
                          builder: (context, child) {
                            return Positioned(
                              top: _laserController.value * 220,
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.transparent, Color(0xFF38BDF8), Colors.transparent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Barcode Alignment Box Center Card
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Aligned: Bay A-14',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                        fontFamily: 'JetBrains Mono',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    10,
                                    (i) => Container(
                                      width: (i % 2 == 0) ? 3.0 : 1.5,
                                      height: 28,
                                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '||| 8824-LDR-v4 |||',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Viewfinder Bar
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.sensors_rounded, color: Color(0xFF059669), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'OPTICAL READY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.volume_up_rounded, color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'BEEP ON SCAN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Primary Scan CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _simulateScan,
                  icon: const Icon(Icons.bolt_rounded, color: Color(0xFFA5F3FC), size: 22),
                  label: const Text(
                    'SIMULATE SCAN (DEMO)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
            ),

            // Results Section Container Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PostScanSheet(
                onDismiss: () {},
                isEmbedded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

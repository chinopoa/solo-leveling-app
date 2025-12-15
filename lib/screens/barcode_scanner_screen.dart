import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/solo_leveling_theme.dart';
import '../services/nutrition_service.dart';
import 'food_detail_screen.dart';
import 'manual_entry_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final NutritionService _nutritionService = NutritionService();
  bool _isProcessing = false;
  String? _lastScannedBarcode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final barcodeValue = barcode.rawValue!;

    // Avoid processing the same barcode multiple times
    if (barcodeValue == _lastScannedBarcode) return;
    _lastScannedBarcode = barcodeValue;

    setState(() => _isProcessing = true);

    // Pause the scanner while processing
    await _controller.stop();

    // Look up the product
    final product = await _nutritionService.getProductByBarcode(barcodeValue);

    if (!mounted) return;

    if (product != null) {
      // Product found - navigate to food detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailScreen(product: product),
        ),
      );
    } else {
      // Product not found - show dialog
      _showProductNotFoundDialog(barcodeValue);
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
          ),
        ),
        title: const Text(
          'PRODUCT NOT FOUND',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barcode: $barcode',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This product was not found in the database. Would you like to enter the nutrition information manually?',
              style: TextStyle(
                color: SoloLevelingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: Text(
              'SCAN AGAIN',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualEntryScreen(barcode: barcode),
                ),
              );
            },
            child: const Text(
              'MANUAL ENTRY',
              style: TextStyle(
                color: SoloLevelingTheme.primaryCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _isProcessing = false;
      _lastScannedBarcode = null;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'SCAN PRODUCT',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: SoloLevelingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: state.torchState == TorchState.on
                      ? SoloLevelingTheme.xpGold
                      : SoloLevelingTheme.textMuted,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: SoloLevelingTheme.textMuted),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualEntryScreen(),
                ),
              );
            },
            tooltip: 'Manual Entry',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Scan overlay
          _buildScanOverlay(),

          // Processing indicator
          if (_isProcessing) _buildProcessingOverlay(),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    SoloLevelingTheme.backgroundDark.withOpacity(0.9),
                    SoloLevelingTheme.backgroundDark,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Position the barcode within the frame',
                    style: TextStyle(
                      color: SoloLevelingTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product not in database? Tap the edit icon for manual entry',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: SoloLevelingTheme.primaryCyan,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: SoloLevelingTheme.glowEffect(SoloLevelingTheme.primaryCyan),
        ),
        child: Stack(
          children: [
            // Corner accents
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(true, true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(true, false),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner(false, true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner(false, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: SoloLevelingTheme.primaryCyan, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: SoloLevelingTheme.primaryCyan, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: SoloLevelingTheme.primaryCyan, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: SoloLevelingTheme.primaryCyan, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: SoloLevelingTheme.backgroundDark.withOpacity(0.8),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: SoloLevelingTheme.primaryCyan,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'SEARCHING DATABASE...',
              style: TextStyle(
                color: SoloLevelingTheme.primaryCyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

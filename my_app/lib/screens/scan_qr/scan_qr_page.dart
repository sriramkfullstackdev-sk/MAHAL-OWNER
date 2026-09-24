import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isCameraOpen = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _openCamera() {
    setState(() {
      _isCameraOpen = true;
      _hasScanned = false;
    });
  }

  void _handleScan(BarcodeCapture capture) {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        _hasScanned = true;
        _scannerController.stop();
        Navigator.pop(context, value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Verify Customer QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previewHeight = (constraints.maxWidth * 0.9).clamp(260.0, 390.0).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF1565C0),
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verify QR Pass',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCameraOpen
                        ? 'Place the customer QR inside the frame.'
                        : 'Tap the button below to open the camera and scan the customer pass.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isCameraOpen)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: previewHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _scannerController,
                              onDetect: _handleScan,
                            ),
                            IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: previewHeight * 0.58,
                                  height: previewHeight * 0.58,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      height: previewHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF1565C0),
                          size: 72,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isCameraOpen ? null : _openCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('VERIFY QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF90A4AE),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (_isCameraOpen) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        _scannerController.toggleTorch();
                      },
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Toggle Flash'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

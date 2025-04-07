import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    controller.toggleTorch();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.first;

    setState(() => _isProcessing = true);
    controller.stop();

    final pattern = RegExp(r'^[0-9]{11}$');
    final isValid = pattern.hasMatch(barcode.rawValue ?? '');

    if (!isValid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsupported QR'),
          content: const Text('QR code must contain 11 digit number only'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.start();
                setState(() => _isProcessing = false);
              },
              child: const Text('GOT IT'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context, barcode.rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final squareSize = size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          SizedBox.expand(
            child: CustomPaint(
              painter: QrOverlayPainter(squareSize: squareSize),
            ),
          ),
          Positioned(
            top: (size.height - squareSize) / 2 + squareSize + 20,
            width: size.width,
            child: const Text(
              'Align QR code within frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrOverlayPainter extends CustomPainter {
  final double squareSize;

  QrOverlayPainter({required this.squareSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final squareRect = Rect.fromLTWH(left, top, squareSize, squareSize);

    // Draw overlay mask
    final backgroundPath = Path()..addRect(Rect.largest);
    final squarePath = Path()..addRect(squareRect);
    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      squarePath,
    );
    canvas.drawPath(combinedPath, paint);

    // Draw border
    final borderRadius = BorderRadius.circular(20);
    final borderPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(squareRect, borderRadius.topLeft),
      );
    canvas.drawRect(squareRect, borderPaint);

    // Draw corner marks
    const cornerLength = 30.0;
    const cornerWidth = 6.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    //const cornerLength = 25.0;

    // Top-left
    canvas.drawLine(
        Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + squareSize - cornerLength, top),
        Offset(left + squareSize, top), cornerPaint);
    canvas.drawLine(Offset(left + squareSize, top),
        Offset(left + squareSize, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + squareSize - cornerLength),
        Offset(left, top + squareSize), cornerPaint);
    canvas.drawLine(Offset(left, top + squareSize),
        Offset(left + cornerLength, top + squareSize), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + squareSize - cornerLength, top + squareSize),
        Offset(left + squareSize, top + squareSize), cornerPaint);
    canvas.drawLine(Offset(left + squareSize, top + squareSize - cornerLength),
        Offset(left + squareSize, top + squareSize), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

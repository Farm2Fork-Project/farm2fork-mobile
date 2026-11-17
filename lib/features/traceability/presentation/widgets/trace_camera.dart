import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import '../../data/utils/trace_id_parser.dart';

/// The callback belongs only to this dialog route. Capture can arrive while
/// its reverse transition is running after any manual dismissal.
Future<String?> showTraceCamera(
  BuildContext context, {
  Widget Function(ValueChanged<String> onScan)? cameraBuilder,
}) {
  var handled = false;
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => PopScope<String>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) handled = true;
      },
      child: Dialog(
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(
                    dialogContext,
                  ).closeButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    handled = true;
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    void accept(String value) {
                      final route = ModalRoute.of(dialogContext);
                      if (handled ||
                          route == null ||
                          !route.isCurrent ||
                          !route.isActive) {
                        return;
                      }
                      handled = true;
                      Navigator.pop(dialogContext, value);
                    }

                    return cameraBuilder?.call(accept) ??
                        TraceCamera(onScan: accept);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Mounted only while the lookup form is visible. The plugin owns foreground
/// lifecycle pause/resume; removing this widget releases the camera entirely.
class TraceCamera extends StatefulWidget {
  const TraceCamera({super.key, required this.onScan});
  final ValueChanged<String> onScan;
  @override
  State<TraceCamera> createState() => _TraceCameraState();
}

class _TraceCameraState extends State<TraceCamera> {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  String? _lastValue;
  DateTime? _lastScan;
  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _detect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      final now = DateTime.now();
      if (_lastValue == value &&
          _lastScan != null &&
          now.difference(_lastScan!) < const Duration(seconds: 3)) {
        return;
      }
      _lastValue = value;
      _lastScan = now;
      widget.onScan(value);
      if (parseTraceLink(value) != null) return;
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _detect,
          errorBuilder: (context, error) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.qrCameraUnavailable,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => IconButton.filled(
              tooltip: context.l10n.qrCameraTorch,
              onPressed:
                  state.isInitialized &&
                      state.isRunning &&
                      state.torchState != TorchState.unavailable
                  ? () async {
                      try {
                        await _controller.toggleTorch();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.qrCameraUnavailable),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flashlight_off_rounded
                    : Icons.flashlight_on_rounded,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

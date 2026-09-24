import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

typedef PhotoPick = Future<XFile?> Function(ImageSource source);

/// Downscaled so uploads stay well under the 5 MB server limit on slow
/// rural connections. Tests override this provider.
final photoPickerProvider = Provider<PhotoPick>(
  (ref) =>
      (source) => ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      ),
);

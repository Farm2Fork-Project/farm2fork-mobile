import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/locale_repository.dart';

final fontSizeControllerProvider =
    NotifierProvider<FontSizeController, double>(FontSizeController.new);

class FontSizeController extends Notifier<double> {
  static const _key = 'font_size_scale';

  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final valueStr = await storage.read(key: _key);
      if (valueStr != null) {
        final val = double.tryParse(valueStr);
        if (val != null) {
          state = val;
        }
      }
    } catch (_) {}
  }

  Future<void> setScale(double scale) async {
    state = scale;
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: _key, value: scale.toString());
    } catch (_) {}
  }
}

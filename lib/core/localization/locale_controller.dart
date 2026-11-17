import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_repository.dart';

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale>(() {
      return LocaleController();
    });

class LocaleController extends AsyncNotifier<Locale> {
  late final LocaleRepository _repository;

  @override
  Future<Locale> build() async {
    _repository = ref.watch(localeRepositoryProvider);
    // Mock builds only: `--dart-define=MOCK_LOCALE=ur` for screen reviews.
    const forced = String.fromEnvironment('MOCK_LOCALE');
    if (AppConfig.useMocks && (forced == 'en' || forced == 'ur')) {
      return Locale(forced);
    }
    final savedLocale = await _repository.getLocale();
    if (savedLocale != null && (savedLocale == 'en' || savedLocale == 'ur')) {
      return Locale(savedLocale);
    }
    return const Locale('en'); // Default fallback to English
  }

  Future<void> setLocale(Locale locale) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (locale.languageCode == 'en' || locale.languageCode == 'ur') {
        await _repository.saveLocale(locale.languageCode);
        return locale;
      }
      return const Locale('en');
    });
  }

  Future<void> toggleLocale() async {
    final current = state.value ?? const Locale('en');
    final next = current.languageCode == 'en'
        ? const Locale('ur')
        : const Locale('en');
    await setLocale(next);
  }
}

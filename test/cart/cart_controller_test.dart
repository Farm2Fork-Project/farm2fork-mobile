import 'dart:convert';
import 'dart:async';
import 'package:farm2fork_mobile/core/localization/locale_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';

const product = Product(
  id: 'p1',
  farmerId: 'farmer-1',
  name: 'Tomatoes',
  category: ProductCategory.vegetables,
  description: '',
  price: 120,
  quantity: 2.5,
  unit: ProductUnit.kg,
  farmer: FarmerSummary(
    id: 'farmer-1',
    name: '',
    farmName: 'Test farm',
    farmLocationAddress: '',
  ),
);

class SlowStorage extends FlutterSecureStorage {
  final gate = Completer<void>();
  final values = <String, String>{};
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await gate.future;
    if (value != null) values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('rapid account return waits for queued cart writes', () async {
    final storage = SlowStorage();
    final container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);
    await cart.bindUser('buyer-1');
    cart.addItem(product, quantity: 2);
    await cart.bindUser(null);
    final restoring = cart.bindUser('buyer-1');
    storage.gate.complete();
    await restoring;
    expect(container.read(cartControllerProvider).single.quantity, 2);
  });
  test(
    'cart additions and quantity edits respect stock and inactive products',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartControllerProvider.notifier);
      cart.addItem(product);
      cart.addItem(product, quantity: 10);
      expect(container.read(cartControllerProvider).single.quantity, 2);
      cart.updateQuantity(product.id, 99);
      expect(container.read(cartControllerProvider).single.quantity, 2);
      cart.updateQuantity(product.id, 1);
      expect(container.read(cartControllerProvider).single.quantity, 1);
      cart.removeItem(product.id);
      cart.addItem(product.copyWith(status: ProductStatus.inactive));
      expect(container.read(cartControllerProvider), isEmpty);
    },
  );
  test(
    'persistent carts remain scoped to the account and restore cannot overwrite a fresh edit',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'f2f.cart.v1.buyer-1': jsonEncode([
          {'product': product.toJson(), 'quantity': 2},
        ]),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartControllerProvider.notifier);
      await cart.bindUser('buyer-1');
      expect(container.read(cartControllerProvider).single.quantity, 2);
      await cart.bindUser('buyer-2');
      expect(container.read(cartControllerProvider), isEmpty);
      cart.addItem(product);
      await Future<void>.delayed(Duration.zero);
      await cart.bindUser('buyer-1');
      expect(container.read(cartControllerProvider).single.quantity, 2);
      await cart.bindUser(null);
      expect(container.read(cartControllerProvider), isEmpty);
      final restoring = cart.bindUser('buyer-1');
      cart.addItem(product);
      await restoring;
      expect(container.read(cartControllerProvider).single.quantity, 1);
    },
  );
}

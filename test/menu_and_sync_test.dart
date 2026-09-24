import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/features/pos/presentation/bloc/menu_bloc.dart';
import 'package:cava_pos/features/pos/presentation/bloc/menu_event.dart';
import 'package:cava_pos/features/pos/domain/models/menu_image_preset.dart';
import 'package:cava_pos/core/network/cloud_sync_service.dart';
import 'package:cava_pos/features/auth/domain/user_role.dart';
import 'package:cava_pos/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  group('MenuBloc Image & Name Update Tests', () {
    test('Updating product with new image URL and name updates state properly', () async {
      final menuBloc = MenuBloc();

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 50));

      const updatedName = 'Caramel Macchiato Special';
      const updatedUrl = 'https://images.unsplash.com/photo-custom';
      const updatedPrice = 38000.0;

      menuBloc.add(const UpdateProductPriceEvent(
        productId: 'p_latte',
        newName: updatedName,
        newPrice: updatedPrice,
        newCostPrice: 9500,
        newImageUrl: updatedUrl,
        isAvailable: true,
      ));

      await Future.delayed(const Duration(milliseconds: 50));

      final updatedProduct = menuBloc.state.allProducts.firstWhere((p) => p.id == 'p_latte');
      expect(updatedProduct.name, equals(updatedName));
      expect(updatedProduct.basePrice, equals(updatedPrice));
      expect(updatedProduct.imageUrl, equals(updatedUrl));
      expect(updatedProduct.costPrice, equals(9500));
    });

    test('MenuImagePreset contains curated cafe presets', () {
      expect(MenuImagePreset.presets, isNotEmpty);
      for (final preset in MenuImagePreset.presets) {
        expect(preset.title, isNotEmpty);
        expect(preset.category, isNotEmpty);
        expect(preset.url, startsWith('https://'));
      }
    });
  });

  group('2 Roles Permissions Tests', () {
    test('Cashier role permissions vs Owner role permissions', () {
      const cashier = AuthBloc.cashierUser;
      const owner = AuthBloc.ownerUser;

      // Cashier restrictions
      expect(cashier.role, equals(RoleType.cashier));
      expect(cashier.canAccessAnalytics, isFalse);
      expect(cashier.canAccessFinancialReport, isFalse);
      expect(cashier.canVoidOrder, isFalse);
      expect(cashier.canEditMenuAndPricing, isFalse);

      // Owner privileges
      expect(owner.role, equals(RoleType.owner));
      expect(owner.canAccessAnalytics, isTrue);
      expect(owner.canAccessFinancialReport, isTrue);
      expect(owner.canVoidOrder, isTrue);
      expect(owner.canEditMenuAndPricing, isTrue);
      expect(owner.canManageInventory, isTrue);
    });
  });

  group('Cloud Database & Offline Sync Service Tests', () {
    test('CloudSyncService handles online toggle, offline queueing, and sync drain', () async {
      final syncService = CloudSyncService();

      expect(syncService.isOnline, isTrue);
      expect(syncService.status, equals(SyncStatus.synced));

      // Toggle to offline
      syncService.toggleConnectivity();
      expect(syncService.isOnline, isFalse);
      expect(syncService.status, equals(SyncStatus.offline));

      // Record offline transactions
      syncService.recordOfflineTransaction('ord-off-1');
      syncService.recordOfflineTransaction('ord-off-2');
      expect(syncService.pendingOrdersCount, equals(2));

      // Toggle back online (triggers auto drain sync)
      syncService.toggleConnectivity();
      expect(syncService.isOnline, isTrue);

      // Await sync completion
      await syncService.syncNow();
      expect(syncService.pendingOrdersCount, equals(0));
      expect(syncService.isSyncing, isFalse);
      expect(syncService.status, equals(SyncStatus.synced));
    });
  });
}

import 'package:equatable/equatable.dart';

enum RoleType { cashier, supervisor, owner }

class AppUser extends Equatable {
  final String id;
  final String name;
  final String pinHash;
  final RoleType role;

  const AppUser({
    required this.id,
    required this.name,
    required this.pinHash,
    required this.role,
  });

  bool get canVoidOrder => role == RoleType.supervisor || role == RoleType.owner;
  bool get canApplyManualDiscount => role == RoleType.supervisor || role == RoleType.owner;
  bool get canManageInventory => role == RoleType.supervisor || role == RoleType.owner;
  bool get canAccessAnalytics => role == RoleType.owner;
  bool get canAccessFinancialReport => role == RoleType.owner;
  bool get canEditMenuAndPricing => role == RoleType.supervisor || role == RoleType.owner;
  bool get canOpenCloseShift => true; // All roles can handle shift if assigned

  @override
  List<Object?> get props => [id, name, pinHash, role];
}

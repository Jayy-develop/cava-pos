import 'package:equatable/equatable.dart';
import '../../domain/user_role.dart';

class AuthState extends Equatable {
  final AppUser currentUser;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    required this.currentUser,
    this.errorMessage,
    this.successMessage,
  });

  bool get isOwner => currentUser.role == RoleType.owner;
  bool get isCashier => currentUser.role == RoleType.cashier;

  AuthState copyWith({
    AppUser? currentUser,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      errorMessage: clearError ? null : errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [currentUser, errorMessage, successMessage];
}

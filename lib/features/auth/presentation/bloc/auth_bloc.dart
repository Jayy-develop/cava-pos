import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/user_role.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const cashierUser = AppUser(
    id: 'usr_cashier_01',
    name: 'Arya Pratama',
    pinHash: '1111',
    role: RoleType.cashier,
  );

  static const ownerUser = AppUser(
    id: 'usr_owner_01',
    name: 'Budi Santoso',
    pinHash: '8888',
    role: RoleType.owner,
  );

  AuthBloc() : super(const AuthState(currentUser: cashierUser)) {
    on<SwitchRoleEvent>(_onSwitchRole);
    on<QuickSwitchRoleEvent>(_onQuickSwitchRole);
  }

  void _onSwitchRole(SwitchRoleEvent event, Emitter<AuthState> emit) {
    if (event.role == RoleType.owner) {
      if (event.pin.trim() != ownerUser.pinHash && event.pin.isNotEmpty) {
        emit(state.copyWith(
          errorMessage: 'PIN Owner salah. Masukkan PIN yang benar (Default: 8888)',
        ));
        return;
      }
      emit(state.copyWith(
        currentUser: ownerUser,
        clearError: true,
        successMessage: 'Berhasil beralih ke role Business Owner',
      ));
    } else {
      emit(state.copyWith(
        currentUser: cashierUser,
        clearError: true,
        successMessage: 'Berhasil beralih ke role Kasir (Arya)',
      ));
    }
  }

  void _onQuickSwitchRole(QuickSwitchRoleEvent event, Emitter<AuthState> emit) {
    if (event.role == RoleType.owner) {
      emit(state.copyWith(
        currentUser: ownerUser,
        clearError: true,
        successMessage: 'Mode Business Owner diaktifkan',
      ));
    } else {
      emit(state.copyWith(
        currentUser: cashierUser,
        clearError: true,
        successMessage: 'Mode Kasir diaktifkan',
      ));
    }
  }
}

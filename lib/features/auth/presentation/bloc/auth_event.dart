import 'package:equatable/equatable.dart';
import '../../domain/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SwitchRoleEvent extends AuthEvent {
  final RoleType role;
  final String pin;

  const SwitchRoleEvent({
    required this.role,
    this.pin = '',
  });

  @override
  List<Object?> get props => [role, pin];
}

class QuickSwitchRoleEvent extends AuthEvent {
  final RoleType role;

  const QuickSwitchRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

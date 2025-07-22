import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/routine.dart';

abstract class RoutinesState extends Equatable {
  const RoutinesState();

  @override
  List<Object?> get props => [];
}

class RoutinesInitial extends RoutinesState {}

class RoutinesLoading extends RoutinesState {}

class RoutinesLoaded extends RoutinesState {
  final List<Routine> routines;

  const RoutinesLoaded(this.routines);

  @override
  List<Object?> get props => [routines];
}

class RoutinesError extends RoutinesState {
  final String message;

  const RoutinesError(this.message);

  @override
  List<Object?> get props => [message];
} 
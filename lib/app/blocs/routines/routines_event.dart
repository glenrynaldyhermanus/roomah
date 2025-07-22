import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/routine.dart';

abstract class RoutinesEvent extends Equatable {
  const RoutinesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutines extends RoutinesEvent {
  const LoadRoutines();
}

class AddRoutine extends RoutinesEvent {
  final Routine routine;

  const AddRoutine(this.routine);

  @override
  List<Object?> get props => [routine];
}

class UpdateRoutine extends RoutinesEvent {
  final Routine routine;

  const UpdateRoutine(this.routine);

  @override
  List<Object?> get props => [routine];
}

class DeleteRoutine extends RoutinesEvent {
  final String id;

  const DeleteRoutine(this.id);

  @override
  List<Object?> get props => [id];
}

class CompleteRoutine extends RoutinesEvent {
  final String id;

  const CompleteRoutine(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleRoutineActive extends RoutinesEvent {
  final String id;

  const ToggleRoutineActive(this.id);

  @override
  List<Object?> get props => [id];
} 
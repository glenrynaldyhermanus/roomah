import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/routine_category.dart';

abstract class RoutineCategoriesState extends Equatable {
  const RoutineCategoriesState();

  @override
  List<Object?> get props => [];
}

class RoutineCategoriesInitial extends RoutineCategoriesState {}

class RoutineCategoriesLoading extends RoutineCategoriesState {}

class RoutineCategoriesLoaded extends RoutineCategoriesState {
  final List<RoutineCategory> categories;

  const RoutineCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class RoutineCategoriesError extends RoutineCategoriesState {
  final String message;

  const RoutineCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
} 
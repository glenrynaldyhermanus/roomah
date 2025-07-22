import 'package:equatable/equatable.dart';
import 'package:myapp/app/models/routine_category.dart';

abstract class RoutineCategoriesEvent extends Equatable {
  const RoutineCategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutineCategories extends RoutineCategoriesEvent {
  const LoadRoutineCategories();
}

class AddRoutineCategory extends RoutineCategoriesEvent {
  final RoutineCategory category;

  const AddRoutineCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateRoutineCategory extends RoutineCategoriesEvent {
  final RoutineCategory category;

  const UpdateRoutineCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteRoutineCategory extends RoutineCategoriesEvent {
  final String id;

  const DeleteRoutineCategory(this.id);

  @override
  List<Object?> get props => [id];
} 
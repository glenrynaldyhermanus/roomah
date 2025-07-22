import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'routine_categories_event.dart';
import 'routine_categories_state.dart';

class RoutineCategoriesBloc extends Bloc<RoutineCategoriesEvent, RoutineCategoriesState> {
  final SupabaseService _supabaseService;

  RoutineCategoriesBloc(this._supabaseService) : super(RoutineCategoriesInitial()) {
    on<LoadRoutineCategories>(_onLoadRoutineCategories);
    on<AddRoutineCategory>(_onAddRoutineCategory);
    on<UpdateRoutineCategory>(_onUpdateRoutineCategory);
    on<DeleteRoutineCategory>(_onDeleteRoutineCategory);
  }

  Future<void> _onLoadRoutineCategories(LoadRoutineCategories event, Emitter<RoutineCategoriesState> emit) async {
    emit(RoutineCategoriesLoading());
    try {
      final categories = await _supabaseService.getRoutineCategories();
      emit(RoutineCategoriesLoaded(categories));
    } catch (e) {
      emit(RoutineCategoriesError(e.toString()));
    }
  }

  Future<void> _onAddRoutineCategory(AddRoutineCategory event, Emitter<RoutineCategoriesState> emit) async {
    try {
      await _supabaseService.addRoutineCategory(event.category);
      add(const LoadRoutineCategories());
    } catch (e) {
      emit(RoutineCategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdateRoutineCategory(UpdateRoutineCategory event, Emitter<RoutineCategoriesState> emit) async {
    try {
      await _supabaseService.updateRoutineCategory(event.category);
      add(const LoadRoutineCategories());
    } catch (e) {
      emit(RoutineCategoriesError(e.toString()));
    }
  }

  Future<void> _onDeleteRoutineCategory(DeleteRoutineCategory event, Emitter<RoutineCategoriesState> emit) async {
    try {
      await _supabaseService.deleteRoutineCategory(event.id);
      add(const LoadRoutineCategories());
    } catch (e) {
      emit(RoutineCategoriesError(e.toString()));
    }
  }
} 
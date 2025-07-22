import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app/services/supabase_service.dart';
import 'routines_event.dart';
import 'routines_state.dart';

class RoutinesBloc extends Bloc<RoutinesEvent, RoutinesState> {
  final SupabaseService _supabaseService;

  RoutinesBloc(this._supabaseService) : super(RoutinesInitial()) {
    on<LoadRoutines>(_onLoadRoutines);
    on<AddRoutine>(_onAddRoutine);
    on<UpdateRoutine>(_onUpdateRoutine);
    on<DeleteRoutine>(_onDeleteRoutine);
    on<CompleteRoutine>(_onCompleteRoutine);
    on<ToggleRoutineActive>(_onToggleRoutineActive);
  }

  Future<void> _onLoadRoutines(LoadRoutines event, Emitter<RoutinesState> emit) async {
    emit(RoutinesLoading());
    try {
      final routines = await _supabaseService.getRoutines();
      emit(RoutinesLoaded(routines));
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }

  Future<void> _onAddRoutine(AddRoutine event, Emitter<RoutinesState> emit) async {
    try {
      await _supabaseService.addRoutine(event.routine);
      add(const LoadRoutines());
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }

  Future<void> _onUpdateRoutine(UpdateRoutine event, Emitter<RoutinesState> emit) async {
    try {
      await _supabaseService.updateRoutine(event.routine);
      add(const LoadRoutines());
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }

  Future<void> _onDeleteRoutine(DeleteRoutine event, Emitter<RoutinesState> emit) async {
    try {
      await _supabaseService.deleteRoutine(event.id);
      add(const LoadRoutines());
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }

  Future<void> _onCompleteRoutine(CompleteRoutine event, Emitter<RoutinesState> emit) async {
    try {
      await _supabaseService.completeRoutine(event.id);
      add(const LoadRoutines());
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }

  Future<void> _onToggleRoutineActive(ToggleRoutineActive event, Emitter<RoutinesState> emit) async {
    try {
      await _supabaseService.toggleRoutineActive(event.id);
      add(const LoadRoutines());
    } catch (e) {
      emit(RoutinesError(e.toString()));
    }
  }
} 
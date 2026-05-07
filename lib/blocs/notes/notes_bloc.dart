import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  const LoadNotes();
}

class CreateNote extends NotesEvent {
  final String title;
  final String content;

  const CreateNote(this.title, this.content);

  @override
  List<Object?> get props => [title, content];
}

class UpdateNote extends NotesEvent {
  final int id;
  final String title;
  final String content;

  const UpdateNote(this.id, this.title, this.content);

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNote extends NotesEvent {
  final int id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final List<Note> filteredNotes;
  final String searchQuery;

  const NotesLoaded({
    required this.notes,
    required this.filteredNotes,
    this.searchQuery = '',
  });

  NotesLoaded copyWith({
    List<Note>? notes,
    List<Note>? filteredNotes,
    String? searchQuery,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [notes, filteredNotes, searchQuery];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteSaved extends NotesState {
  const NoteSaved();
}

class NoteDeleted extends NotesState {
  const NoteDeleted();
}

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteService _noteService;

  NotesBloc({required NoteService noteService})
      : _noteService = noteService,
        super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<SearchNotes>(_onSearchNotes);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _noteService.getNotes();
      emit(NotesLoaded(
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(NotesError('Failed to load notes: $e'));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
    try {
      await _noteService.createNote(event.title, event.content);
      emit(NoteSaved());
      final notes = await _noteService.getNotes();
      emit(NotesLoaded(
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(NotesError('Failed to create note: $e'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await _noteService.updateNote(event.id, event.title, event.content);
      emit(NoteSaved());
      final notes = await _noteService.getNotes();
      emit(NotesLoaded(
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _noteService.deleteNote(event.id);
      emit(NoteDeleted());
      final notes = await _noteService.getNotes();
      emit(NotesLoaded(
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(NotesError('Failed to delete note: $e'));
    }
  }

  void _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) {
    final current = state;
    if (current is NotesLoaded) {
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        emit(current.copyWith(filteredNotes: current.notes, searchQuery: ''));
      } else {
        final filtered = current.notes
            .where((n) => n.title.toLowerCase().contains(query))
            .toList();
        emit(current.copyWith(
          filteredNotes: filtered,
          searchQuery: event.query,
        ));
      }
    }
  }
}

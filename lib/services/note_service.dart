import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NoteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<Note>> getNotes() async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Note> createNote(String title, String content) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final note = Note(
      id: 0,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );

    final response = await _supabase
        .from('notes')
        .insert(note.toInsertJson())
        .select()
        .single();

    return Note.fromJson(response);
  }

  Future<Note> updateNote(int id, String title, String content) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final note = Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );

    final response = await _supabase
        .from('notes')
        .update(note.toJson())
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return Note.fromJson(response);
  }

  Future<void> deleteNote(int id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('notes')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';
import '../models/note.dart';

// ── Categoría de guardados ─────────────────────────────────────────────────

class VerseCategory {
  final String name;
  final int color;

  const VerseCategory({required this.name, required this.color});

  Map<String, dynamic> toJson() => {'name': name, 'color': color};
  factory VerseCategory.fromJson(Map<String, dynamic> j) =>
      VerseCategory(name: j['name'], color: j['color']);
}

// ── SavedVersesService ─────────────────────────────────────────────────────

class SavedVersesService {
  static const _highlightsKey  = 'saved_verses';
  static const _categoriesKey  = 'verse_categories';

  static final List<VerseCategory> _defaultCategories = [
    const VerseCategory(name: 'General',    color: 0xFFFFD54F),
    const VerseCategory(name: 'Promesas',   color: 0xFF81C784),
    const VerseCategory(name: 'Fe',         color: 0xFF64B5F6),
    const VerseCategory(name: 'Sabiduría',  color: 0xFFBA68C8),
  ];

  // Categorías
  static Future<List<VerseCategory>> getCategories() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_categoriesKey);
    if (raw == null) return List.from(_defaultCategories);
    return (jsonDecode(raw) as List)
        .map((e) => VerseCategory.fromJson(e))
        .toList();
  }

  static Future<void> saveCategories(List<VerseCategory> cats) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_categoriesKey, jsonEncode(cats.map((c) => c.toJson()).toList()));
  }

  static Future<VerseCategory> addCategory(String name, Color color) async {
    final cats = await getCategories();
    final cat = VerseCategory(name: name, color: color.value);
    cats.add(cat);
    await saveCategories(cats);
    return cat;
  }

  // Highlights
  static List<Highlight>? _cache;

  static Future<List<Highlight>> getAll() async {
    if (_cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_highlightsKey);
    _cache = raw == null ? [] : (jsonDecode(raw) as List).map((e) => Highlight.fromJson(e)).toList();
    return _cache!;
  }

  static void _invalidateCache() => _cache = null;

  static Future<void> _saveAll(List<Highlight> list) async {
    _invalidateCache();
    final p = await SharedPreferences.getInstance();
    await p.setString(_highlightsKey, jsonEncode(list.map((h) => h.toJson()).toList()));
  }

  static Future<Highlight> save(Highlight h) async {
    final list = await getAll();
    list.removeWhere((e) =>
        e.bookName == h.bookName &&
        e.chapterNumber == h.chapterNumber &&
        e.verseNumber == h.verseNumber);
    list.insert(0, h);
    await _saveAll(list);
    return h;
  }

  static Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((h) => h.id == id);
    await _saveAll(list);
  }

  static Future<Highlight?> getForVerse(
      String bookName, int chapter, int verse) async {
    final list = await getAll();
    try {
      return list.firstWhere((h) =>
          h.bookName == bookName &&
          h.chapterNumber == chapter &&
          h.verseNumber == verse);
    } catch (_) {
      return null;
    }
  }
}

// ── NotesService ───────────────────────────────────────────────────────────

class NotesService {
  static const _notesKey = 'user_notes';
  // In-memory cache to avoid repeated SharedPreferences reads per verse
  static List<Note>? _cache;

  static Future<List<Note>> getAll() async {
    if (_cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_notesKey);
    _cache = raw == null ? [] : (jsonDecode(raw) as List).map((e) => Note.fromJson(e)).toList();
    return _cache!;
  }

  static void _invalidate() => _cache = null;

  static Future<void> _saveAll(List<Note> list) async {
    _invalidate();
    final p = await SharedPreferences.getInstance();
    await p.setString(_notesKey, jsonEncode(list.map((n) => n.toJson()).toList()));
  }

  static Future<Note> save(Note n) async {
    final list = await getAll();
    list.removeWhere((e) => e.id == n.id);
    list.insert(0, n);
    await _saveAll(list);
    return n;
  }

  static Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((n) => n.id == id);
    await _saveAll(list);
  }

  static Future<List<Note>> getForVerse(
      String bookName, int chapter, int verse) async {
    final list = await getAll();
    return list.where((n) =>
        n.bookName == bookName &&
        n.chapterNumber == chapter &&
        n.verseNumber == verse).toList();
  }
}

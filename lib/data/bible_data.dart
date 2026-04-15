import '../models/bible_book.dart';

class BibleData {
  static List<BibleBook> getAllBooks() {
    return [
      // Antiguo Testamento
      BibleBook(id: 1, name: 'Génesis', testament: 'OT', chapters: 50, icon: 'history_edu'),
      BibleBook(id: 2, name: 'Éxodo', testament: 'OT', chapters: 40, icon: 'history_edu'),
      BibleBook(id: 3, name: 'Levítico', testament: 'OT', chapters: 27, icon: 'history_edu'),
      BibleBook(id: 4, name: 'Números', testament: 'OT', chapters: 36, icon: 'history_edu'),
      BibleBook(id: 5, name: 'Deuteronomio', testament: 'OT', chapters: 34, icon: 'history_edu'),
      BibleBook(id: 6, name: 'Josué', testament: 'OT', chapters: 24, icon: 'history_edu'),
      BibleBook(id: 7, name: 'Jueces', testament: 'OT', chapters: 21, icon: 'history_edu'),
      BibleBook(id: 8, name: 'Rut', testament: 'OT', chapters: 4, icon: 'history_edu'),
      BibleBook(id: 9, name: '1 Samuel', testament: 'OT', chapters: 31, icon: 'history_edu'),
      BibleBook(id: 10, name: '2 Samuel', testament: 'OT', chapters: 24, icon: 'history_edu'),
      BibleBook(id: 11, name: '1 Reyes', testament: 'OT', chapters: 22, icon: 'history_edu'),
      BibleBook(id: 12, name: '2 Reyes', testament: 'OT', chapters: 25, icon: 'history_edu'),
      BibleBook(id: 13, name: '1 Crónicas', testament: 'OT', chapters: 29, icon: 'history_edu'),
      BibleBook(id: 14, name: '2 Crónicas', testament: 'OT', chapters: 36, icon: 'history_edu'),
      BibleBook(id: 15, name: 'Esdras', testament: 'OT', chapters: 10, icon: 'history_edu'),
      BibleBook(id: 16, name: 'Nehemías', testament: 'OT', chapters: 13, icon: 'history_edu'),
      BibleBook(id: 17, name: 'Ester', testament: 'OT', chapters: 10, icon: 'history_edu'),
      BibleBook(id: 18, name: 'Job', testament: 'OT', chapters: 42, icon: 'history_edu'),
      BibleBook(id: 19, name: 'Salmos', testament: 'OT', chapters: 150, icon: 'music_note'),
      BibleBook(id: 20, name: 'Proverbios', testament: 'OT', chapters: 31, icon: 'history_edu'),
      BibleBook(id: 21, name: 'Eclesiastés', testament: 'OT', chapters: 12, icon: 'history_edu'),
      BibleBook(id: 22, name: 'Cantares', testament: 'OT', chapters: 8, icon: 'history_edu'),
      BibleBook(id: 23, name: 'Isaías', testament: 'OT', chapters: 66, icon: 'history_edu'),
      BibleBook(id: 24, name: 'Jeremías', testament: 'OT', chapters: 52, icon: 'history_edu'),
      BibleBook(id: 25, name: 'Lamentaciones', testament: 'OT', chapters: 5, icon: 'history_edu'),
      BibleBook(id: 26, name: 'Ezequiel', testament: 'OT', chapters: 48, icon: 'history_edu'),
      BibleBook(id: 27, name: 'Daniel', testament: 'OT', chapters: 12, icon: 'history_edu'),
      BibleBook(id: 28, name: 'Oseas', testament: 'OT', chapters: 14, icon: 'history_edu'),
      BibleBook(id: 29, name: 'Joel', testament: 'OT', chapters: 3, icon: 'history_edu'),
      BibleBook(id: 30, name: 'Amós', testament: 'OT', chapters: 9, icon: 'history_edu'),
      BibleBook(id: 31, name: 'Abdías', testament: 'OT', chapters: 1, icon: 'history_edu'),
      BibleBook(id: 32, name: 'Jonás', testament: 'OT', chapters: 4, icon: 'history_edu'),
      BibleBook(id: 33, name: 'Miqueas', testament: 'OT', chapters: 7, icon: 'history_edu'),
      BibleBook(id: 34, name: 'Nahúm', testament: 'OT', chapters: 3, icon: 'history_edu'),
      BibleBook(id: 35, name: 'Habacuc', testament: 'OT', chapters: 3, icon: 'history_edu'),
      BibleBook(id: 36, name: 'Sofonías', testament: 'OT', chapters: 3, icon: 'history_edu'),
      BibleBook(id: 37, name: 'Hageo', testament: 'OT', chapters: 2, icon: 'history_edu'),
      BibleBook(id: 38, name: 'Zacarías', testament: 'OT', chapters: 14, icon: 'history_edu'),
      BibleBook(id: 39, name: 'Malaquías', testament: 'OT', chapters: 4, icon: 'history_edu'),
      
      // Nuevo Testamento
      BibleBook(id: 40, name: 'Mateo', testament: 'NT', chapters: 28, icon: 'auto_stories'),
      BibleBook(id: 41, name: 'Marcos', testament: 'NT', chapters: 16, icon: 'auto_stories'),
      BibleBook(id: 42, name: 'Lucas', testament: 'NT', chapters: 24, icon: 'auto_stories'),
      BibleBook(id: 43, name: 'Juan', testament: 'NT', chapters: 21, icon: 'auto_stories'),
      BibleBook(id: 44, name: 'Hechos', testament: 'NT', chapters: 28, icon: 'auto_stories'),
      BibleBook(id: 45, name: 'Romanos', testament: 'NT', chapters: 16, icon: 'mail'),
      BibleBook(id: 46, name: '1 Corintios', testament: 'NT', chapters: 16, icon: 'mail'),
      BibleBook(id: 47, name: '2 Corintios', testament: 'NT', chapters: 13, icon: 'mail'),
      BibleBook(id: 48, name: 'Gálatas', testament: 'NT', chapters: 6, icon: 'mail'),
      BibleBook(id: 49, name: 'Efesios', testament: 'NT', chapters: 6, icon: 'mail'),
      BibleBook(id: 50, name: 'Filipenses', testament: 'NT', chapters: 4, icon: 'mail'),
      BibleBook(id: 51, name: 'Colosenses', testament: 'NT', chapters: 4, icon: 'mail'),
      BibleBook(id: 52, name: '1 Tesalonicenses', testament: 'NT', chapters: 5, icon: 'mail'),
      BibleBook(id: 53, name: '2 Tesalonicenses', testament: 'NT', chapters: 3, icon: 'mail'),
      BibleBook(id: 54, name: '1 Timoteo', testament: 'NT', chapters: 6, icon: 'mail'),
      BibleBook(id: 55, name: '2 Timoteo', testament: 'NT', chapters: 4, icon: 'mail'),
      BibleBook(id: 56, name: 'Tito', testament: 'NT', chapters: 3, icon: 'mail'),
      BibleBook(id: 57, name: 'Filemón', testament: 'NT', chapters: 1, icon: 'mail'),
      BibleBook(id: 58, name: 'Hebreos', testament: 'NT', chapters: 13, icon: 'mail'),
      BibleBook(id: 59, name: 'Santiago', testament: 'NT', chapters: 5, icon: 'mail'),
      BibleBook(id: 60, name: '1 Pedro', testament: 'NT', chapters: 5, icon: 'mail'),
      BibleBook(id: 61, name: '2 Pedro', testament: 'NT', chapters: 3, icon: 'mail'),
      BibleBook(id: 62, name: '1 Juan', testament: 'NT', chapters: 5, icon: 'mail'),
      BibleBook(id: 63, name: '2 Juan', testament: 'NT', chapters: 1, icon: 'mail'),
      BibleBook(id: 64, name: '3 Juan', testament: 'NT', chapters: 1, icon: 'mail'),
      BibleBook(id: 65, name: 'Judas', testament: 'NT', chapters: 1, icon: 'mail'),
      BibleBook(id: 66, name: 'Apocalipsis', testament: 'NT', chapters: 22, icon: 'visibility'),
    ];
  }

  static List<BibleBook> getOldTestamentBooks() {
    return getAllBooks().where((book) => book.testament == 'OT').toList();
  }

  static List<BibleBook> getNewTestamentBooks() {
    return getAllBooks().where((book) => book.testament == 'NT').toList();
  }
}

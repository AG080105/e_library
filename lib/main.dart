import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Entry point of the E-Library Flutter application.
/// Initializes and runs the app.
void main() {
  runApp(const ELibraryApp());
}

// ===================== MODELS ===================== Ashley ito

/// Represents a book in the e-library.
/// Contains basic information about a book including title, publication year,
/// PDF URL for downloading, and cover image URL.
class Book {
  final String title;
  final String year;
  final String pdfUrl;
  final String coverUrl;

  /// Creates a new Book instance.
  /// All parameters are required.
  Book({
    required this.title,
    required this.year,
    required this.pdfUrl,
    required this.coverUrl,
  });
}

/// Represents user feedback with a comment and rating.
/// Used to collect user opinions about the app.
class FeedbackModel {
  final String comment;
  final int rating;

  /// Creates a new FeedbackModel instance.
  FeedbackModel(this.comment, this.rating);
}

// ===================== GLOBAL STATE ===================== Ashley ito

/// Global list of all books available in the library.
/// This list is shared across the app and modified by admin functions.
List<Book> books = [];

/// Global list of books that have been downloaded by the user.
/// Tracks which books the user has accessed.
List<Book> downloadedBooks = [];

/// Global list of user feedback submissions.
/// Stores all feedback provided by users.
List<FeedbackModel> feedbacks = [];

// ===================== APP ROOT ===================== Ashley ito

/// Root widget of the E-Library application.
/// Configures the MaterialApp with dark theme and navigation.
class ELibraryApp extends StatelessWidget {
  const ELibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00FF88),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          secondary: Color(0xFF00FF88),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00FF88),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ===================== HOME (FIXED) ===================== Mich ito

/// Home screen displaying the list of available books.
/// Allows navigation to the menu and shows books in a list view.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            );
            setState(() {}); // 🔥 REFRESH AFTER RETURN
          },
          child: const Text('E-Library'),
        ),
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                'No books added yet',
                style: TextStyle(color: Color(0xFF00FF88), fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: books.length,
              itemBuilder: (_, i) => BookTile(book: books[i]),
            ),
    );
  }
}

// ===================== MENU ===================== Mich ito

/// Menu screen providing navigation to different sections of the app.
/// Includes options for viewing books by year, feedback, and admin settings.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView(
        children: [
          tile(context, 'Books by Year', Icons.book, const BookYearScreen()),
          tile(context, 'Feedback', Icons.feedback, const FeedbackScreen()),
          tile(context, 'Admin', Icons.settings, const SettingsScreen()),
        ],
      ),
    );
  }

  /// Creates a navigation tile for the menu list.
  /// [c] is the build context, [t] is the title, [i] is the icon, [p] is the page to navigate to.
  Widget tile(BuildContext c, String t, IconData i, Widget p) {
    return ListTile(
      leading: Icon(i, color: const Color(0xFF00FF88)),
      title: Text(t),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
    );
  }
}

// ===================== BOOK TILE ===================== Mich ito

/// Widget representing a single book item in a list.
/// Displays book cover, title, year, and provides download functionality.
class BookTile extends StatelessWidget {
  final Book book;
  const BookTile({super.key, required this.book});

  /// Opens the book's PDF in an external application and marks it as downloaded.
  Future<void> openAndDownload() async {
    final uri = Uri.parse(book.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!downloadedBooks.contains(book)) {
        downloadedBooks.add(book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0A0F0C),
      child: ListTile(
        leading: Image.network(
          book.coverUrl,
          width: 50,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.book, color: Color(0xFF00FF88)),
        ),
        title: Text(book.title),
        subtitle: Text(book.year),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Color(0xFF00FF88)),
          onPressed: openAndDownload,
        ),
        onTap: openAndDownload,
      ),
    );
  }
}

// ===================== BOOKS BY YEAR ===================== Corrales ito

/// Screen displaying books organized by academic year.
/// Allows adding new books and viewing books grouped by year.
class BookYearScreen extends StatelessWidget {
  const BookYearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
    return Scaffold(
      appBar: AppBar(title: const Text('Books by Year')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
        },
      ),
      body: ListView(
        children: years.map((y) {
          return ExpansionTile(
            title: Text(y, style: const TextStyle(color: Color(0xFF00FF88))),
            children: books
                .where((b) => b.year == y)
                .map((b) => BookTile(book: b))
                .toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ===================== ADD BOOK ===================== Corrales ito

/// Screen for adding new books to the library.
/// Provides form fields for book details and saves to global books list.
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final title = TextEditingController();
  final pdf = TextEditingController();
  final cover = TextEditingController();
  String year = '1st Year';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field(title, 'Title'),
            DropdownButton<String>(
              value: year,
              isExpanded: true,
              items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (v) => setState(() => year = v!),
            ),
            field(pdf, 'PDF URL'),
            field(cover, 'Cover URL'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                books.add(Book(
                  title: title.text,
                  year: year,
                  pdfUrl: pdf.text,
                  coverUrl: cover.text,
                ));
                Navigator.pop(context);
              },
              child: const Text('ADD BOOK'),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a text input field with label.
  /// [c] is the text controller, [l] is the label text.
  Widget field(TextEditingController c, String l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: l),
      ),
    );
  }
}

// ===================== FEEDBACK ===================== Corrales ito

/// Screen for submitting and viewing user feedback.
/// Allows users to submit anonymous comments and ratings, and displays all feedback.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final comment = TextEditingController();
  int rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: comment,
                  decoration:
                      const InputDecoration(labelText: 'Anonymous Comment'),
                ),
                DropdownButton<int>(
                  value: rating,
                  items: List.generate(5, (i) => i + 1)
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text('Rating $r')))
                      .toList(),
                  onChanged: (v) => setState(() => rating = v!),
                ),
                ElevatedButton(
                  onPressed: () {
                    feedbacks.add(FeedbackModel(comment.text, rating));
                    comment.clear();
                    setState(() {});
                  },
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: feedbacks
                  .map((f) => ListTile(
                        title: Text(f.comment),
                        trailing: Text('${f.rating}/5'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== ADMIN ===================== Sai ito

/// Admin panel screen for managing app data.
/// Provides options to delete books, feedback, and view downloaded books.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        children: [
          adminTile('Delete All Books', () => books.clear()),
          adminTile('Delete Downloaded Books', () => downloadedBooks.clear()),
          adminTile('Delete Feedbacks', () => feedbacks.clear()),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Downloaded Books',
                style: TextStyle(color: Color(0xFF00FF88), fontSize: 18)),
          ),
          ...downloadedBooks.map((b) => ListTile(title: Text(b.title))),
        ],
      ),
    );
  }

  /// Creates an admin action tile for the settings list.
  /// [t] is the title, [a] is the action callback.
  Widget adminTile(String t, VoidCallback a) {
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.redAccent),
      title: Text(t),
      onTap: a,
    );
  }
}

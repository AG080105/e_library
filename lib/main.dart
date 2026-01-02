import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ELibraryApp());
}

// ===================== MODELS ===================== Ashley ito
/*
So itong mga code dito ay nagde-define ng mga modelo para sa Book at FeedbackModel.
Ang Book class ay may apat na properties: title, year, pdfUrl, at coverUrl
*/
class Book {
  final String title;
  final String year;
  final String pdfUrl;
  final String coverUrl;

  Book({
    required this.title,
    required this.year,
    required this.pdfUrl,
    required this.coverUrl,
  });
}

//Ito ay yung makikita sa ano pag nag rerate sa settings ata yun basta makikita yung rating at comment
class FeedbackModel {
  final String comment;
  final int rating;
  FeedbackModel(this.comment, this.rating);
}

// ===================== GLOBAL STATE ===================== Ashley ito
/*
Ito naman ay yung global state ng application kung saan nilalagay yung mga listahan ng books, downloadedBooks, at feedbacks.
*/
List<Book> books = [];
List<Book> downloadedBooks = [];
List<FeedbackModel> feedbacks = [];

// ===================== APP ROOT ===================== Ashley ito

/*
Ito ay yung mga code na nagpapakita ng primary screen ng applicaton.
Balee andito nakabilang yung background color, primary colors, at iba pa na tema ng app.
*/
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
/*
Dito naman ay yung home screen, pero dito ay yung dlwang nakalagay sa screen which is yung word at yung word button sa appbar.
*/
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
            setState(() {}); // Refresh state when returning from menu
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
/*
Ang primary use nito ay yung pag pinindot na yung E-Library sa home screen
Ipupunta ka non sa Menu screen which is yung tatlong title context sa ibaba
plus colors lng nila at icons
*/
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

  Widget tile(BuildContext c, String t, IconData i, Widget p) {
    return ListTile(
      leading: Icon(i, color: const Color(0xFF00FF88)),
      title: Text(t),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
    );
  }
}

// ===================== BOOK TILE ===================== Mich ito
/*
Dito sa section na ito nakalagay yung BookTile class na siyang nagre-render ng bawat book sa listahan.
Sa loob ng BookTile, mayroong method na openAndDownload na nagbubukas ng PDF URL ng book at idinadagdag ito sa downloadedBooks list kung hindi pa ito nandoon.
*/
class BookTile extends StatelessWidget {
  final Book book;
  const BookTile({super.key, required this.book});
//So dito ay server end na nagbubukas ng nilalagay mo na URl sa pdfUrl ng Book model
  Future<void> openAndDownload() async {
    final uri = Uri.parse(book.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!downloadedBooks.contains(book)) {
        downloadedBooks.add(book);
      }
    }
  }

/*ito naman yung UI ng BookTile kung paano siya mag-aappear sa screen
Dito din pala belong yung handlers ng mga button sa loob ng book tiles 
like yung Dl button and yung pag click sa tile mismo
*/
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
/*
Ito ay yung sa ano sa loob ng MENU
Ito yung part ng BOOKS BY YEAR button, na nagpupush ng new screen
Nag nagpapakita ng new contents which are yung apat na year na kung saan ka pwede mag lagay ng laman 
sa pamamagitan ng + sign na button sa end side ng screen sa baba
*/
class BookYearScreen extends StatelessWidget {
  const BookYearScreen({super.key});
//Itong part yung front end specifically
  @override
  Widget build(BuildContext context) {
    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
    return Scaffold(
      appBar: AppBar(title: const Text('Books by Year')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add), //Dito yung sign na button sa baba
        onPressed: () async {
          await Navigator.push(
            //Dito yung handler ng plus sign button na magpupush ng new screen
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
        },
      ),
      body: ListView(
        //Mula dito nagsisimula yung listahan ng books by year, like yung may dropdown shit sa mga year sa BOOK BY YEAR na table
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
/*
Dito is yung about sa pag add na ng book tlga
Balee ito yung nasa prang fill-up phase ka after mo ma click yung plus sign button
Ispecify ko nlng per block or per line
*/
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

//So balee dito ay yung makikita mo bilang main shit ng fill-up screen
class _AddBookScreenState extends State<AddBookScreen> {
  final title = TextEditingController();
  final pdf = TextEditingController();
  final cover = TextEditingController();
  String year = '1st Year';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              'Add Book')), //Balee ito ay yung title lng sa appBar ng ano sa fill-up screen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field(title,
                'Title'), //Ito ay yung nakasulat sa unang line ng fill-up screen
            DropdownButton<String>(
              value: year,
              isExpanded: true,
              items: [
                '1st Year',
                '2nd Year',
                '3rd Year',
                '4th Year'
              ] //Ito naman ay supporting shit dun sa dropdown sa year nmn
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (v) => setState(() => year =
                  v!), //Ito ay yung handler ng dropdown button, like pag nakapili ka na, yun na din yung lalabas
            ),
            field(pdf, 'PDF URL'), //Ito yung about sa PDF na textfield
            field(cover,
                'Cover URL'), //Ito ay same lng din sa PDF textfield, which is ito ay about sa Cover text field, pweede nga ito lagyan ng picsum.photos eh kaso kasi di aayon sa black/green theme ntin
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (pdf.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Kailangan ng URL sa PDF broh')),
                  );
                } else {
                  //Mula dito ay yung didiscuss ko sa presentation day ntin, ito yung ilalagay sa properties
                  books.add(Book(
                    title: title.text,
                    year: year,
                    pdfUrl: pdf.text,
                    coverUrl: cover.text,
                  ));
                  Navigator.pop(
                      context); //Ito yung kapag done na sa fill-up screen, kaya nakapaloob sya sa onPressed handler ng ADD BOOK button
                }
              },
              child: const Text(
                  'ADD BOOK'), //Ito ay yung button lng sa center eh, alam mo na ito Corrales, ikaw pa
            ),
          ],
        ),
      ),
    );
  }

// Dito naman ay yung kung saan ka mag fifill-up sa fil-up screen
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

// ===================== FEEDBACK ===================== Sai ito
/*
So dito naman nakalgay yung mga bgay bgay sa code na naghahandle ng feedback screen
like yung comment box, yung rating, at yung submit button pra maipasa yugn feedback
plus, yung guhit sa baba which is yung mga listahan ng mga feedback na naipasa na
*/
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

// dito naman yung part specifically ng feedback screen
// kung saan nakalagay yung UI at yung mga handlers ng mga button sa loob ng feedback screen
class _FeedbackScreenState extends State<FeedbackScreen> {
  final comment =
      TextEditingController(); //Dito ay yung textfield for the comment
  int rating =
      5; //Dito naman ay yung rating default, balee yung number na makikita mo sa dropdown bago mo pindutin
  static const List<String> ratinglabels = [
    'Very bad',
    'Bad',
    'Saks',
    'Good',
    'Very Good'
  ];

/*
Dito nmn ay yung UI ng FEEDBACK screen
Kasma na rin dito ay yng mga handlers
*/
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
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(ratinglabels[r -
                              1]))) //ito ay yung mga numbers na prsent sa dropdown
                      .toList(),
                  onChanged: (v) => setState(() => rating =
                      v!), //While ito yung pag nakapili ka na ng number sa ay yun na ang ididisplay ng screen pra sayo
                ),
                ElevatedButton(
                  onPressed: () {
                    //Ito yung handler ng SUBMIT button
                    feedbacks.add(FeedbackModel(comment.text, rating));
                    comment.clear();
                    setState(() {});
                  },
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          ),
          const Divider(), // Ito ay yung guhit na mahaba sa baba ng SUBMIT button
          Expanded(
            child: ListView(
              children: feedbacks
                  .map((f) => ListTile(
                        //Itong part ay yung mga listahan sa UI na kung saan nakikita yung mga fedback na pinasa or sinubmit
                        title: Text(f.comment),
                        trailing: Text(ratinglabels[f.rating -
                            1]), //Ito sa part ng rating, sa gilid tlga toh makikita eh
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
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
/*
Dito naman ay yung mga related sa ADMIN screen
Like yung mga buttons na nasa adminTile methods
*/
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
          ...downloadedBooks.map((b) => ListTile(
              title: Text(b
                  .title))), //Ito yung malaking black part ng ADMIN screen, sya rin yugn may sublabel na 'Downloaded Books'
        ],
      ),
    );
  }

  Widget adminTile(String t, VoidCallback a) {
    return ListTile(
      leading: const Icon(Icons.delete,
          color: Colors
              .redAccent), //Alam mo na ito, sila yung basurahan na icon Sai
      title: Text(t),
      onTap: a,
    );
  }
}

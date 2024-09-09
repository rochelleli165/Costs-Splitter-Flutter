import 'package:flutter/material.dart';
import 'package:split_wise/receipt-view-model.dart';
import 'package:split_wise/receipt-model.dart';
import 'package:split_wise/receipt.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

final receiptModel = ReceiptModel();
final receiptViewModel = ReceiptViewModel(ReceiptModel());

final peopleNotifier = PeopleNotifer();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Costs Splitter',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemTeal,
        primaryContrastingColor: CupertinoColors.white,
        barBackgroundColor: CupertinoColors.systemCyan,
        scaffoldBackgroundColor: CupertinoColors.systemBlue,
        textTheme: CupertinoTextThemeData(
          textStyle: DefaultTextStyle,
          actionTextStyle: BlackTextStyle,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

TextStyle get DefaultTextStyle {
  final TextStyle DefaultTextStyle = GoogleFonts.notoSans(
      // ignore: prefer-trailing-comma
      textStyle: const TextStyle(
          color: CupertinoColors.label,
          letterSpacing: -0.41,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.bold,
          // ignore: prefer-trailing-comma
          fontSize: 17.0));

  return DefaultTextStyle;
}

TextStyle get BlackTextStyle {
  final TextStyle BlackTextStyle = GoogleFonts.notoSans(
      // ignore: prefer-trailing-comma
      textStyle: const TextStyle(
          color: CupertinoColors.black,
          letterSpacing: -0.41,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.bold,
          // ignore: prefer-trailing-comma
          fontSize: 17.0));

  return BlackTextStyle;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200, // Adjust height as needed
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor, // Panel color
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(30), // Adjust curve radius as needed
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Cost Splitter',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                  ),
                ),
              ),
              ListenableBuilder(
                  listenable: peopleNotifier,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            color: CupertinoColors.extraLightBackgroundGray,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                               ListTile(
                                  leading: Icon(Icons.people),
                                  title: Text('Step 1: Add people',
                                  style: CupertinoTheme.of(context).textTheme.actionTextStyle),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: peopleNotifier.people
                                          .map((item) => Text(
                                                item,
                                                style: CupertinoTheme.of(context).textTheme.actionTextStyle,
                                              ))
                                          .toList()),
                                ),
                                Form(
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CupertinoTextField(
                                          style: CupertinoTheme.of(context).textTheme.actionTextStyle,
                                          decoration: BoxDecoration(color: Colors.white),
                                          controller: textController,
              
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: CupertinoButton.filled(
                                            onPressed: () {
                                              setState(() {
                                                if(!textController.text.isEmpty) {
                                                peopleNotifier
                                                    .add(textController.text);
                                                }
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(40.0),
                                            child: Icon(Icons.person_add))),
                                      
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const Padding(
                          padding: EdgeInsets.all(8.0),
                  ),
              ListenableBuilder(
                  listenable: receiptViewModel,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: CupertinoColors.extraLightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            children: [
                              ListTile(
                                    leading: Icon(Icons.receipt),
                                    title: Text('Step 2: Upload receipt image',
                                    style: CupertinoTheme.of(context).textTheme.actionTextStyle),
                                  ),
                              receiptViewModel.items.isEmpty
                                  ? CupertinoButton.filled(
                                      onPressed: () {
                                        receiptViewModel.update();
                                      },
                                      borderRadius: BorderRadius.circular(40.0),
                                      child: const Text('Upload Image'),
                                    )
                                  : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Image Processed!', style: CupertinoTheme.of(context).textTheme.actionTextStyle),
                                  ),
                              receiptViewModel.items.isEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('It will take time to upload and process',style: CupertinoTheme.of(context).textTheme.actionTextStyle,
                                    ),
                                  )
                                  
                                  : CupertinoButton.filled(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ReceiptPage(
                                                items: receiptViewModel.items,
                                                people: peopleNotifier.people),
                                          ),
                                        );
                                      },
                                      child: const Text('Next'),
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    Padding(padding: EdgeInsets.all(10.0)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class PeopleNotifer extends ChangeNotifier {
  List<String> _people = [];
  List<String> get people => _people;

  void add(String person) {
    _people.add(person);
    notifyListeners();
  }
}

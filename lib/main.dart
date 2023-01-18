import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import './components/notepage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import './components/onboarding.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:io';

class YourObject {
  String title;
  final double ID;
  final String date;
  String category;

  YourObject({
    required this.title,
    required this.ID,
    required this.category,
    required this.date
  });
  YourObject.fromJson(Map<String, Object?> json)
      : this(
    title: json['title']! as String,
    category: json['category']! as String,
    date: json['date']! as String,
    ID: json['ID']! as double,
  );
  Map<String, Object?> toJson() {
    return {
      'ID': ID,
      'title': title,
      'category': category,
      'date': date,
    };
  }
}

int order = 1;
List<YourObject> yourObjectList = [];
List<String> encodedObjects = yourObjectList.map((res)=>json.encode(res.toJson())).toList();
Iterable yourObjectListRev = yourObjectList.reversed;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? decodedObjects = prefs.getStringList("notes");
  double? firstBoot = prefs.getDouble("firstBoot");
  print(firstBoot);
  print(decodedObjects);
  if(decodedObjects == null){
    yourObjectList = [];
  } else {
    yourObjectList = decodedObjects.map((res)=>YourObject.fromJson(json.decode(res))).toList();
  }
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (firstBoot == 2.0){
    prefs.setDouble("firstBoot", 3);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(const CupertinoApp(
      home: OnboardingPage(),
      title: 'Audionote',
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
    ),));
  } else {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(const CupertinoApp(
      home: Home(),
      title: 'Audionote',
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
    ),));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => homeState();
}

class homeState extends State<Home> {
  TextEditingController controller = TextEditingController(text: "");
  late int index;
  late CupertinoButton cupertinoButton;
  refresh() {
    save();
    setState(() {});
  }
  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedObjects = yourObjectList.map((res)=>json.encode(res.toJson())).toList();
    prefs.setStringList("notes", encodedObjects);
    print(encodedObjects);
  }
  read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? decodedObjects = prefs.getStringList("notes");
    yourObjectList = decodedObjects!.map((res)=>YourObject.fromJson(json.decode(res))).toList();
    yourObjectListRev = yourObjectList;
  }
  addToList() {
    if(yourObjectList.isEmpty){
      var now = DateTime.now();
      var formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);
      yourObjectList.add(YourObject(ID: 1, date: formattedDate, title: "New Audionote #1", category: 'Uncategorized'));
      refresh();
    } else {
      var now = DateTime.now();
      var formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);
      final int newID = yourObjectList.last.ID.toInt();
      yourObjectList.add(YourObject(ID: yourObjectList.last.ID+1, date: formattedDate, title: "New Audionote #${newID+1}", category: 'Uncategorized'));
      refresh();
    }
  }
  changeOrder() {
    if(order == 1){
      order = 0;
      yourObjectListRev = yourObjectList;
      refresh();
    } else {
      order = 1;
      yourObjectListRev = yourObjectList.reversed;
      refresh();
    }
  }
  filterSearch(text) {
    if(text.isNotEmpty){
      List results = [];
      results = yourObjectListRev
          .where((element) => element.title
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase()))
          .toList();
      yourObjectListRev = results;
      refresh();
    } else {
      changeOrder();
      changeOrder();
    }
  }
  removeToList(IDRemove) async{
    final int Removeindex = yourObjectList.indexWhere(((yourObject) => yourObject.ID == IDRemove));
    final date = yourObjectList[Removeindex].date;
    final id = yourObjectList[Removeindex].ID.toInt();
    print(date);
    print(id);
    yourObjectList.remove(yourObjectList[Removeindex]);
    final directory = await getApplicationDocumentsDirectory();
    final _path = directory.path; // instead of "/storage/emulated/0"
    final filePath = File('$_path/Audionotes/Audionote-($date)-$id.m4a');
    if(await filePath.exists()){
      print(filePath.path);
      filePath.delete();
    } else {
      print("No hay archivo");
    }
    refresh();
  }
  void _aboutDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('About'),
        content: const Text('Audionote is an application \nby Maximo Ospital, 2023.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  final TextEditingController titleController = TextEditingController();
  final TextEditingController categoryType = TextEditingController();

  void _propertiesDialog(BuildContext context, double ID) {
    titleController.text = yourObjectList[yourObjectList.indexWhere(((yourObject) => yourObject.ID == ID))].title;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Rename"),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              const SizedBox(height:15),
              SizedBox(
                width: double.infinity,
                child: Container(
                  child: Text(
                    "Note title:",
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const SizedBox(height:5),
              CupertinoTextField(
                placeholder: yourObjectList[yourObjectList.indexWhere(((yourObject) => yourObject.ID == ID))].title,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(35),
                ],
                controller: titleController,
              ),
            ],
          ),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates this action is the default,
            /// and turns the action's text to bold text.
            isDefaultAction: false,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: false,
            onPressed: () {
              if(titleController.text.isNotEmpty){
                final int index = yourObjectList.indexWhere(((yourObject) => yourObject.ID == ID));
                setState(() {
                  yourObjectList[index].title = titleController.text;
                });
                refresh();
              } else {
                refresh();
              }
              Navigator.pop(context);
              Navigator.pop(context);
              refresh();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  void _showActionSheet(BuildContext context, double ID) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("${yourObjectList[yourObjectList.indexWhere(((yourObject) => yourObject.ID == ID))].title} - Properties"),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// defualt behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              _propertiesDialog(context, ID);
            },
            child: const Text('Rename'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Change Category'),
          ),
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              removeToList(ID);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  void dispose() async{
    super.dispose();
    titleController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return CupertinoPageScaffold(
      // A ScrollView that creates custom scroll effects using slivers.
      child: CustomScrollView(
        // A list of sliver widgets.
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading:  CupertinoButton(onPressed: () { changeOrder(); }, padding: EdgeInsets.zero, child: Icon(order == 1 ? CupertinoIcons.sort_down : CupertinoIcons.sort_up),),
            middle: CupertinoButton(
              onPressed: () { _aboutDialog(context); },
              padding: EdgeInsets.zero,
              child: Text('Audionote', style: TextStyle(color: CupertinoTheme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black)),
            ),
            // This title is visible in both collapsed and expanded states.
            // When the "middle" parameter is omitted, the widget provided
            // in the "largeTitle" parameter is used instead in the collapsed state.
            largeTitle: Text('Notes'),
            trailing:  CupertinoButton(onPressed: () {
              addToList();
              Navigator.push(context, CupertinoPageRoute<Widget>(
                  builder: (BuildContext context) {
                    return notepage(ID: yourObjectList.last.ID, category: yourObjectList.last.category, date: yourObjectList.last.date, notifyParent: () { refresh(); },);
                  }));
            }, padding: EdgeInsets.zero, child: Icon(CupertinoIcons.add_circled),),
          ),
          SliverToBoxAdapter (
            child: yourObjectList.isEmpty ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                  children:[SizedBox(height: 22),
                    Text("No notes here! Press + to create new notes.",
                        style: TextStyle(color: CupertinoTheme.brightnessOf(context) == Brightness.dark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)))]
              )
            ) : Column(
              children:[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Container(
                        child:
                          CupertinoSearchTextField(
                            controller: controller,
                            placeholder: "Search a note",
                            onChanged: (value) {
                              filterSearch(value);
                            },
                            autocorrect: true,
                          ),
                      )
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                        children:[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState)
                                  {
                                    return Column(
                                          children: yourObjectListRev.map((currentObject) {
                                            final index = yourObjectList.indexWhere(((yourObject) => yourObject.ID == currentObject.ID));
                                            final item = yourObjectList[index];
                                            return HoldDetector(
                                                onHold: () { _showActionSheet(context, currentObject.ID); },
                                                holdTimeout: Duration(milliseconds: 200),
                                                enableHapticFeedback: true,
                                                child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Dismissible(
                                                      key: Key(item.ID.toString()),
                                                      onDismissed: (direction) {
                                                        removeToList(currentObject.ID);
                                                      },
                                                      background: Container(color: Colors.red),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                                        child: CupertinoButton(
                                                          pressedOpacity: 0.65,
                                                          borderRadius: const BorderRadius.all(
                                                            Radius.circular(0),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                                                          alignment: Alignment.centerLeft,
                                                          child: Row(
                                                              children:[
                                                                Expanded(
                                                                    child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children:[
                                                                                  Text(
                                                                                      '${currentObject.title}',
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoTheme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black),
                                                                                      overflow: TextOverflow.ellipsis
                                                                                  ),
                                                                                  Text.rich(
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      TextSpan(
                                                                                          children: [
                                                                                            TextSpan(text:"${currentObject.category}", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                                                                            TextSpan(text:" • 0:00", style: TextStyle(color: Colors.grey))
                                                                                          ]
                                                                                      )
                                                                                  ),
                                                                                  Text(
                                                                                    '${currentObject.date}',
                                                                                    style: TextStyle(color: Colors.grey),
                                                                                  ),
                                                                                ]
                                                                            ),
                                                                          ),
                                                                          const Icon(
                                                                            Icons.chevron_right,
                                                                            color: Colors.grey,
                                                                          ),
                                                                        ]
                                                                    )
                                                                ),
                                                              ]
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(context, CupertinoPageRoute<Widget>(
                                                                builder: (BuildContext context) {
                                                                  return notepage(ID: currentObject.ID, category: currentObject.category, date: currentObject.date, notifyParent: () { refresh(); },);
                                                                }));
                                                          },
                                                        ),
                                                      )
                                                  ),
                                                ),
                                              ],
                                            )
                                            );
                                          }).toList(),
                                        );
                                  }
                              ),
                            ],
                          ),
                        ]
                    )
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}
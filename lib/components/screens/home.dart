import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../screens/notepage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:io';
import '../NoteObject.dart';
import '../../main.dart';

int order = 1;
List<String> encodedObjects = NoteObjectList.map((res)=>json.encode(res.toJson())).toList();
Iterable NoteObjectListRev = NoteObjectList.reversed;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => homeState();
}

class homeState extends State<Home> {
  TextEditingController controller = TextEditingController(text: "");
  late int index;
  late CupertinoButton cupertinoButton;
  bool _show = false;
  refresh() {
    save();
    setState(() {});
  }
  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedObjects = NoteObjectList.map((res)=>json.encode(res.toJson())).toList();
    prefs.setStringList("notes", encodedObjects);
    print(encodedObjects);
  }
  read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? decodedObjects = prefs.getStringList("notes");
    NoteObjectList = decodedObjects!.map((res)=>NoteObject.fromJson(json.decode(res))).toList();
    NoteObjectListRev = NoteObjectList;
  }
  addToList() {
    if(NoteObjectList.isEmpty){
      var now = DateTime.now();
      var formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);
      NoteObjectList.add(NoteObject(ID: 1, date: formattedDate, title: "New Audionote #1", category: 'Uncategorized'));
      refresh();
    } else {
      var now = DateTime.now();
      var formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);
      final int newID = NoteObjectList.last.ID.toInt();
      NoteObjectList.add(NoteObject(ID: NoteObjectList.last.ID+1, date: formattedDate, title: "New Audionote #${newID+1}", category: 'Uncategorized'));
      refresh();
    }
  }
  changeOrder() {
    if(order == 1){
      order = 0;
      NoteObjectListRev = NoteObjectList;
      refresh();
    } else {
      order = 1;
      NoteObjectListRev = NoteObjectList.reversed;
      refresh();
    }
  }
  filterSearch(text) {
    if(text.isNotEmpty){
      List results = [];
      results = NoteObjectListRev
          .where((element) => element.title
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase()))
          .toList();
      NoteObjectListRev = results;
      refresh();
    } else {
      changeOrder();
      changeOrder();
    }
  }
  filterCategory(text) {
    changeOrder();
    changeOrder();
    if(text != 'all'){
      List results = [];
      results = NoteObjectListRev.where((element) => element.category.toString().toLowerCase() == text.toLowerCase()).toList();
      NoteObjectListRev = results;
      refresh();
    } else {
      changeOrder();
      changeOrder();
    }
  }
  showFilter(){
    _show = !_show;
    refresh();
    if(_show == false){
      filterCategory('all');
      CupertinoRadioResetSelect();
    }
  }
  removeToList(IDRemove) async{
    final int Removeindex = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == IDRemove));
    final date = NoteObjectList[Removeindex].date;
    final id = NoteObjectList[Removeindex].ID.toInt();
    print(date);
    print(id);
    NoteObjectList.remove(NoteObjectList[Removeindex]);
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
  CupertinoSuggestionsBoxController _suggestionsBoxController = CupertinoSuggestionsBoxController();
  String favoriteCategory = 'Unavailable';
  void _titleDialog(BuildContext context, double ID) {
    titleController.text = NoteObjectList[NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID))].title;
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
                placeholder: NoteObjectList[NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID))].title,
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
                final int index = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID));
                setState(() {
                  NoteObjectList[index].title = titleController.text;
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
  void _categoryDialog(BuildContext context, double ID) {
    List<String> categories = NoteObjectList.map((NoteObject) => NoteObject.category).toList().toSet().toList();
    print(categories);
    List<String> getSuggestions(String query) {
      List<String> matches = <String>[];
      matches.addAll(categories);

      matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
      return matches;
    }
    categoryType.text = NoteObjectList[NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID))].category;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Change category"),
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
                    "Note category:",
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const SizedBox(height:5),
              CupertinoTypeAheadFormField(
                getImmediateSuggestions: true,
                suggestionsBoxController: _suggestionsBoxController,
                textFieldConfiguration: CupertinoTextFieldConfiguration(
                  controller: categoryType,
                  maxLength: 35,
                ),
                suggestionsCallback: (pattern) {
                  return Future.delayed(
                    Duration(seconds: 1),
                        () => getSuggestions(pattern),
                  );
                },
                itemBuilder: (context, String suggestion) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      suggestion,
                    ),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  categoryType.text = suggestion;
                },
                validator: (value) =>
                value!.isEmpty ? 'Please select a category' : null,
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
              if(categoryType.text.isNotEmpty){
                final int index = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID));
                setState(() {
                  NoteObjectList[index].category = categoryType.text;
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
        title: Text("${NoteObjectList[NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == ID))].title} - Properties"),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// defualt behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              _titleDialog(context, ID);
            },
            child: const Text('Rename'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _categoryDialog(context, ID);
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
                    return notepage(ID: NoteObjectList.last.ID, category: NoteObjectList.last.category, date: NoteObjectList.last.date, notifyParent: () { refresh(); },);
                  }));
            }, padding: EdgeInsets.zero, child: Icon(CupertinoIcons.add_circled),),
          ),
          SliverToBoxAdapter (
              child: NoteObjectList.isEmpty ? Padding(
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
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          child: Container(
                            child:
                            Row(
                              children: [
                                Expanded(child:
                                CupertinoSearchTextField(
                                  controller: controller,
                                  placeholder: "Search a note",
                                  onChanged: (value) {
                                    filterSearch(value);
                                  },
                                  autocorrect: true,
                                ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: CupertinoButton(
                                    onPressed: () { showFilter(); },
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(CupertinoIcons.slider_horizontal_3),
                                  ),
                                ),
                              ],
                            ),

                          )
                      ),
                    ),
                    SizedBox(height: 2),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.ease,
                      child: SizedBox(
                          height: _show? null : 0.0,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                              children: [
                                Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                      child: Row(
                                          children: [
                                            CupertinoRadioChoice(
                                              choices: const {'all' : 'All', 'Uncategorized' : 'Uncategorized', 'Uncategorized 2' : 'Uncategorized 2', 'Uncategorized 3' : 'Uncategorized 3'},
                                              onChange: (selectedCategory) {
                                                filterCategory(selectedCategory);
                                              },
                                              initialKeyValue: 'all',
                                            )
                                          ]
                                      ),
                                    )
                                )
                              ]
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
                                          children: NoteObjectListRev.map((currentObject) {
                                            final index = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == currentObject.ID));
                                            final item = NoteObjectList[index];
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
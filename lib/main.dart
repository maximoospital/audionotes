import 'package:audionotes/components/services/InitialSetup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'components/NoteObject.dart';

List<NoteObject> NoteObjectList = [];
List<String> encodedObjects = NoteObjectList.map((res)=>json.encode(res.toJson())).toList();
Iterable NoteObjectListRev = NoteObjectList.reversed;


void main() async {
  // Checks if app was initialized
  WidgetsFlutterBinding.ensureInitialized();
  InitialSetup();
}
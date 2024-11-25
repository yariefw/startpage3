import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startpage/config.dart';
import 'package:startpage/homepage.dart';
import 'package:startpage/menu_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> loadBookmarks() async {
    final String jsonBookmarks =
        await rootBundle.loadString('assets/json/bookmarks.json');

    Map<String, dynamic> data = await json.decode(jsonBookmarks);

    List<MenuItem> jsonMenu = [];

    for (var item in data['bookmarks']) {
      MenuItem menuItem = menuItemFromJson(item);
      jsonMenu.add(menuItem);
    }

    bookmarks = jsonMenu;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homepage',
      home: FutureBuilder(
        future: loadBookmarks(),
        builder: (context, snapshot) {
          return const Homepage();
        },
      ),
    );
  }
}

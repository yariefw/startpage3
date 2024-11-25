import 'dart:convert';

MenuItem menuItemFromJson(Map<String, dynamic> data) => MenuItem.fromJson(data);

String menuItemToJson(MenuItem data) => json.encode(data.toJson());

class MenuItem {
  String label;
  String url;
  List<MenuItem> submenu;

  MenuItem({
    required this.label,
    this.url = '',
    this.submenu = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        label: json["label"],
        url: json["url"] ?? '',
        submenu: json["submenu"] == null
            ? []
            : List<MenuItem>.from(
                json["submenu"].map((x) => MenuItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "url": url,
        "submenu": List<dynamic>.from(submenu.map((x) => x.toJson())),
      };
}

class MenuItem {
  String label;
  String url;
  List<MenuItem> items;

  MenuItem({
    required this.label,
    this.url = '',
    this.items = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        label: json["label"],
        url: json["url"] ?? '',
        items: json["submenu"] == null
            ? []
            : List<MenuItem>.from(
                json["submenu"].map((x) => MenuItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "url": url,
        "submenu": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

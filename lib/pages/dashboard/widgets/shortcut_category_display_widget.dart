part of '../dashboard.dart';

class ShortcutCategoryDisplayWidget extends StatelessWidget {
  const ShortcutCategoryDisplayWidget({
    super.key,
    this.label,
    this.items = const [],
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final String? label;
  final List<MenuItem> items;
  final Function(MenuItem item)? onTap;
  final Function(MenuItem item)? onDoubleTap;
  final Function(MenuItem item)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label?.isNotEmpty ?? false)
                Container(
                  width: context.screenWidth,
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    label ?? '',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: (constraints.maxWidth) / 500,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (onTap != null) onTap!(items[index]);
                    },
                    onDoubleTap: () {
                      if (onDoubleTap != null) onDoubleTap!(items[index]);
                    },
                    onLongPress: () {
                      if (onLongPress != null) onLongPress!(items[index]);
                    },
                    child: ShortcutIconWidget(
                      url: items[index].url,
                      label: items[index].label,
                      icon: Container(
                        height: constraints.maxWidth * 0.15,
                        width: constraints.maxWidth * 0.15,
                        margin: EdgeInsets.only(bottom: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          boxShadow: kElevationToShadow[2],
                        ),
                        child: Text(
                          items[index].label[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

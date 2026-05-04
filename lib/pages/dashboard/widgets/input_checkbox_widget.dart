part of '../dashboard.dart';

class InputCheckboxWidget extends StatefulWidget {
  const InputCheckboxWidget({
    super.key,
    this.enabled = true,
    this.initialValue,
    this.onChanged,
    this.labelText,
  });

  final bool enabled;
  final bool? initialValue;
  final Function(bool isCheck)? onChanged;
  final String? labelText;

  @override
  State<InputCheckboxWidget> createState() => _InputCheckboxWidgetState();
}

class _InputCheckboxWidgetState extends State<InputCheckboxWidget> {
  ValueNotifier<bool> isCheckNotifier = ValueNotifier(false);

  void updateCheck() {
    if (!widget.enabled) return;

    isCheckNotifier.value = !isCheckNotifier.value;

    if (widget.onChanged != null) {
      widget.onChanged!(isCheckNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();
    isCheckNotifier.value = widget.initialValue ?? isCheckNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => updateCheck(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: isCheckNotifier,
            builder: (context, isCheck, child) {
              return Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                value: isCheck,
                onChanged: (value) => updateCheck(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(widget.labelText ?? ''),
          ),
        ],
      ),
    );
  }
}

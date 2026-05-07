part of '../dashboard.dart';

class InputTimeWidget extends StatefulWidget {
  const InputTimeWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.labelText,
  });

  final String? initialValue;
  final Function(String newValue)? onChanged;
  final String? labelText;

  @override
  State<InputTimeWidget> createState() => _InputTimeWidgetState();
}

class _InputTimeWidgetState extends State<InputTimeWidget> {
  ValueNotifier<String> currentValueNotifier = ValueNotifier('');

  void updateValue(String newValue) {
    currentValueNotifier.value = newValue;

    if (widget.onChanged != null) {
      widget.onChanged!(currentValueNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();

    currentValueNotifier.value =
        widget.initialValue ?? currentValueNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              widget.labelText ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ValueListenableBuilder(
          valueListenable: currentValueNotifier,
          builder: (context, currentValue, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (currentValue.isNotEmpty) ? currentValue : '--:--',
                ),
                ElevatedButton(
                  onPressed: () async {
                    int hour = 0;
                    int minute = 0;

                    if (currentValue.length == 5) {
                      try {
                        List<String> split = currentValue.split(':');

                        hour = int.tryParse(split[0]) ?? 0;
                        minute = int.tryParse(split[1]) ?? 0;
                      } catch (e) {
                        // Ignore error
                      }
                    }

                    TimeOfDay? selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: hour,
                        minute: minute,
                      ),
                    );

                    if (selected != null) {
                      String formattedTime =
                          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';

                      updateValue(formattedTime);
                    }
                  },
                  child: Text('Change'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

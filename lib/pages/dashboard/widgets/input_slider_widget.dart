part of '../dashboard.dart';

class InputSliderWidget extends StatefulWidget {
  const InputSliderWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.labelText,
    this.reversed = false,
  });

  final double? initialValue;
  final Function(double newValue)? onChanged;
  final String? labelText;
  final bool reversed;

  @override
  State<InputSliderWidget> createState() => _InputSliderWidgetState();
}

class _InputSliderWidgetState extends State<InputSliderWidget> {
  ValueNotifier<double> currentValueNotifier = ValueNotifier(1);

  void updateValue(double newValue) {
    currentValueNotifier.value = newValue;

    if (widget.onChanged != null) {
      widget.onChanged!(
        (widget.reversed)
            ? 1 - currentValueNotifier.value
            : currentValueNotifier.value,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    currentValueNotifier.value = (widget.reversed)
        ? (1 - (widget.initialValue ?? currentValueNotifier.value))
        : widget.initialValue ?? currentValueNotifier.value;
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
            return Slider(
              label: '${(currentValue * 100).round()}%',
              allowedInteraction: SliderInteraction.tapAndSlide,
              min: 0,
              max: 1,
              value: currentValue,
              divisions: 100,
              onChanged: (value) => updateValue(value),
            );
          },
        ),
      ],
    );
  }
}

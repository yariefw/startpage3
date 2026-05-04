part of '../dashboard.dart';

class InputTextWidget extends StatefulWidget {
  const InputTextWidget({
    super.key,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.style,
    this.keyboardType,
    this.maxLength,
    this.prefixText,
    this.obscureText = false,
  });

  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? prefixText;
  final bool obscureText;

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLengthEnforcement:
          (widget.maxLength != null) ? MaxLengthEnforcement.enforced : null,
      obscureText: widget.obscureText,
      textAlign: TextAlign.end,
      style: widget.style,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade200),
        prefixText: widget.prefixText,
        counter: SizedBox.shrink(),
      ),
    );
  }
}

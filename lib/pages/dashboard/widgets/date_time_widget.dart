part of '../dashboard.dart';

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({super.key});

  DateTime get now => DateTime.now();

  String get currentTime => DateFormat.jm().format(now);
  String get currentDate => DateFormat("EEEE, MMMM d").format(now);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currentTime,
          style: TextStyle(
            fontSize: 48,
            color: Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            currentDate,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}

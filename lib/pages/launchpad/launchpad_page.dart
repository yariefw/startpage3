part of 'launchpad.dart';

class LaunchpadPage extends StatelessWidget {
  static String route = '/';

  const LaunchpadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

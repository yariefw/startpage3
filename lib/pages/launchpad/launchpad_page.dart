part of 'launchpad.dart';

class LaunchpadPage extends StatefulWidget {
  static String route = '/';

  const LaunchpadPage({super.key});

  @override
  State<LaunchpadPage> createState() => _LaunchpadPageState();
}

class _LaunchpadPageState extends State<LaunchpadPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.pushReplacement(
        DashboardPage.route,
        extra: DashboardPageArgs(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black, child: SizedBox.shrink());
  }
}

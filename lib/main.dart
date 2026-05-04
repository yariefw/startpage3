import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:startpage/pages/dashboard/dashboard.dart';
import 'package:startpage/router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Homepage',
      routerConfig: GoRouter(
        initialLocation: DashboardPage.route,
        routes: [
          ShellRoute(
            routes: AppRouter.routes,
            builder: (context, state, child) => child,
          ),
        ],
      ),
    );
  }
}

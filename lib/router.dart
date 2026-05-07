import 'package:go_router/go_router.dart';
import 'package:startpage/pages/dashboard/dashboard.dart';
import 'package:startpage/pages/launchpad/launchpad.dart';

class AppRouter {
  static const _envConfigs = {
    'bookmarks_work': String.fromEnvironment('SC_BOOKMARKS_WORK'),
  };

  static List<GoRoute> get routes => [
        GoRoute(
          path: LaunchpadPage.route,
          builder: (context, state) => LaunchpadPage(),
        ),
        GoRoute(
          path: DashboardPage.route,
          builder: (context, state) => DashboardPage(
            args: DashboardPageArgs(
              envConfig: _envConfigs[state.uri.queryParameters['source']],
            ),
          ),
        ),
        ..._envConfigs.keys.map(
          (key) => GoRoute(
            path: '/$key',
            redirect: (context, state) => Uri(
              path: DashboardPage.route,
              queryParameters: {
                'source': key,
                ...state.uri.queryParameters,
              },
            ).toString(),
          ),
        ),
      ];
}

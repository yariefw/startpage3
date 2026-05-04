import 'package:go_router/go_router.dart';
import 'package:startpage/pages/dashboard/dashboard.dart';

class AppRouter {
  static const _envConfigs = {
    'bookmarks_work': String.fromEnvironment('SC_BOOKMARKS_WORK'),
  };

  static List<GoRoute> get routes => [
        GoRoute(
          path: DashboardLoadingPage.route,
          builder: (context, state) => DashboardLoadingPage(),
        ),
        GoRoute(
          path: DashboardPage.route,
          builder: (context, state) => DashboardPage(
            args: DashboardPageArgs(
              config: _envConfigs[state.uri.queryParameters['source']],
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

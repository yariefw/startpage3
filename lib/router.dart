import 'package:go_router/go_router.dart';
import 'package:startpage/pages/dashboard/dashboard.dart';
import 'package:web/web.dart' as web;

class AppRouter {
  static List<GoRoute> get routes => [
        GoRoute(
          path: DashboardPage.route,
          builder: (context, state) => DashboardPage(),
        ),
        GoRoute(
          path: '/bookmarks_work',
          redirect: (context, state) {
            const String scBookmarksWork =
                String.fromEnvironment('SC_BOOKMARKS_WORK');

            Uri parsed = Uri.parse(scBookmarksWork);

            Uri uriWithParams = parsed.replace(
              queryParameters: {
                ...parsed.queryParameters,
                ...state.uri.queryParameters,
              },
            );

            web.window.location.replace(uriWithParams.toString());
            return null;
          },
        ),
      ];
}

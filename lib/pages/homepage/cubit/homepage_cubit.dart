import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:startpage/config.dart';
import 'package:startpage/model/menu_item.dart';
import 'package:startpage/utility/encryption/aes_gcm.dart';
import 'package:universal_html/html.dart';

part 'homepage_state.dart';

class HomepageCubit extends Cubit<HomepageState> {
  HomepageCubit() : super(HomepageInitial());

  Future<void> loadConfig() async {
    try {
      // Display loading

      emit(HomepageLoading());

      // Declare config var

      String config = '';

      // Optionally use external config from url

      String configUrl = getUriParameter('config') ?? '';

      if (configUrl.isNotEmpty) {
        config = await getConfigFromOnline(configUrl);
      } else {
        config = await getConfigFromLocal();
      }

      // If config is encrypted, decode it

      String key = getUriParameter('key') ?? '';
      if (key.isNotEmpty) config = await AesGcm.decrypt(config, key: key);

      // Cast config String into Map

      Map<String, dynamic> data = jsonDecode(config);

      // Fill runtime vars based on config

      if (data.containsKey('fullname')) fullname = data['fullname'];
      if (data.containsKey('profile')) profile = data['profile'];
      if (data.containsKey('wallpaper')) wallpaper = data['wallpaper'];
      if (data.containsKey('bookmarks')) bookmarks = parseBookmarks(data);

      String workStart = '';
      String workFinish = '';

      if (data.containsKey('work_start')) workStart = data['work_start'];
      if (data.containsKey('work_finish')) workFinish = data['work_finish'];

      // Allow overriding from uri params

      fullname = getUriParameter('fullname') ?? fullname;
      profile = getUriParameter('profile') ?? profile;
      wallpaper = getUriParameter('wallpaper') ?? wallpaper;
      workStart = getUriParameter('work_start') ?? workStart;
      workFinish = getUriParameter('work_finish') ?? workFinish;

      // Decode work time

      int? workStartMinute;
      int? workStartHour;
      int? workFinishHour;
      int? workFinishMinute;

      if (workStart.isNotEmpty) {
        List<String> workStartSplit = workStart.split(':');
        workStartMinute = int.tryParse(workStartSplit[1]);
        workStartHour = int.tryParse(workStartSplit[0]);
      }

      if (workFinish.isNotEmpty) {
        List<String> workFinishSplit = workFinish.split(':');
        workFinishHour = int.tryParse(workFinishSplit[0]);
        workFinishMinute = int.tryParse(workFinishSplit[1]);
      }

      // Display page

      emit(HomepageLoaded(
        workStartHour: workStartHour,
        workStartMinute: workStartMinute,
        workFinishHour: workFinishHour,
        workFinishMinute: workFinishMinute,
      ));
    } catch (e) {
      // Display error

      emit(HomepageError(message: e.toString()));
    }
  }

  List<MenuItem> parseBookmarks(Map<String, dynamic> data) {
    List<MenuItem> jsonMenu = [];

    for (var item in data['bookmarks']) {
      MenuItem menuItem = menuItemFromJson(item);
      jsonMenu.add(menuItem);
    }

    return jsonMenu;
  }

  String? getUriParameter(String key) {
    Map<String, String> params = Uri.base.queryParameters;
    if (params.containsKey(key)) return params[key];
    return null;
  }

  Future<String> getConfigFromLocal() async {
    try {
      String config = 'config';

      bool isHasConfig = window.localStorage.containsKey(config);

      if (!isHasConfig) {
        String template = await loadStringFromAsset(
          'assets/json/config_sample.json',
        );

        window.localStorage[config] = template;
      }

      return window.localStorage[config] ?? '';
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getConfigFromOnline(String url) async {
    try {
      final String response = await http.read(Uri.parse(url));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> loadStringFromAsset(String key) => rootBundle.loadString(key);
}

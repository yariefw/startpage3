import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:startpage/helpers/helpers.dart';
import 'package:startpage/model/menu_item.dart';
import 'package:universal_html/html.dart' as html;

part 'dashboard_page.dart';
part 'dashboard_methods.dart';
part 'dashboard_loader_methods.dart';
part 'widgets/shortcut_category_display_widget.dart';
part 'widgets/shortcut_icon_widget.dart';
part 'widgets/interval_refresher_widget.dart';
part 'widgets/date_time_widget.dart';
part 'widgets/progress_bar_widget.dart';

part of '../dashboard.dart';

class ButtonSettingsWidget extends StatelessWidget {
  const ButtonSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.settings,
          color: Colors.grey,
          size: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({
    super.key,
    this.isFirstLoad = false,
    this.configuration,
    required this.bookmarksController,
    required this.bookmarksKeyController,
    required this.bookmarksKeySaveToLocal,
    required this.wallpaperUrlController,
    required this.wallpaperOpacity,
    required this.workStartController,
    required this.workFinishController,
  });

  final bool isFirstLoad;
  final DashboardConfigurationData? configuration;
  final TextEditingController bookmarksController;
  final TextEditingController bookmarksKeyController;
  final ValueNotifier<bool> bookmarksKeySaveToLocal;
  final TextEditingController wallpaperUrlController;
  final ValueNotifier<double> wallpaperOpacity;
  final TextEditingController workStartController;
  final TextEditingController workFinishController;

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  void initState() {
    super.initState();

    if (widget.configuration != null) {
      widget.bookmarksController.text = widget.configuration?.bookmarks ?? '';

      widget.bookmarksKeyController.text =
          widget.configuration?.bookmarksKey ?? '';

      widget.bookmarksKeySaveToLocal.value =
          widget.bookmarksKeyController.text.isNotEmpty;

      widget.wallpaperUrlController.text =
          widget.configuration?.wallpaperUrl ?? '';

      widget.wallpaperOpacity.value =
          widget.configuration?.wallpaperOpacity ?? 0.5;

      widget.workStartController.text = widget.configuration?.workStart ?? '';

      widget.workFinishController.text = widget.configuration?.workFinish ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isFirstLoad)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Bookmarks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: (!widget.isFirstLoad) ? 20 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InputTextWidget(
                        controller: widget.bookmarksController,
                        labelText: 'Data',
                      ),
                    ),
                    InputTextWidget(
                      controller: widget.bookmarksKeyController,
                      obscureText: true,
                      labelText: 'Encryption Key',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: InputCheckboxWidget(
                        labelText: 'Save Key',
                        initialValue: widget.bookmarksKeySaveToLocal.value,
                        onChanged: (isCheck) =>
                            widget.bookmarksKeySaveToLocal.value = isCheck,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isFirstLoad)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Wallpaper',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputTextWidget(
                          controller: widget.wallpaperUrlController,
                          labelText: 'Wallpaper Url',
                        ),
                        ValueListenableBuilder(
                          valueListenable: widget.wallpaperOpacity,
                          builder: (context, wallpaperOpacity, child) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputSliderWidget(
                                labelText: 'Wallpaper Opacity',
                                reversed: true,
                                initialValue: wallpaperOpacity,
                                onChanged: (newValue) =>
                                    widget.wallpaperOpacity.value = newValue,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!widget.isFirstLoad)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Work Time Progress Tracker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputTimeWidget(
                          labelText: 'Start Time (HH:mm)',
                          initialValue: widget.workStartController.text,
                          onChanged: (newValue) =>
                              widget.workStartController.text = newValue,
                        ),
                        SizedBox(height: 20),
                        InputTimeWidget(
                          labelText: 'Finish Time (HH:mm)',
                          initialValue: widget.workFinishController.text,
                          onChanged: (newValue) =>
                              widget.workFinishController.text = newValue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

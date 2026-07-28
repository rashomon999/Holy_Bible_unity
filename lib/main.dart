import 'package:flutter/material.dart';

import 'data/passage_repository.dart';
import 'l10n/strings.dart';
import 'services/settings.dart';
import 'ui/menu_page.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Settings.load();
  final repository = await PassageRepository.load();
  runApp(HolyBibleApp(settings: settings, repository: repository));
}

class HolyBibleApp extends StatelessWidget {
  const HolyBibleApp(
      {super.key, required this.settings, required this.repository});

  final Settings settings;
  final PassageRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: Strings.of(settings.lang)['appTitle'],
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        // El modo del sistema NO manda: si no, un teléfono en dark mode
        // mostraba la app casi negra. Manda lo que el usuario elija en Ajustes.
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: MenuPage(repository: repository, settings: settings),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/home/home_binding.dart';
import '../features/home/home_view.dart';
import 'theme.dart';

class VistaForexApp extends StatelessWidget {
  const VistaForexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VistaForex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialBinding: HomeBinding(),
      home: const HomeView(),
    );
  }
}

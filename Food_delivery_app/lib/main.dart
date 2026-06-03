import 'package:flutter/material.dart';
import 'package:khaanado/app_theme.dart';
import 'package:khaanado/provider/my_provider.dart';

import 'package:khaanado/screen/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KhaanaDo',
        theme: AppTheme.dark,
        home: const HomePage(),
      ),
    );
  }
}

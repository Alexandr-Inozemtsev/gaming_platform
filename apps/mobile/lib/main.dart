import 'package:flutter/material.dart';
import 'theme/tokens.dart';

void main() {
  runApp(const TabletopApp());
}

class TabletopApp extends StatelessWidget {
  const TabletopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabletopPlatform',
      theme: ThemeData(
        fontFamily: AppTokens.fontFamily,
        scaffoldBackgroundColor: AppTokens.bg,
        cardColor: AppTokens.card,
        colorScheme: ColorScheme.fromSeed(seedColor: AppTokens.accent)
      ),
      home: const HomePage()
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '[HOME] Continue • Play • Create • Store • Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTokens.accent)
        )
      )
    );
  }
}

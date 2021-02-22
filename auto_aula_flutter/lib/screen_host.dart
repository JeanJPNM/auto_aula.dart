import 'screens/home.dart';
import 'screens/settings.dart';
import 'package:flutter/material.dart';

class ScreenHost extends StatefulWidget {
  @override
  _ScreenHostState createState() => _ScreenHostState();
}

class _ScreenHostState extends State<ScreenHost> {
  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Auto Aula'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aulas'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Home(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}

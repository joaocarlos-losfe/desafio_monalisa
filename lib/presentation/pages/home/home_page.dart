import 'package:desafio_monalisa/presentation/pages/home/about_page.dart';
import 'package:desafio_monalisa/presentation/pages/home/help_page.dart';
import 'package:desafio_monalisa/presentation/pages/home/history_page.dart';
import 'package:desafio_monalisa/presentation/pages/home/import_data_page.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/sale_page.dart';
import 'package:desafio_monalisa/presentation/widgets/desktop_layout_widget.dart';
import 'package:desafio_monalisa/presentation/widgets/mobile_layout_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = const [
    SalePage(),
    HistoryPage(),
    ImportDataPage(),
    HelpPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth < 600
            ? MobileLayoutWidget(pages: _pages)
            : DesktopLayoutWidget(pages: _pages);
      },
    );
  }
}

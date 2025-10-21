import 'package:flutter/material.dart';

class MobileLayoutWidget extends StatefulWidget {
  final List<Widget> pages;
  const MobileLayoutWidget({super.key, required this.pages});

  @override
  State<MobileLayoutWidget> createState() => _MobileLayoutWidgetState();
}

class _MobileLayoutWidgetState extends State<MobileLayoutWidget> {
  int _selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: widget.pages[_selectedPageIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFFffa637),
        unselectedItemColor: Colors.white.withValues(alpha: 0.7),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 0,
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.history_outlined, 'Vendas', 1),
          _buildNavItem(Icons.download_outlined, 'Importar', 2),
          _buildNavItem(Icons.help_outline, 'Ajuda', 3),
          _buildNavItem(Icons.info_outline, 'Sobre', 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _selectedPageIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }
}

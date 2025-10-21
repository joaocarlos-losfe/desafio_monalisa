import 'package:flutter/material.dart';

class DesktopLayoutWidget extends StatefulWidget {
  final List<Widget> pages;
  const DesktopLayoutWidget({super.key, required this.pages});

  @override
  State<DesktopLayoutWidget> createState() => _DesktopLayoutWidgetState();
}

class _DesktopLayoutWidgetState extends State<DesktopLayoutWidget> {
  int _selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
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
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileHeader(),
                SizedBox(height: 30),
                Expanded(
                  child: Column(
                    children: [
                      _buildNavItem(Icons.home, 'Home', 0),
                      _buildNavItem(Icons.history, 'Histórico de vendas', 1),
                      _buildNavItem(Icons.download, 'Importar dados', 2),
                      _buildNavItem(Icons.help_outline, 'Ajuda', 3),
                      _buildNavItem(Icons.info_outline, 'Sobre', 4),
                      Spacer(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(width: 1, color: Colors.grey[300]),
          Expanded(child: widget.pages[_selectedPageIndex]),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/images/logo.png", scale: 2),
          Text(
            'Operador John Doe',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedPageIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedPageIndex = index;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Color(0XFFffa637)
                        : Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          SizedBox(height: 16),
          Text(
            'v1.0.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          Icon(
            Icons.logout,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}

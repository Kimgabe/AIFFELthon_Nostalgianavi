import 'package:flutter/material.dart';

class AppBarAlbum extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<int> onToggleChanged;

  AppBarAlbum({required this.title, required this.onToggleChanged});

  @override
  _AppBarAlbumState createState() => _AppBarAlbumState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarAlbumState extends State<AppBarAlbum> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF303742),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/nostalgianavi_logo.png'),
            ),
            SizedBox(width: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildToggleButton(0, 'Album'),
              _buildToggleButton(1, 'Map'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onToggleChanged(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black38 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
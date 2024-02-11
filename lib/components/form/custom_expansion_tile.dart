import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget children;

  const CustomExpansionTile(
      {super.key, required this.title, required this.children});

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: widget.title,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          trailing: _isExpanded
              ? const Icon(Icons.expand_less)
              : const Icon(Icons.expand_more),
        ),
        _isExpanded ? widget.children : const SizedBox.shrink(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'app_header_bar.dart';

class AppHeaderBarWithActions extends AppHeaderBar {
  static const _actionSpacing = 8.0;

  final List<Widget>? actions;

  const AppHeaderBarWithActions({
    super.key,
    super.title,
    super.titleStyle,
    super.leading,
    this.actions,
    super.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final actionList = actions;

    final trailing = <Widget>[];
    if (actionList != null && actionList.isNotEmpty) {
      trailing.add(const SizedBox(width: 8));
      for (var i = 0; i < actionList.length; i++) {
        if (i > 0) trailing.add(const SizedBox(width: _actionSpacing));
        trailing.add(actionList[i]);
      }
    }

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: buildTitleRow(trailing),
      bottom: bottom,
    );
  }
}
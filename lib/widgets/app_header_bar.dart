import 'package:flutter/material.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 20);
  static const _contentGap = 8.0;
  static const _actionSpacing = 8.0;

  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppHeaderBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final actionList = actions;
    final hasLeading = leading != null;

    // Saat ada leading (mis. icon arrow), padding kiri dihilangkan agar arrow
    // menempel di tepi layar dan title tidak terdorong terlalu jauh.
    final padding = hasLeading
        ? const EdgeInsets.only(right: 20)
        : _contentPadding;

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: padding,
        child: Row(
          children: [
            if (hasLeading) ...[
              leading!,
              const SizedBox(width: _contentGap),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
            if (actionList != null && actionList.isNotEmpty) ...[
              const SizedBox(width: _contentGap),
              for (var i = 0; i < actionList.length; i++) ...[
                if (i > 0) const SizedBox(width: _actionSpacing),
                actionList[i],
              ],
            ],
          ],
        ),
      ),
      bottom: bottom,
    );
  }
}
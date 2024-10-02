import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    required this.title,
    this.actions,
    this.centerTitle,
    super.key,
  });

  final List<Widget>? actions;
  final String title;
  final bool? centerTitle;

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: getGradientColors(context),
        ),
      ),
      title: Text(title),
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

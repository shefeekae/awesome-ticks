import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';

class BuildElevatedButton extends StatelessWidget {
  const BuildElevatedButton({
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    super.key,
  });

  final String title;
  final void Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const Center(
              child: LoadingIosAndroidWidget(),
            )
          : Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                // color: primaryAlt,
              ),
            ),
    );
  }
}

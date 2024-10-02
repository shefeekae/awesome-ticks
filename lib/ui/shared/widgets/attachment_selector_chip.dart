import 'package:awesometicks/ui/shared/models/file_selector_model.dart';
import 'package:flutter/material.dart';

class AttachmentSelectorChip extends StatelessWidget {
  const AttachmentSelectorChip({super.key, required this.fileSelectorModel});

  final FileSelectorModel fileSelectorModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => fileSelectorModel.onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            child: Image.asset(
              'assets/images/${fileSelectorModel.icon}.png',
              height: 24.0,
              width: 24.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(fileSelectorModel.title),
        ],
      ),
    );
  }
}

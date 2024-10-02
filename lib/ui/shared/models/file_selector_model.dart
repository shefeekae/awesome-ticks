/// model class for showing inside the attachment popUp with action buttons
class FileSelectorModel {
  final String title;
  final String icon;
  final Function onTap;

  FileSelectorModel({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

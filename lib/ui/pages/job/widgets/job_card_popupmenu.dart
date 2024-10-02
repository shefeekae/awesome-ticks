import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../../core/services/jobs/jobs_services.dart';

class JobCardPopmenuButton extends StatelessWidget {
  const JobCardPopmenuButton({
    super.key,
    this.popupMenuItems = const [],
    required this.jobId,
    required this.filePath,
  });

  final int jobId;
  final String filePath;
  final List<PopupMenuItem> popupMenuItems;

  @override
  Widget build(BuildContext context) {
    return PermissionChecking(
      featureGroup: "jobManagement",
      feature: "job",
      permission: "jobCard",
      child: PopupMenuButton(
        icon: const Icon(Icons.download),
        itemBuilder: (context) {
          return [
            buildPopmenuItem(
              context,
              fileType: "PDF",
              iconData: Icons.picture_as_pdf,
              label: "Job Card Pdf",
            ),
            buildPopmenuItem(
              context,
              fileType: "EXCEL",
              iconData: Icons.file_open,
              label: "Job Card Excel",
            ),
          ];
        },
      ),
    );
  }

  // ======================================================================================
  // Showing the pop up menu button item

  PopupMenuItem buildPopmenuItem(
    BuildContext context, {
    String? fileType,
    required IconData iconData,
    required String label,
    void Function()? onTap,
  }) {
    return PopupMenuItem(
      onTap: onTap ??
          () {
            JobsServices().openJobCard(
              jobId,
              fileType: fileType ?? "",
              context: context,
            );
          },
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.grey,
          ),
          SizedBox(
            width: 5.sp,
          ),
          Text(
            label,
          ),
        ],
      ),
    );
  }
}

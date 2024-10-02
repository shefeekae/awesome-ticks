import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sizer/sizer.dart';

class ChecklistProgressBar extends StatelessWidget {
  const ChecklistProgressBar({
    super.key,
    required this.checklistLength,
    required this.isAssetChecklist,
  });

  final int checklistLength;
  final bool isAssetChecklist;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobManagementBloc, JobManagementState>(
      builder: (context, state) {
        int completed;

        // int total = checkLists.length;

        if (isAssetChecklist) {
          completed = state.assetChecklistCompleted;
        } else {
          completed = state.completed;
        }

        double widthFactor =
            checklistLength == 0 ? 0 : completed / checklistLength;

        // print("PERCENT : $widthFactor");

        return LinearPercentIndicator(
          width: 90.w,
          animation: true,
          lineHeight: 10.sp,
          animationDuration: 500,
          percent: widthFactor,
          barRadius: Radius.circular(5.sp),
          animateFromLastPercent: true,
          backgroundColor: Colors.grey.shade300,
          progressColor: Colors.green,
        );
      },
    );
  }
}
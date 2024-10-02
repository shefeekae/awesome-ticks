import 'package:app_filter_form/app_filter_form.dart';
// import 'package:awesometicks/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:awesometicks/core/blocs/pagination%20controller/pagination_controller_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/models/listalljobsmodel.dart';
import '../../../../core/services/jobs/jobs_services.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../job/job_details.dart';
import 'job_card.dart';

class JobListviewBuilder extends StatefulWidget {
  const JobListviewBuilder({
    super.key,
    // required this.list,
    required this.setState,
    this.removePagination = false,
    this.padding,
  });

  // final List<Items> list;

  final StateSetter setState;
  final EdgeInsetsGeometry? padding;
  final bool removePagination;

  // final List<String> status;

  @override
  State<JobListviewBuilder> createState() => _JobListviewBuilderState();
}

class _JobListviewBuilderState extends State<JobListviewBuilder> {
  ScrollController scrollController = ScrollController();

  void _onScroll() {
    bool paginationCompleted = paginationControllerBloc.state.isCompleted;

    if (!paginationCompleted) {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // _fetchMoreData();
        JobsServices().listAlljobsWithPagination(
          paginationControllerBloc: paginationControllerBloc,
          payloadManagementBloc: payloadManagementBloc,
        );
        // print("scroll end");
      }
    }
  }

  late PayloadManagementBloc payloadManagementBloc;
  late PaginationControllerBloc paginationControllerBloc;

  @override
  void initState() {
    if (!widget.removePagination) {
      payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);
      paginationControllerBloc =
          BlocProvider.of<PaginationControllerBloc>(context);
      scrollController.addListener(_onScroll);
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationControllerBloc, PaginationControllerState>(
      builder: (context, state) {
        List<Items> list = state.result as List<Items>;

        bool completed = state.isCompleted;

        return ListView.separated(
          padding: widget.padding,
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.removePagination
              ? list.length
              : list.length +
                  (completed
                      ? 0
                      : list.length <= 9
                          ? 0
                          : 1),
          itemBuilder: (context, index) {
            if (list.length > index) {
              Items item = list[index];

              return BuildJobCardWidget(
                item: item,
                onPressed: () async {
                  await Navigator.of(context).pushNamed(
                    JobDetailsScreen.id,
                    arguments: {
                      "jobId": item.id,
                    },
                  );

                  widget.setState(
                    () {},
                  );
                },
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: const LoadingIosAndroidWidget(),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7.sp,
            );
          },
        );
      },
    );
  }
}

import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/parts/parts_quantity_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/models/parts_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/main.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobDetailsRepository {
  final GraphqlServices graphqlServices = GraphqlServices();
  final JobsServices jobsServices = JobsServices();

  Future<QueryResult> fetchJobDetails({
    required int jobId,
    required bool isFirstTimeCall,
  }) async {
    var result = await graphqlServices
        .performQuery(query: JobsSchemas.findJobWithId, variables: {
      "jobId": jobId,
    });

    JobDetailsModel jobDetailsModel =
        jobDetailsModelFromJson(result.data ?? {});

    BuildContext? context = MyApp.navigatorKey.currentContext;

    if (context != null && context.mounted) {
      PartsQuantityBloc partsQuantityBloc = context.read<PartsQuantityBloc>();
      TimelineUpdateBloc timelineUpdateBloc =
          context.read<TimelineUpdateBloc>();
      JobControllerBlocBloc jobControllerBloc =
          context.read<JobControllerBlocBloc>();

      var job = jobDetailsModel.findJobWithId;

      String jobStatus = job?.status ?? "";

      jobControllerBloc.state.jobStatus = jobStatus;
      jobControllerBloc.state.actualStartTime = job?.actualStartTime;
      jobControllerBloc.state.actualEndTime = job?.actualEndTime;

      List transitions = jobDetailsModel.findJobWithId?.transitions ?? [];

      List timeLines = [
        {
          "time": job?.requestTime ?? 0,
          "status": "REGISTERED",
          "comment": "Job Created",
        },
        ...transitions.map(
          (e) {
            return {
              "time": e['transitionTime'] ?? e['time'],
              "status": e['currentStatus'] ?? e['status'],
              "comment": e['transitionComment'] ?? e['comment'],
            };
          },
        ).toList(),
      ];

      timelineUpdateBloc.state.timelines = timeLines;

      List parts = jobDetailsModel.findJobWithId?.parts ?? [];

      for (var element in parts) {
        element.remove("__typename");
      }

      partsQuantityBloc.state.localParts =
          parts.map((e) => PartsModel.fromJson(e)).toList();

      partsQuantityBloc.state.partsList = parts;
    }

    if (isFirstTimeCall) {
      var job = jobDetailsModel.findJobWithId;

      String jobDomain = jobDetailsModel.findJobWithId?.domain ?? "";

      String? serviceRequestNumber = job?.serviceRequest?.isNotEmpty == true
          ? job!.serviceRequest!.first.requestNumber
          : "";

      jobsServices.addJobAttachmentsToBlocState(
        jobAttachmentFilePath: "jobs/$jobDomain/$jobId",
        attachmentCategoryKey: "",
        serviceRequestAttachmentFilePath: serviceRequestNumber == null
            ? null
            : "serviceRequests/$jobDomain/$serviceRequestNumber",
      );
    }

    return result;
  }
}

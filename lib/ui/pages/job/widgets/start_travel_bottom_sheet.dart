// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:app_filter_form/shared/widgets/custom_elevated_button.dart';
import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/models/team_members_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/ui/pages/job/functions/time_counter.dart';
import 'package:awesometicks/ui/pages/job/widgets/travel_type_selection_button.dart';
import 'package:track_location/track_location.dart';

class StartTravelBottomSheet extends StatefulWidget {
  const StartTravelBottomSheet({
    Key? key,
    // required this.startTravelService,
    required this.domain,
    required this.members,
    required this.assignee,
    required this.jobId,
    required this.hasTravelTimeIncluded,
  }) : super(key: key);

  // final ScrollController scrollController;

  final int jobId;
  // final StartTravelService startTravelService;
  final String domain;
  final List<dynamic> members;
  final Assignee? assignee;
  final bool hasTravelTimeIncluded;

  @override
  State<StartTravelBottomSheet> createState() => _StartTravelBottomSheetState();
}

class _StartTravelBottomSheetState extends State<StartTravelBottomSheet> {
  ValueNotifier<TravelType> selectedValueNotifier =
      ValueNotifier<TravelType>(TravelType.withTeam);

  ValueNotifier<bool> selectAllNotifier = ValueNotifier(true);

  UserDataSingleton userData = UserDataSingleton();

  TrackLocation trackLocation = TrackLocation();

  final JobsActionService jobsActionService = JobsActionService();

  // List<TeamMember> selectedTeamMembers = [];

  ValueNotifier<List<TeamMember>> teamMemberNotifier =
      ValueNotifier<List<TeamMember>>([]);

  late TravelTimeBloc travelTimeBloc;
  late JobControllerBlocBloc jobControllerBlocBloc;
  late TimelineUpdateBloc timelineUpdateBloc;
  late ActionButtonLoadingBloc actionButtonLoadingBloc;

  @override
  void initState() {
    travelTimeBloc = BlocProvider.of<TravelTimeBloc>(context);
    jobControllerBlocBloc = BlocProvider.of<JobControllerBlocBloc>(context);
    timelineUpdateBloc = BlocProvider.of<TimelineUpdateBloc>(context);
    actionButtonLoadingBloc = BlocProvider.of<ActionButtonLoadingBloc>(context);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleSelectAll(bool value) {
    teamMemberNotifier.value = teamMemberNotifier.value
        .map((e) => TeamMember(
            name: e.name, memberDetails: e.memberDetails, isChecked: value))
        .toList();

    selectAllNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedValueNotifier,
        builder: (context, travelType, _) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Start travel ?",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 15.sp,
                  ),
                  Text(
                    travelType == TravelType.alone
                        ? "I am travelling alone"
                        : "I am travelling with my team",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                  SizedBox(
                    height: 15.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TravelTypeSelectionButton(
                        icon: Icons.person,
                        title: "Alone",
                        isSelected: travelType == TravelType.alone,
                        onPressed: () {
                          selectedValueNotifier.value = TravelType.alone;
                          teamMemberNotifier.value = [];
                        },
                        value: travelType,
                      ),
                      TravelTypeSelectionButton(
                        icon: Icons.groups,
                        title: "With team",
                        isSelected: travelType == TravelType.withTeam,
                        value: travelType,
                        onPressed: () {
                          selectedValueNotifier.value = TravelType.withTeam;
                          toggleSelectAll(true);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.sp,
                  ),
                  Visibility(
                      visible: travelType == TravelType.withTeam,
                      child: QueryWidget(
                        options: GraphqlServices().getQueryOptions(
                          query: JobsSchemas.listAllAssigneesUnPaged,
                          rereadPolicy: true,
                          variables: {
                            "domain": widget.domain,
                            "type": "Mechanic"
                          },
                        ),
                        builder: (result, {fetchMore, refetch}) {
                          if (result.isLoading) {
                            return Flexible(
                              child: BuildShimmerLoadingWidget(
                                itemCount: 3,
                                height: 30.sp,
                              ),
                            );
                          }

                          if (result.hasException) {
                            return GraphqlServices().handlingGraphqlExceptions(
                              result: result,
                              context: context,
                              refetch: refetch,
                            );
                          }

                          // List teamMemberList =
                          //     result.data?['listAllAssigneesUnPaged']
                          //             ?['items'] ??
                          //         [];

                          TeamMembersDataModel teamMembersDataModel =
                              TeamMembersDataModel.fromJson(result.data ?? {});

                          List<Items> teamMemberList = teamMembersDataModel
                                  .listAllAssigneesUnPaged?.items ??
                              [];

                          List jobTeamMembers = widget.members.map(
                            (e) {
                              return e['assignee']['id'];
                            },
                          ).toList();

                          jobTeamMembers.add(widget.assignee?.id);

                          /// This method filters the assignee list with job team members
                          List<Items> filteredTeamMemberList =
                              teamMemberList.where(
                            (element) {
                              return jobTeamMembers.contains(element.id);
                            },
                          ).toList();

                          /// This method filters out the current logged in user from the list
                          filteredTeamMemberList =
                              filteredTeamMemberList.where((e) {
                            return e.id != userData.userId;
                          }).toList();

                          if (filteredTeamMemberList.isEmpty) {
                            return const Text(
                              "No team members are assigned",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }

                          /// Converts to TeamMember model class
                          List<TeamMember> teamMembers =
                              filteredTeamMemberList.map(
                            (e) {
                              return TeamMember(
                                name: e.name ?? "",
                                memberDetails: e,
                              );
                            },
                          ).toList();

                          teamMemberNotifier.value = teamMembers;

                          return ValueListenableBuilder(
                              valueListenable: selectAllNotifier,
                              builder: (context, selectAll, child) {
                                return Flexible(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        CheckboxListTile.adaptive(
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          secondary: const CircleAvatar(
                                              child: Icon(Icons.groups)),
                                          title: const Text("All team members"),
                                          value: selectAll,
                                          onChanged: (value) {
                                            if (value == null) {
                                              return;
                                            }
                                            toggleSelectAll(value);
                                          },
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable: teamMemberNotifier,
                                            builder: (context, teamMembers, _) {
                                              return ListView.separated(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    TeamMember teamMember =
                                                        teamMembers[index];

                                                    return CheckboxListTile
                                                        .adaptive(
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                      secondary:
                                                          const CircleAvatar(
                                                              child: Icon(Icons
                                                                  .person)),
                                                      subtitle: Text(teamMember
                                                              .memberDetails
                                                              .contactNumber ??
                                                          ""),
                                                      title:
                                                          Text(teamMember.name),
                                                      value:
                                                          teamMember.isChecked,
                                                      onChanged: (value) {
                                                        if (value == null) {
                                                          return;
                                                        }

                                                        teamMembers[index]
                                                            .isChecked = value;

                                                        teamMemberNotifier
                                                                .value =
                                                            List.from(
                                                                teamMembers);

                                                        if (teamMemberNotifier
                                                            .value
                                                            .every(
                                                          (element) =>
                                                              element
                                                                  .isChecked ==
                                                              true,
                                                        )) {
                                                          selectAllNotifier
                                                              .value = true;
                                                        }

                                                        if (value == false) {
                                                          selectAllNotifier
                                                              .value = false;
                                                        }

                                                        if (value) {
                                                          // selectedTeamMembers.add(
                                                          //     "${teamMember.name}@${userData.domain}");
                                                        } else {
                                                          // selectedTeamMembers.remove(
                                                          //     "${teamMember.name}@${userData.domain}");
                                                        }
                                                      },
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(
                                                            height: 5.sp,
                                                          ),
                                                  itemCount:
                                                      teamMembers.length);
                                            }),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      )),
                  SizedBox(
                    height: 15.sp,
                  ),
                  MutationWidget(
                      options: GrapghQlClientServices().getMutateOptions(
                          onCompleted: (data) {
                            if (data == null) {
                              actionButtonLoadingBloc.add(
                                  ActionButtonIsLoadingEvent(isLoading: false));
                              if (context.mounted) {
                                buildSnackBar(
                                    context: context,
                                    value:
                                        "Something went wrong. Please try again");
                                Navigator.of(context).pop();
                              }
                              return;
                            }

                            DateTime now = DateTime.now();

                            JobsActionService.callTravelTimeSheetApi(
                                travelTimeBloc: travelTimeBloc,
                                jobId: widget.jobId);

                            String jobStatus =
                                jobControllerBlocBloc.state.jobStatus;

                            if (travelTimeBloc.isWorkLogsIsEmpty &&
                                jobStatus != "COMPLETED" &&
                                jobStatus != "CLOSED") {
                              if (widget.hasTravelTimeIncluded == true) {
                                jobControllerBlocBloc.add(
                                  ChangeJobStatusEvent(status: "INPROGRESS"),
                                );

                                timelineUpdateBloc.add(
                                  TimeLineChangeEvent(
                                    timeline: {
                                      "time": now.millisecondsSinceEpoch,
                                      "status": "INPROGRESS",
                                    },
                                  ),
                                );
                              }
                            }
                            actionButtonLoadingBloc.add(
                                ActionButtonIsLoadingEvent(isLoading: false));
                            Navigator.of(context).pop();
                          },
                          document: JobsSchemas.startTrip,
                          context: context),
                      builder: (runMutation, result) {
                        return BuildElevatedButton(
                          isMobile: true,
                          isLoading: result?.isLoading ?? false,
                          onPressed: () async {
                            actionButtonLoadingBloc.add(
                                ActionButtonIsLoadingEvent(isLoading: true));

                            DateTime now = DateTime.now();

                            var locationMap = await trackLocation
                                .getCurrentLocationAndLocationName(context);

                            runMutation({
                              "data": {
                                "startTime": now.millisecondsSinceEpoch,
                                "startLocationName":
                                    locationMap["locationName"],
                                // "endLocationName": "kunnamkulam",
                                "tripPurpose": "TO_WORK",
                                "startLocation": locationMap["location"],
                                // "endLocation": "POINT(1232323,2323123)",
                                "jobId": widget.jobId,
                                "assignees": [
                                  "${userData.identifier}@${userData.domain}",
                                  ...teamMemberNotifier.value
                                      .where((e) => e.isChecked)
                                      .map((e) =>
                                          "${e.memberDetails.referenceId}")
                                      .toList()
                                ]
                              }
                            });

                            // jobsActionService.startTravelApiCall(context,
                            //     jobId: widget.jobId,
                            //     travelTimeBloc: travelTimeBloc,
                            //     timelineUpdateBloc: timelineUpdateBloc,
                            //     jobControllerBlocBloc: jobControllerBlocBloc,
                            //     hasTravelTimeIncluded:
                            //         widget.hasTravelTimeIncluded,
                            //     actionButtonLoadingBloc: );
                          },
                          title: "Confirm",
                        );
                      }),
                  SizedBox(
                    height: 15.sp,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class TeamMember {
  final String name;
  bool isChecked;
  Items memberDetails;

  TeamMember({
    required this.name,
    required this.memberDetails,
    this.isChecked = true,
  });
}

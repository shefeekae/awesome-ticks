import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SyncProgressScren extends StatelessWidget {
  SyncProgressScren({super.key});

  static const String id = "sync/progress";

  List<Map> list = [
    {
      "title": "Pool cleaning job started on May 2 2023 11:00 PM",
      "reason": "Job Alreay started"
    },
    {
      "title": "Pool cleaning job holded on May 2 2023 12:00 PM",
      "reason": "Job Alreay started"
    },
    {
      "title": "Pool cleaning job closed on May 2 2023 5:00 Pm",
      "reason": "Job Alreay started"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Pending"),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          Map map = list[index];

          String title = map['title'];
          String reason = map['reason'];

          return Column(
            children: [
              Row(
                children: [Text(title), Spacer(), Text("10:00 AM")],
              ),
              Row(
                children: [
                  Text(reason),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sync,
                      // color: Colors.green,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete,
                      // color: Colors.red,
                    ),
                  ),
                ],
              )
            ],
          );

          // return ListTile(
          //   isThreeLine: true,
          //   title: Text(title),
          //   subtitle: Text(reason),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.sync,
          //           // color: Colors.green,
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: Icon(
          //           Icons.delete,
          //           // color: Colors.red,
          //         ),
          //       )
          //     ],
          //   ),
          // );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
              // height: 10.sp,
              );
        },
        itemCount: list.length,
      ),
    );
  }
}

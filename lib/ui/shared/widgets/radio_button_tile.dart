//  // =============================================================================
//   // Return radio butotn listTile,

//   import 'package:flutter/material.dart';

// import '../../../core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// import '../../../core/models/filter_value_model.dart';
// import '../../../utils/themes/colors.dart';

// RadioListTile<int> buildRadiobuttonListTile({
//     required String name,
//     required int index,
//     required int? groupValue,
//     required String identifier,
//     required String key,
//     required FilterSelectionBloc filterSelectionBloc,
//   }) {
//     return RadioListTile(
//       activeColor: primaryColor,
//       title: Text(name),
//       value: index,
//       groupValue: groupValue,
//       onChanged: (value) {
//         SelectedValue selectedValue = SelectedValue(
//           name: name,
//           identifier: identifier,
//         );
//         filterSelectionBloc.add(AddRadioButtonValueEvent(
//           selectedValue: selectedValue,
//           key: key,
//         ));
//       },
//     );
//   }
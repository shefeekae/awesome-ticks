
// ignore_for_file: public_member_api_docs, sort_constructors_first
class CheckListModel {
  String title;
  bool checkable;
  bool choiceType;
  List<String> choiceTypes;
  
  CheckListModel({
    required this.title,
    required this.checkable,
    required this.choiceType,
    required this.choiceTypes,
  });
}

class UserSchema {
  static const String findAssigneeQuery = '''
query findAssignee(\$id: String!){
  findAssignee(id:\$id)
}
''';

  static const String forgetPasswordQuery = '''
mutation forgotPassword(\$userDetails: JSON) {
  forgotPassword(userDetails: \$userDetails)
}
''';
}

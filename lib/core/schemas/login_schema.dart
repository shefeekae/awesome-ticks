class LoginSchema {
  static String getLoginJson = """
query login(\$credentials: JSON,\$isDevMode : Boolean,\$origin : String){
  login(credentials : \$credentials, isDevMode : \$isDevMode, origin : \$origin)
}
""";

// ===============================================================================

  static String refreshtoken = """
query refresh(\$refreshToken : String!,\$origin : String!){
   refresh(refreshToken : \$refreshToken, origin : \$origin)
}
""";

}

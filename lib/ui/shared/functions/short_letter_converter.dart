  String shortLetterConverter(String userName) {
   return  userName.contains("@")
        ? '${userName.split("@")[0][0].toUpperCase()}${userName.split("@")[1][0].toUpperCase()}'
        : userName.contains(" ")
            ? '${userName.split(" ")[0][0].toUpperCase()}${userName.split(" ")[1][0].toUpperCase()}'
            : '${userName[0].toUpperCase()}${userName.length == 1 ? "" : userName[1].toUpperCase()}';
  }
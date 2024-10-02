

bool areArraysEqual(List<dynamic> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false; // Lists have different lengths, so they can't be equal
  }

  for (int i = 0; i < list1.length; i++) {
    bool contains = list1.any((element) => element == list2[i]);

    if (!contains) {
      return false;
    }
  }

  return true; // All elements are equal
}

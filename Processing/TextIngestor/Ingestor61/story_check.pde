//
boolean isStory(String s) {
  // for 1961 the story line will start with a series of odd characters
  boolean isStory = false;
  int oddCharCount = 0;
  for (int i = 0; i < s.length(); i++) {
    if (isOddChar(s.charAt(i))) oddCharCount++;
  }
  if (oddCharCount > (float)s.length() / 2) isStory = true;
  return isStory;
} // end isStory

//
String stripStoryStuff(String[] broken, boolean isDateStory) {
  String cleanStoryString = "";
  if (!isDateStory) {
    for (int i = 1; i < broken.length; i++) {
      cleanStoryString += broken[i] + " ";
    }
  }
  else {
    for (int j = 1; j < broken.length - 1; j++) {
      if (!stringContainsNumber(broken[j])) {
        for (int i = j; i < broken.length; i++) {
          cleanStoryString += broken[i] + " ";
        }
        break;
      }
    }
  }
  return cleanStoryString;
} // end stripStoryStuff


//
boolean stringContainsNumber(String s) {
  int num = 0;
  for (int i = 0; i < s.length(); i++) {
    num = s.charAt(i);
    if (num <= 57 && num >= 48) return true;
  }
  return false;
} // end stringContainsNumber
//
//
//
//


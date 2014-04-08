//
boolean isStory(String s) {
  // for 1964 the story line will start with a series of odd characters
  boolean isStory = false;
  int oddCharCount = 0;
  for (int i = 0; i < s.length(); i++) {
    if (isOddChar(s.charAt(i))) oddCharCount++;
  }
  if (oddCharCount > (float)s.length() / 2) isStory = true;
  // check for a dot: •
  if (s.contains("•")) isStory = true;
  return isStory;
} // end isStory

//
String stripStoryStuff(String[] broken, boolean isDateStory) {
  String cleanStoryString = "";
  String joined = join(broken, " ");
  if (!isDateStory) {
    // clean away all odd characters, then add that substring
    int cleanIndex = 0;
    for (int i = 1; i < joined.length(); i++) {
      if (isNormalChar(joined.charAt(i))) {
        cleanIndex = i - 1;
        break;
      }
    }
    try {
      cleanStoryString += joined.substring(cleanIndex) + " ";
    }
    catch (Exception e) {
    }
  }
  else {
    int cleanIndex = 0;
    for (int j = 0; j < broken.length - 1; j++) {
      boolean foundNumber = false;
      boolean foundMonth = false;
      String a = broken[j].toLowerCase().trim();
      String b = broken[j + 1].toLowerCase().trim();
      if (isMonth(a)) {
        foundMonth = true;
        try {
          int dayCheck = Integer.parseInt(b);
          if (dayCheck >= 1 && dayCheck <= 32) foundNumber = true;
        }
        catch (Exception e) {
        }
      }
      else if (isMonth(b)) {
        foundMonth = true;
        try {
          int dayCheck = Integer.parseInt(b);
          if (dayCheck >= 1 && dayCheck <= 32) foundNumber = true;
        }
        catch (Exception e) {
        }
      }
      if (foundMonth && foundNumber) {
        cleanIndex = j + 2;
        break;
      }
    }


    for (int j = cleanIndex; j < broken.length; j++) {
      cleanStoryString += broken[j] + " ";
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


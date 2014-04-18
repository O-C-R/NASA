//
String cleaner(String s) {
  String newString = "";
  boolean lastCharWasOdd = false;
  for (int i = 0; i < s.length(); i++) {
    if (!isOddChar(s.charAt(i))) {
      boolean nextCharIsOdd = false;
      if (i < s.length() - 1) {
        if (isOddChar(s.charAt(i + 1))) nextCharIsOdd = true;
      }
      if (lastCharWasOdd && nextCharIsOdd) {
        
      }
      else {
        newString += s.charAt(i);
        lastCharWasOdd = false;
      }
    } 
    else {
      lastCharWasOdd = true;
    }
  }
  return newString.trim();
} // end cleaner


//
boolean isOddChar(char c) {
  int value = c;
  if (value >= 32 && value <= 127) return false;
  return true;
} // end isOddChar

//
boolean isNormalChar(char c) {
  int value = c;
  if (value >= 34 && value <= 122) return true; // from ! to z, skipping space 
  return false;
} // end isOddChar

//
boolean isRestrictedOddChar(char c) {
  int value = c;
  if (value >= 48 && value <= 122) return false;
  return true;
} // end isRestrictedOddChar

//
boolean charIsNumber(char c) {
  int value = c;
  if (value >= 48 && value <= 57) return true;
  return false;
} // end charIsNumber

// 
boolean charIsLetter(char c) {
  int value = c;
  if (value >= 65 && value <= 90) return true;
  if (value >= 97 && value <= 122) return true;
  return false;
} // end charIsLetter

//
// this will take out weird chars like • or ªº£¶¢
String cleanOddCharsOut(String s) {
  String clean = "";
  for (int i = 0; i < s.length(); i++) {
    if (!isRestrictedOddChar(s.charAt(i))) clean += s.charAt(i);
  }
  return clean;
} // end cleanOddCharsOut
//
//
//
//


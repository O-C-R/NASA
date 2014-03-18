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
//
//
//


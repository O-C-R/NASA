class Story {  
  String month = "";
  int monthNumber = 0;
  int day = 0;
  String cleanString = "";
  String[] cleanStringArray = new String[0];
  String[] rawLines = new String[0];

  //
  Story(String month, int day) {
    this.month = month;
    this.day = day;
    this.monthNumber = getMonthNumber(month);
  } // end constructor


  void addRawString(String s) {
    rawLines = (String[])append(rawLines, s.trim());
  } // end addRawString

  //
  void makeCleanString() {
    boolean fixDash = false;
    for (String s : rawLines) {
      s = s.trim();
      boolean endsInDash = s.charAt(s.length() - 1) == '-';
      String[] broken = splitTokens(s, " ");
      for (int i = 0; i < broken.length; i++) {
        if (!fixDash || i > 0) cleanString += " ";
        if (endsInDash) if (i == broken.length - 1) broken[i] = broken[i].replace("-", "");
        cleanString += broken[i];
      }
      if (endsInDash) fixDash = true;
      else fixDash = false;
    }
    cleanStringArray = splitTokens(cleanString, " ");
  } // end makeCleanString

    //
  void setText(String s, boolean hasDate) {
    if (!hasDate) {
      if (s.charAt(0) == '*') {
        cleanString = s.substring(1).trim();
      }
    }
    else {
      for (int c = 0; c < s.length(); c++) {
        if (s.charAt(c) == ':') {
          cleanString = s.substring(c + 1).trim();
          break;
        }
      }
    }
  } // end setText

  //
  void assignParentheticals() {
    int refNumber = getReferenceNumber(cleanString);

    if (refNumber > 0) {
      String proposedReference = "" + refNumber;
      try {
        int parentheticalReference = Integer.parseInt(proposedReference);
        cleanString = cleanString.substring(0, cleanString.length() - proposedReference.length());
        if (parentheticals.containsKey(parentheticalReference)) {
          cleanString += "(" + (String)parentheticals.get(parentheticalReference) + ")";
        }
      }
      catch (Exception l) {
      }
    }
  } // end assignParentheticals

  // 
  boolean alreadyEndsInReference() {  
    if(rawLines.length > 0) if (getReferenceNumber(rawLines[rawLines.length - 1]) > 0) return true;
    return false;
  } // end alreadyEndsInReference

    //
  int getReferenceNumber(String s) {
    int parentheticalReference = -1;
    String proposedReference = "";
    for (int i = s.length() - 1; i >= 0; i--) {
      int value = s.charAt(i);
      if (value >= 48 && value <= 57) {
        proposedReference = s.charAt(i) + proposedReference;
      }
      else break;
    }
    if (proposedReference.length() > 0) {
      try {
        parentheticalReference = Integer.parseInt(proposedReference);
      }
      catch (Exception o) {
      }
    }
    return parentheticalReference;
  } // end getReferenceNumber

  //
  String toString() {
    String builder = month + " " + day + "\n";
    builder += cleanString + "\n";
    //for (String s : rawLines) builder += s + "\n";
    return builder;
  } // end toString

  //
  JSONObject getJSONObject() {
    JSONObject output = new JSONObject();
    output.setString("month", month);
    output.setInt("day", day);
    output.setInt("monthNumber", monthNumber);
    output.setString("story", cleanString);
    return output;
  } // end getJSONObject
} // end class Story


//
//
//
//
//
//
//
//


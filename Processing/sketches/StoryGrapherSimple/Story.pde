class Story {  
  String month = "";
  int monthNumber = 0;
  int day = 0;
  String story = "";
  Year year;

  //
  Story(String month, int day, int monthNumber, String story) {
    this.month = month;
    this.day = day;
    this.monthNumber = monthNumber;
    this.story = story;
  } // end constructor

  //
  Story(JSONObject json, Year year) {
    this.month = json.getString("month");
    this.day = json.getInt("day");
    this.monthNumber = json.getInt("monthNumber");
    this.story = json.getString("story").trim();
    this.year = year;
  } // end constructor

  //
  String toString() {
    String builder = month + " " + day + ", " + year.year + "\n";
    builder += story + "\n";
    return builder;
  } // end toString

  //
  JSONObject getJSONObject() {
    JSONObject output = new JSONObject();
    output.setString("month", month);
    output.setInt("day", day);
    output.setInt("monthNumber", monthNumber);
    output.setString("story", story);
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


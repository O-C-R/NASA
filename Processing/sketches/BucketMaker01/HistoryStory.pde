class HistoryStory {  
  String month = "";
  int monthNumber = 0;
  int day = 0;
  String story = "";
  Calendar cal = null;
  int year = 0;

  int id = 0;

  color c = color(random(255), random(255), random(255));
  
  IntDict ngrams = new IntDict();
  ArrayList<Bucket> buckets = new ArrayList<Bucket>();
  

  //
  HistoryStory(String month, int day, int monthNumber, String story) {
    this.month = month;
    this.day = day;
    this.monthNumber = monthNumber;
    this.story = story;
  } // end constructor

  //
  HistoryStory(JSONObject json, int year) {
    this.month = json.getString("month");
    this.day = json.getInt("day");
    this.monthNumber = json.getInt("monthNumber");
    this.year = year;
    this.story = json.getString("story").trim();
    cal = getCalFromDataTime(year + nf(monthNumber, 2) + nf(day, 2));
  } // end constructor

  //
  void addBucket(Bucket b) {
    if (!buckets.contains(b)) buckets.add(b);
  } // end addBucket

  //
  String toString() {
    String builder = month + " " + day + ", " + year + "\n";
    builder += story + "\n";
    return builder;
  } // end toString

  //

  //
  JSONObject getJSON() {
    JSONObject output = new JSONObject();
    output.setString("month", month);
    output.setInt("day", day);
    output.setInt("monthNumber", monthNumber);
    output.setString("story", story);
    return output;
  } // end getJSON
} // end class HistoryStory




//
//
//
//
//
//
//
//


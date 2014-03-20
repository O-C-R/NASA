class Year {
  int year = 0;
  ArrayList<Story> stories = new ArrayList<Story>();

  //
  Year(JSONObject json) {
    this.year = json.getInt("year");
    JSONArray storiesJS = json.getJSONArray("stories");
    for (int i = 0; i < storiesJS.size(); i++) {
      stories.add(new Story(storiesJS.getJSONObject(i), this));
    }
  } // end constructor

  //
  String toString() {
    String builder = "";
    builder += "Year: " + year + " with story count: " + stories.size();
    return builder;
  } // end toString
} // end class Year

//
//
//
//
//
//


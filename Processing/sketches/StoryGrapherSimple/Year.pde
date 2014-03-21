class Year {
  int year = 0;
  ArrayList<Story> stories = new ArrayList<Story>();
  ArrayList<ArrayList<Story>> storiesByMonth = new ArrayList<ArrayList<Story>>();

  //
  Year(JSONObject json) {
    for (int i = 0; i < 12; i++) {
      storiesByMonth.add(new ArrayList<Story>());
    }
    this.year = json.getInt("year");
    JSONArray storiesJS = json.getJSONArray("stories");
    for (int i = 0; i < storiesJS.size(); i++) {
      Story newStory = new Story(storiesJS.getJSONObject(i), this);
      stories.add(newStory);
      storiesByMonth.get(newStory.monthNumber - 1).add(newStory);
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


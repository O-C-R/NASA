class Year {
  int year = 0;
  ArrayList<HistoryStory> historyStories = new ArrayList<HistoryStory>();
  ArrayList<ArrayList<HistoryStory>> historyStoriesByMonth = new ArrayList<ArrayList<HistoryStory>>();

  ArrayList<NYTStory> nytStories = new ArrayList<NYTStory>();
  ArrayList<ArrayList<NYTStory>> nytStoriesByMonth = new ArrayList<ArrayList<NYTStory>>();

  //
  Year(JSONObject json) {
    for (int i = 0; i < 12; i++) {
      historyStoriesByMonth.add(new ArrayList<HistoryStory>());
      nytStoriesByMonth.add(new ArrayList<NYTStory>());
    }
    this.year = json.getInt("year");
    JSONArray storiesJS = json.getJSONArray("stories");
    for (int i = 0; i < storiesJS.size(); i++) {
      HistoryStory newStory = new HistoryStory(storiesJS.getJSONObject(i), this);
      historyStories.add(newStory);
      historyStoriesByMonth.get(newStory.monthNumber - 1).add(newStory);
    }
  } // end constructor

  //
  void addNYTStory(NYTStory storyIn) {
    nytStories.add(storyIn);
    nytStoriesByMonth.get(storyIn.pubDate.get(Calendar.MONTH)).add(storyIn);
  } // end addNYTStory

    //
  String toString() {
    String builder = "";
    builder += "Year: " + year + " with history story count: " + historyStories.size() + "\n";
    builder += "                and nyt story count: " + nytStories.size() + "\n";
    String historyStoryMonthString = " historyStories by month: ";
    for (int i = 0; i < historyStoriesByMonth.size(); i++) historyStoryMonthString += " " + i + "-" + historyStoriesByMonth.get(i).size();
    builder += historyStoryMonthString + "\n";
    String nytStoryMonthString =     "     ntyStories by month: ";
    for (int i = 0; i < nytStoriesByMonth.size(); i++) nytStoryMonthString += " " + i + "-" + nytStoriesByMonth.get(i).size();
    builder += nytStoryMonthString;
    return builder;
  } // end toString
} // end class Year

//
//
//
//
//
//


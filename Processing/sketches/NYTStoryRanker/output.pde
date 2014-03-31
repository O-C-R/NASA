
//
void outputImportantStories() {
  JSONObject output = new JSONObject();
  output.setInt("startYear", yearRange[0]);
  output.setInt("endYear", yearRange[1]);
  output.setInt("totalStories", importantStories.size());
  JSONArray stories = new JSONArray();
  for (ImportantStory is : importantStories) stories.setJSONObject(stories.size(), is.getJSON());
  output.setJSONArray("stories", stories);

  // output an array illustrating the number of HistoryStories on nyt pages
  JSONObject pageCountAwesome = new JSONObject();
  pageCountAwesome.setString("description", "this will illustrate how many HistoryStories have a NYTStory with the lowest page of...");
  HashMap<Integer, Integer> pageCount = new HashMap<Integer, Integer>();
  for (ImportantStory is : importantStories) {
    int pageCountNumber = is.getLowestPage();
    if (!pageCount.containsKey(pageCountNumber)) pageCount.put(pageCountNumber, 0);
    pageCount.put(pageCountNumber, ((Integer)pageCount.get(pageCountNumber)) + 1);
  }
  JSONArray pageCounter = new JSONArray();
  for (Map.Entry me : pageCount.entrySet()) {
    JSONObject pgCt = new JSONObject();
    pgCt.setInt("nytPrintPage", (Integer)me.getKey());
    pgCt.setInt("count", (Integer)me.getValue());
    pageCounter.setJSONObject(pageCounter.size(), pgCt);
  }
  pageCountAwesome.setJSONArray("pageCounts", pageCounter);
  output.setJSONObject("pageCountAwesome", pageCountAwesome);
  
  // output an array illustrating the number nyt stories for each HistoryStory
  JSONObject storyCountAwesome = new JSONObject();
  storyCountAwesome.setString("description", "this will illustrate how many HistoryStories have a certain NYTStory count");
  HashMap<Integer, Integer> storyCount = new HashMap<Integer, Integer>();
  for (ImportantStory is : importantStories) {
    int storyCountNumber = is.nytStories.size();
    if (!storyCount.containsKey(storyCountNumber)) storyCount.put(storyCountNumber, 0);
    storyCount.put(storyCountNumber, ((Integer)storyCount.get(storyCountNumber)) + 1);
  }
  JSONArray storyCounter = new JSONArray();
  for (Map.Entry me : storyCount.entrySet()) {
    JSONObject stCt = new JSONObject();
    stCt.setInt("nytStoryCount", (Integer)me.getKey());
    stCt.setInt("count", (Integer)me.getValue());
    storyCounter.setJSONObject(storyCounter.size(), stCt);
  }
  storyCountAwesome.setJSONArray("storyCounts", storyCounter);
  output.setJSONObject("storyCountAwesome", storyCountAwesome);

  saveJSONObject(output, "output/importantStories_" + yearRange[0] + "-" + yearRange[1] + ".json");
} // end outputImportantStories

//
//
//
//
//
//


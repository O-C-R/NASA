//
void outputStories(int thisYear, ArrayList<Story> storiesIn) {
  JSONObject output = new JSONObject();
  output.setInt("year", thisYear);
  output.setInt("totalStories", storiesIn.size());
  JSONArray ar = new JSONArray();
  
  for (int i = 0; i < storiesIn.size(); i++) {
    JSONObject storyJSON = storiesIn.get(i).getJSONObject();
    ar.setJSONObject(i, storyJSON);
  }
  output.setJSONArray("stories", ar);
  saveJSONObject(output, outputLocation + thisYear + ".json");
} // end outputStories

//
//
//
//
//


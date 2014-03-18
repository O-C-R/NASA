//
void outputStories(int thisYear) {
  JSONObject output = new JSONObject();
  output.setInt("year", thisYear);
  output.setInt("totalStories", stories.size());
  JSONArray ar = new JSONArray();
  
  for (int i = 0; i < stories.size(); i++) {
    JSONObject storyJSON = stories.get(i).getJSONObject();
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


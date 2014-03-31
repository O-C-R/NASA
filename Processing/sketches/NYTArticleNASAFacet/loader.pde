//
void loadKeys() {
  String keyLocation = "../../../Private/keys.json";
  JSONObject keys = loadJSONObject(keyLocation);
  JSONObject nytKey = keys.getJSONObject("nyt5");
  nytArticleKey = nytKey.getString("article_search");
  println("XX " + nytArticleKey);
} // end loadKeys

//
void loadExistingSearches() {
  // tbd
  // existingSearches....
} // end loadExistingSearches

//
//
//
//


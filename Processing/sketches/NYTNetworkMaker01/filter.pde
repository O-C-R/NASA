//
/*
// example
 String[] keyWords = {
 "MILITARY"
 };
 ArrayList<NYTStory> filtered = filterByKeywords(keyWords); // filter by keyword
 */
ArrayList<NYTStory> filterByKeywords(String[] keywords) {
  ArrayList<NYTStory> filtered = new ArrayList<NYTStory>();
  for (NYTStory s : nytStoriesByDate) {
    for (String keyword : keywords) {
      if (s.keywords.containsKey(keyword)) {
        filtered.add(s);
        break;
      }
    }
  }
  return filtered;
} // end filterByKeywords


//
//
//
//
//
//
//

//
// try to rank the stories by matching the nyt headline text + nyt page with the history story
void tryToRankHistoryStories() {
  println("in tryToRankHistoryStories");



  ArrayList<NYTStory> topStories = new ArrayList<NYTStory>();
  for (NYTStory st : nytStoriesByPage) if (st.printPage == 1) topStories.add(st);
  println("topStories.size(): " + topStories.size());

  for (int i = 0; i < topStories.size(); i++) {
    ArrayList<HistoryStory> similarStories = findSimilarStories(topStories.get(i));

    println("similar stories for: " + topStories.get(i).pubDateString + " -- " + topStories.get(i).headline);
    println(" total similar: " + similarStories.size());
    // manual break;
    if (i == 2) break;
  } 


  println("end of tryToRankHistoryStories");
} // end tryToRankHistoryStories


//
ArrayList<HistoryStory> findSimilarStories(NYTStory nytStory) {
  ArrayList<HistoryStory> similar = new ArrayList<HistoryStory>();
  int monthsPreviousToSearch = 1; // will collect and look at stories up to n months before this article was written
  Calendar end = nytStory.pubDate;
  Calendar start = Calendar.getInstance();
  start.setTimeInMillis(end.getTimeInMillis());
  start.add(Calendar.MONTH, -monthsPreviousToSearch); 
  ArrayList<HistoryStory> options = getHistoryStoriesWithinRange(start, end); // the ones which are in the monthsPreviousToSearch range

  println(" in findSimilarSories.  options as: " + options.size());

  return similar;
} // end findSimilarStories


//
// this will go through the years and return an ArrayList of all history stories within this calendar range
ArrayList<HistoryStory> getHistoryStoriesWithinRange (Calendar start, Calendar end) {
  long startMS = start.getTimeInMillis();
  long endMS = end.getTimeInMillis();
  ArrayList<HistoryStory> range = new ArrayList<HistoryStory>();
  int startYear = start.get(Calendar.YEAR);
  int endYear = end.get(Calendar.YEAR);
  for (int year = startYear; year <= endYear; year++) {
    Year thisYear = yearsHM.get(year);
    for (int i = 0; i < 12; i++) {
      Calendar monthStart = getCalFromDataTime(thisYear.year + nf(i + 1, 2) + "01");
      Calendar monthEnd = Calendar.getInstance();
      monthEnd.setTimeInMillis(monthStart.getTimeInMillis());
      monthEnd.add(Calendar.MONTH, 1);
      monthEnd.add(Calendar.SECOND, -1);
      long monthStartMS = monthStart.getTimeInMillis();
      long monthEndMS = monthEnd.getTimeInMillis();
      if (startMS <= monthStartMS && endMS >= monthEndMS) {
        // entire range
        range.addAll(thisYear.historyStoriesByMonth.get(i));
      }
      else if ((monthStartMS >= startMS && monthStartMS <= endMS) || (monthEndMS >= startMS && monthEndMS <= endMS)) {
        // partial range 
        //println("\nXXX" + getNicePubDateString(start) + "_"+ getNicePubDateString(end));
        for (HistoryStory st : thisYear.historyStoriesByMonth.get(i)) {
          if (st.cal != null) {
            long storyMS = st.cal.getTimeInMillis();
            //print(getNicePubDateString(st.cal) + "|");
            if (storyMS >= startMS && storyMS <= endMS) {
              range.add(st);
            }
          }
        }
        //range.addAll(thisYear.historyStoriesByMonth.get(i));  good
      }
    }
  }

  return range;
} // end getHistoryStoriesWithinRange



//
//
//
//
//
//
//


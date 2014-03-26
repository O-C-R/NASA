//
void doSearch(String searchTerm, String fq, int targetYear, int targetMonth) {
  String beginDate = targetYear + "0101";
  String endDate = targetYear + "1231";
  boolean pastTime = false;
  // if it is going by month then that will be adjusted here
  boolean endOfYear = false;
  if (targetMonth > -1) {
    beginDate = targetYear + nf(targetMonth, 2) + "01";
    if (targetMonth == 12) {
      targetMonth = 1;
      targetYear++;
      endOfYear = true;
    }
    else {
      targetMonth++;
    }
    Calendar temp = getCalFromDataTime(nf(targetYear, 4) + nf(targetMonth, 2) + 01);
    temp.add(Calendar.DAY_OF_MONTH, -1);
    endDate = nf(temp.get(Calendar.YEAR), 4) + nf(temp.get(Calendar.MONTH) + 1, 2) + nf(temp.get(Calendar.DAY_OF_MONTH), 2);
    // stop if the date is after today
    if (getCalFromDataTime(beginDate).getTimeInMillis() > Calendar.getInstance().getTimeInMillis()) pastTime = true;
  }

  // reset the targetMonth
  if (endOfYear) targetMonth = 12;
  else targetMonth--;

  //println(beginDate + " to " + endDate);
  Search newSearch = new Search(searchTerm, fq, beginDate, endDate, targetYear, targetMonth);
  if (!pastTime) {
    newSearch.makeResults();
    //println("done with " + searchTerm + " for year: " + targetYear + " with " + newSearch.hits + " hits");
    //if (targetYear % 10 == 0) print(targetYear); 
    //else print(".");
  }
} // end doSearch



//
void doBigSearch(String searchTerm, String fq, int startYear, int endYear, boolean byMonth) {
  // make a big search that contains all of the little searches
  String beginDate = startYear + "0101";
  String endDate = endYear + "1231";
  Search bigSearch = new Search(searchTerm, fq, beginDate, endDate, startYear, -1); 

  for (int i = startYear; i <= endYear; i++) {
    if (byMonth) {
      for (int j = 1; j <= 12; j++) {
        doSearch(searchTerm, fq, i, j);
      }
    }
    else {
      doSearch(searchTerm, fq, i, -1);
    }
  }
} // end doBigSearch

//
//
//
//
//
//


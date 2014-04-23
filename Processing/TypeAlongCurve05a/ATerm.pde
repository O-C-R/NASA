class Term {
  String term = "";
  String[] theseTermWords = new String[0];
  //String[] posTermWords = new String[0];
  float[] series = null;
  int totalCount = 0;

  float seriesSum = 0f;
  
  float fillAlphaPercent = 1f; // between 0 and 1.  used in label to go between minimumFillAlpha and maximumFillAlpha.  assigned in makeAlphaValuesForTerms()

  // put the things into order
  int[] seriesOrderedIndices = new int[0];

  //
  Term() {
  } // end blank constructor

  //
  Term(String term, int totalCount, float[] series) {
    this.term = term;
    theseTermWords = split(term, " ");
    this.totalCount = totalCount;
    this.series = series;
  } // end constructor


  // 
  Term get() {
    Term t = new Term();
    t.term = term;
    t.totalCount = totalCount;
    if (series != null) {
      t.series = new float[0];
      for (float f : series) t.series = (float[])append(t.series, f);
    }
    for (String s : theseTermWords) t.theseTermWords = (String[])append(t.theseTermWords, s);
    t.fillAlphaPercent = fillAlphaPercent;
    for (int i : seriesOrderedIndices) t.seriesOrderedIndices = (int[])append(t.seriesOrderedIndices, i);
    return t;
  } // end copy

  //
  void tallyThings() {
    for (float f : series) seriesSum += f;
  } // end tallyThings

  //
  // this will fill in the seriesOrderedIndices[] with a descending order of the series numbers
  void makeSeriesOrder() {
    ArrayList<Integer> tempIndexCount = new ArrayList<Integer>();
    ArrayList<Float> tempSeriesAmt = new ArrayList<Float>();
    for (int i = 0; i < series.length; i++) {
      if (i == 0) {
        tempIndexCount.add(i);
        tempSeriesAmt.add(series[i]);
      }
      else {
        boolean foundSpot = false;
        for (int j = 0; j < tempSeriesAmt.size(); j++) {
          if (series[i] > tempSeriesAmt.get(j)) {
            tempIndexCount.add(j, i);
            tempSeriesAmt.add(j, series[i]);
            foundSpot = true;
            break;
          }
        }
        if (!foundSpot) {
          tempIndexCount.add(i);
          tempSeriesAmt.add(series[i]);
        }
      }
    }
    // transfer to seriesOrderedIndices
    for (Integer i : tempIndexCount) seriesOrderedIndices = (int[])append(seriesOrderedIndices, i);
  } // end makeSeriesOrder

  //
  // try to tell if a word equals this one.  not used
  boolean matchesTermWords(String[] arIn) {
    //String thisPos = "";
    for (int i = 0; i < theseTermWords.length; i++) {
      //thisPos = posTermWords[i];
      for (String t : arIn) {
        if (t.equals(theseTermWords[i])) return true;
      }
    }
    return false;
  } // end matchesTermWords
  

  //
  String toString() {
    return "TERM: " + term + " totalCount: " + totalCount + " seriesSum: " + seriesSum;
  } // end toString
} // end class Term

//
//
//
//
//


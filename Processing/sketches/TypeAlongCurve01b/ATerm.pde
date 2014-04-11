class Term {
  String term = "";
  float[] series = null;
  int totalCount = 0;
  
  float seriesSum = 0f;

  //
  Term(String term, int totalCount, float[] series) {
    this.term = term;
    this.totalCount = totalCount;
    this.series = series;
  } // end constructor
  
  //
  void tallyThings() {
    for (float f : series) seriesSum += f;
  } // end tallyThings
} // end class Term

//
//
//
//
//


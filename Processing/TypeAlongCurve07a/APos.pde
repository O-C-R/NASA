class Pos {
  String pos = "";

  float totalSeriesSum = 0; // the sum of all the series numbers from these terms
  int totalTermCount = 0; // how many terms there are.. not terms.size(),but using term.totalCount
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;

  HashMap<String, Term> termsHM = new HashMap<String, Term>();
  ArrayList<Term> termsAL = new ArrayList<Term>();

  float[] seriesSum = null;

  //
  Pos(String pos) {
    this.pos = pos;
  } // end constructor

  //
  void addTerm(Term t) {
    termsHM.put(t.term, t);
    termsAL.add(t);
  } // end addWord

  //
  void tallyThings() {
    for (Map.Entry me : termsHM.entrySet()) {
      Term t = (Term)me.getValue();
      t.tallyThings();

      if (t.series != null && t.series.length > 0) {
        if (seriesSum == null) seriesSum = t.series;
        else {
          for (int i = 0; i < seriesSum.length; i++) {
            if (i < t.series.length) { // hack
              seriesSum[i] += t.series[i];
            }
            else {
              println("mismatch of t.series.length vs seriesSum.length");
            }
          }
        }
      }

      totalSeriesSum += t.seriesSum;
      totalTermCount += t.totalCount;
      if (t.seriesSum > highestSeriesCount) {
        highestSeriesCount = t.seriesSum;
        highestSeriesTermString = t.term;
        highestSeriesTerm = t;
      }
    }
  } // end tallyThings

  //
  void orderTerms() {
    for (Term t : termsAL) t.makeSeriesOrder();
    termsAL = OCRUtils.sortObjectArrayListSimple(termsAL, "seriesSum");
    termsAL = OCRUtils.reverseArrayList(termsAL);
  } // end orderTerms

  //
  String getString() {
    String builder = "   POS: " + pos;
    builder += "\n     totalSeriesSum: " + totalSeriesSum + "  totalTermCount: " + totalTermCount + "  highestSeriesCount: " + highestSeriesCount + "  highestSeriesTermString: " + highestSeriesTermString + "  total terms: " + termsHM.size();
    return builder;
  } // end getString
} // end class Pos

//
//
//
//
//


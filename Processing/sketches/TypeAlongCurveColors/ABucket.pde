class Bucket {
  String name = "";
  HashMap<String, Pos> posesHM = new HashMap<String, Pos>();
  ArrayList<Pos> posesAL = new ArrayList<Pos>();

  float highCount = 0f;
  float totalSeriesSum = 0; // total from all of the terms within all of the poses
  int totalTermCount = 0; // total terms from all of the poses
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;

  float maxPosSeriesNumber = 0f; // go through and find the max posSeries number


  // keep a specific list of the terms .. from all of the poses
  ArrayList<Term> bucketTermsAL = new ArrayList<Term>();
  HashMap<String, Term> bucketTermsHM = new HashMap<String, Term>();
  ArrayList<Term> bucketTermsRemainingAL = new ArrayList<Term>();


  float[] seriesSum = null;

  color c = color(random(255), random(255), random(255));

  //
  HashMap<String, Term> failedTerms = new HashMap<String, Term>(); // the ones that were not placed
  // when populating, if it cannot be placed it will be placed in this hm.  upon changing the year range this will get reset


  //
  Bucket(String name) {
    this.name = name;
  } // end constructor

  //
  void addPos(Pos pos) {
    posesHM.put(pos.pos, pos);
    posesAL.add(pos);
  } // end addPos

    //
  void tallyThings() {
    for (Map.Entry me : posesHM.entrySet()) {
      Pos p = (Pos)me.getValue();
      p.tallyThings();

      if (p.seriesSum != null && p.seriesSum.length > 0) {
        if (seriesSum == null) seriesSum = p.seriesSum;
        else {
          for (int i = 0; i < seriesSum.length; i++) seriesSum[i] += p.seriesSum[i];
        }
      }

      totalSeriesSum += p.totalSeriesSum;
      totalTermCount += p.totalTermCount;
      if (p.totalSeriesSum > highestSeriesCount) {
        highestSeriesCount = p.totalSeriesSum;
        highestSeriesTermString = p.highestSeriesTermString;
        highestSeriesTerm = p.highestSeriesTerm;
      }
    }

    for (float f : seriesSum) maxPosSeriesNumber = (maxPosSeriesNumber > f ? maxPosSeriesNumber : f);
  } // end tallyThings

  //
  void orderTerms() {
    println("orderTerms for bucket " + name);
    for (Pos p : posesAL) {
      p.orderTerms();
      bucketTermsAL.addAll(p.termsAL);
    }
    bucketTermsAL = OCRUtils.sortObjectArrayListSimple(bucketTermsAL, "seriesSum");
    bucketTermsAL = OCRUtils.reverseArrayList(bucketTermsAL);
    for (Term t : bucketTermsAL) {
      if (!bucketTermsHM.containsKey(t.term)) bucketTermsHM.put(t.term, t);
      else println("bucket " + name + " already has: " + t.term);
      bucketTermsRemainingAL.add(t); // keep a copy
    }
    println(" done.  with " + bucketTermsRemainingAL.size() + " options");
  } // end orderTerms

  //
  void takeOutTerm(Term t) {
    for (int i = bucketTermsRemainingAL.size() - 1; i >= 0; i--) {
      if (bucketTermsRemainingAL.get(i) == t) bucketTermsRemainingAL.remove(t);
      /*
      else {
       String[] termAr = split(t.term, " ");
       if (bucketTermsRemainingAL.get(i).matchesTermWords(termAr)) {
       bucketTermsRemainingAL.remove(i);
       }
       }
       */
    }
  } // end takeOutTerm

  //
  String toString() {
    String builder = "BUCKET: " + name + " with " + posesHM.size() + " poses.";
    builder += "\n  totalSeriesSum: " + totalSeriesSum + "  totalTermCount: " + totalTermCount + "  highestSeriesCount: " + highestSeriesCount + "  highestSeriesTermString: " + highestSeriesTermString;
    for (Map.Entry me : posesHM.entrySet()) {
      builder += "\n" + ((Pos)me.getValue()).getString();
    }
    return builder;
  } // end toString
} // end class Bucket

//
//
//
//
//
//
//
//


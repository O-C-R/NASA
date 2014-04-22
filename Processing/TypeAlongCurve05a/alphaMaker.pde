// 
void makeAlphaValuesForTerms() {
  println("in makeAlphaValuesForTerms.  maximumTermOverallCount: " + maximumTermOverallCount);
  long startTime = millis();

  for (int i = 0; i < bucketsAL.size(); i++) {
    println("looking at bucket: " + bucketsAL.get(i).name + " with " + bucketsAL.get(i).bucketTermsAL.size() + " terms");
    Bucket thisBucket = bucketsAL.get(i);
    //for (Term t : thisBucket.bucketTermsAL) {
    for (int j = 0; j <  thisBucket.bucketTermsAL.size(); j++) {
      Term t = thisBucket.bucketTermsAL.get(j);
      makeTermAlpha(t, (float)j / thisBucket.bucketTermsAL.size(), bucketsAL.get(i).name);
    }
    //for (Term t : thisBucket.bucketTermsEntitiesAL) {
    for (int j = 0; j <  thisBucket.bucketTermsEntitiesAL.size(); j++) {
      Term t = thisBucket.bucketTermsEntitiesAL.get(j);
      makeTermAlpha(t, (float)j / thisBucket.bucketTermsEntitiesAL.size(), bucketsAL.get(i).name);
    }
    //for (Term t : thisBucket.fillersTermsAL) {
    for (int j = 0; j <  thisBucket.fillersTermsAL.size(); j++) {
      Term t = thisBucket.fillersTermsAL.get(j);
      makeTermAlpha(t, (float)j / thisBucket.fillersTermsAL.size(), bucketsAL.get(i).name);
    }
  }
  println("end of makeAlphaValuesForTerms.  total time: " + (int)(((float)millis() - startTime) / 1000) + " seconds");
} // end makeAlphaValuesForTerms

//
void makeTermAlpha(Term t, float positionInAr, String bucketName) {
  ArrayList<String> termCount = (ArrayList<String>)termSimpleCount.get(t.term);
  float multiplier = constrain(map((1 - positionInAr) * (1 - positionInAr), 0, 1, .25, 3), .25, 3);
  int termCountOverall = termCount.size();
  int termCountThisBucket = 0;
  for (String s : termCount) if (s.equals(bucketName)) termCountThisBucket++;
  
  float ratio = multiplier * (float)termCountThisBucket / termCountOverall;
  
  t.fillAlphaPercent = constrain(map(ratio, 0, 1, 0, 1), 0, 1);

  println(t.term + " count: " + termCountOverall + " termCountThisBucket: " + termCountThisBucket + " ratio: " + ratio + " alpha: " + t.fillAlphaPercent);
} // end makeTermAlpha



//
//
//
//


class Bucket {
  String name = "";
  HashMap<String, Pos> posesHM = new HashMap<String, Pos>();
  ArrayList<Pos> posesAL = new ArrayList<Pos>();

  // entities will be treated like a separate pos series –– because their ranking system is different
  HashMap<String, Pos> entitiesHM = new HashMap<String, Pos>();
  ArrayList<Pos> entitiesAL = new ArrayList<Pos>();

  // tally stuff for regular pos
  float highCount = 0f;
  float totalSeriesSum = 0; // total from all of the terms within all of the poses
  int totalTermCount = 0; // total terms from all of the poses
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;
  float[] seriesSum = null;
  float maxPosSeriesNumber = 0f; // go through and find the max posSeries number


  // tally stuff for entity pos
  float highCountEntity = 0f;
  float totalSeriesSumEntity = 0; // total from all of the terms within all of the poses
  int totalTermCountEntity = 0; // total terms from all of the poses
  float highestSeriesCountEntity = 0; // max count for a term
  String highestSeriesTermStringEntity = "";
  Term highestSeriesTermEntity;
  float[] seriesSumEntity = null;
  float maxPosSeriesNumberEntity = 0f;


  // keep a specific list of the terms .. from all of the poses
  ArrayList<Term> bucketTermsAL = new ArrayList<Term>();
  HashMap<String, Term> bucketTermsHM = new HashMap<String, Term>();
  ArrayList<Term> bucketTermsRemainingAL = new ArrayList<Term>();




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
  void addEntity(Pos entity) {
    entitiesHM.put(entity.pos, entity);
    entitiesAL.add(entity);
  } // end addEntity

    //
  void tallyThings() {
    // tally things for both the regular pos and for the entity pos values
    for (Map.Entry me : posesHM.entrySet()) {
      Pos p = (Pos)me.getValue();
      p.tallyThings();

      if (p.seriesSum != null && p.seriesSum.length > 0) {
        if (seriesSum == null) seriesSum = p.seriesSum;
        else {
          for (int i = 0; i < seriesSum.length; i++) seriesSum[i] += .000000001 + p.seriesSum[i]; // add in at least something so that it doesnt 0 out. ****** BUG ****** 
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

    println("bucket: " + name + " REGULAR POS STUFF: " );
    println(" highestSeriesCount: " + highestSeriesCount);
    println(" highestSeriesTermString: " + highestSeriesTermString);
    println(" maxPosSeriesNumber: " + maxPosSeriesNumber);


    // entity pos stuff
    for (Map.Entry me : entitiesHM.entrySet()) {
      Pos p = (Pos)me.getValue();
      p.tallyThings();

      if (p.seriesSum != null && p.seriesSum.length > 0) {
        if (seriesSumEntity == null) seriesSumEntity = p.seriesSum;
        else {
          for (int i = 0; i < seriesSumEntity.length; i++) {
            if (i < seriesSumEntity.length && i < p.seriesSum.length) seriesSumEntity[i] += p.seriesSum[i];
            //else seriesSumEntity = (float[])append(seriesSumEntity, p.seriesSum[i]);
          }
        }
      }

      // do a check to make sure that the seriesSumEntity.length == seriesSum.length.  if the seriesSum has more then add empty spots to the seriesSumEntity
      if (seriesSum.length > seriesSumEntity.length) {
        while (true) {
          seriesSumEntity = (float[])append(seriesSumEntity, 0f);
          if (seriesSum.length == seriesSumEntity.length) break;
        }
      }

      totalSeriesSumEntity += p.totalSeriesSum;
      totalTermCountEntity += p.totalTermCount;
      if (p.totalSeriesSum > highestSeriesCountEntity) {
        highestSeriesCountEntity = p.totalSeriesSum;
        highestSeriesTermStringEntity = p.highestSeriesTermString;
        highestSeriesTermEntity = p.highestSeriesTerm;
      }
    }

    for (float f : seriesSumEntity) maxPosSeriesNumberEntity = (maxPosSeriesNumberEntity > f ? maxPosSeriesNumberEntity : f);

    println("bucket: " + name + " ENTITY STUFF: " );
    println(" highestSeriesCountEntity: " + highestSeriesCountEntity);
    println(" highestSeriesTermStringEntity: " + highestSeriesTermStringEntity);
    println(" maxPosSeriesNumberEntity: " + maxPosSeriesNumberEntity);
  } // end tallyThings

  //
  void orderTerms() {
    // goal here is to order first the normal pos terms, then the entity terms.  then order both by highest count, then splice the two lists together according to the entityToNormalRatio
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
      //bucketTermsRemainingAL.add(t); // keep a copy
    }

    ArrayList<Term>bucketTermsEntitiesAL = new ArrayList<Term>();
    for (Pos p : entitiesAL) {
      p.orderTerms();
      bucketTermsEntitiesAL.addAll(p.termsAL);
    }
    bucketTermsEntitiesAL = OCRUtils.sortObjectArrayListSimple(bucketTermsEntitiesAL, "seriesSum");
    bucketTermsEntitiesAL = OCRUtils.reverseArrayList(bucketTermsEntitiesAL);
    for (Term t : bucketTermsEntitiesAL) {
      if (!bucketTermsHM.containsKey(t.term)) bucketTermsHM.put(t.term, t);
      else println("bucket " + name + " already has: " + t.term);
      //bucketTermsRemainingAL.add(t); // keep a copy
    }    

    // lastly splice the two lists together into the bucketTermsRemainingAL;
    ArrayList<String> testOutput = new ArrayList<String>();
    while (true) {
      float rando = random(1 + entityToNormalRatio);
      if ((rando < entityToNormalRatio  || bucketTermsAL.size() == 0) && bucketTermsEntitiesAL.size() > 0) {
        bucketTermsRemainingAL.add(bucketTermsEntitiesAL.get(0));
        bucketTermsEntitiesAL.remove(0);
        testOutput.add("e");
      }
      else {
        if (bucketTermsAL.size() > 0) {
          bucketTermsRemainingAL.add(bucketTermsAL.get(0));
          bucketTermsAL.remove(0);
          testOutput.add("p");
        }
      }
      if (bucketTermsAL.size() == 0 && bucketTermsEntitiesAL.size() == 0) break;
    } 


    println(" done.  with " + bucketTermsRemainingAL.size() + " options");
    println(testOutput);
  } // end orderTerms

  //
  void takeOutTerm(Term t) {
    for (int i = bucketTermsRemainingAL.size() - 1; i >= 0; i--) {
      if (bucketTermsRemainingAL.get(i) == t) bucketTermsRemainingAL.remove(t);

      else {
        //String[] termAr = split(t.term, " ");
        //if (bucketTermsRemainingAL.get(i).matchesTermWords(termAr)) {
        // bucketTermsRemainingAL.remove(i);
        //}
        if (bucketTermsRemainingAL.get(i).term.equals(t.term)) {
          bucketTermsRemainingAL.remove(i);
        }
      }
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


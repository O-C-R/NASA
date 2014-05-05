// 
void setupHexColors() {
  hexColors.put("debug", #ffffff);
  hexColors.put("administrative", #66ffff);
  hexColors.put("astronaut", #ff331f);
  hexColors.put("mars", #cc1166);
  hexColors.put("moon", #FFB914);
  hexColors.put("people", #f5a3cf);
  hexColors.put("research_and_development", #BDEEFF);
  hexColors.put("rockets", #FFDFA8);
  hexColors.put("russia", #E50C30);
  hexColors.put("satellites", #FF450D);
  hexColors.put("space_shuttle", #FF7E0D);
  hexColors.put("spacecraft", #333333);
  hexColors.put("us", #0022ff);
} // end setupHexColors


//
void readInBucketData() {
  String[] directories = OCRUtils.getDirectoryNames(mainDiretoryPath, false);

  float overallSum = 0f;

  for (String directory : directories) {
    String newBucketName = split(directory, "/")[split(directory, "/").length - 1];



    // check that this is a valid bucket
    boolean isValid = false;
    for (String s : bucketsToUse) if (s.equals(newBucketName)) isValid = true;
    if (!isValid) continue;

    println("bucket: " + newBucketName);

    Bucket newBucket = new Bucket(newBucketName);
    // assign color if it is in the hm
    if (hexColors.containsKey(newBucketName)) newBucket.c = (Integer)hexColors.get(newBucketName); 

    String[] files = OCRUtils.getFileNames(directory, true);
    float yearSum = 0f;
    for (String thisFile : files) {
      String newPosName = split(thisFile, "/")[split(thisFile, "/").length - 1];

      boolean isPos = false;
      boolean isEntity = false;
      boolean isFiller = false;
      //for (String s : posesToUse) if (newPosName.contains(s)) isPos = true;
      if (newPosName.contains("_")) newPosName = split(newPosName, "_")[0];
      for (String s : posesToUse) if (newPosName.equals(s)) isPos = true;
      for (String s : entitiesToUse) if (newPosName.contains(s)) isEntity = true;
      for (String s : fillersToUse) if (newPosName.equals(s)) isFiller = true;
      if (!isPos && !isEntity && !isFiller) continue;

      Pos newPos = new Pos(newPosName);

      String[] allLines = loadStrings(thisFile);

      println("file: " + thisFile + " allLines.length: " + allLines.length);

      for (int i = 0; i < allLines.length; i++) {
        // ****** QUICK LOADER ****** //
        if (debugQuickLoader) {
          if (i > (float)allLines.length / 4) break;
        }
        // ****** QUICK LOADER ****** //
        String[] broken = split(allLines[i], ",");
        String term = "";
        int termCount = 0;
        float[] breakdown = new float[0];

        // some of the names have commas in them
        int nameIndices = 0;

        int manualBreak = 0;
        boolean badLine = false;
        while (true) {
          try {
            manualBreak++;
            if (manualBreak > 10000) {
              badLine = true;
              break;
            }
            int test = Integer.parseInt(broken[nameIndices + 1]);
            break;
          }
          catch (Exception e) {
            nameIndices++;
          }
        }


        // skip the bad line
        if (badLine) {
          println("badLine");
          continue;
        }

        for (int j = 0; j < broken.length; j++) {          
          if (j <= nameIndices) {
            if (j > 0) term += " ";
            term += broken[j].replace("\"", "").trim(); // take out ""
          }
          else if (j == nameIndices + 1) {
            termCount = Integer.parseInt(broken[j]);
          }
          else {
            breakdown = (float[])append(breakdown, Float.parseFloat(broken[j]));
          }
        }

        // ****** //
        if (term.length() <= 2) continue; // skip if it is 2 or fewer characters
        term = doSpecialNeeds(term);
        // add in an extra space
        term = term.replace(" ", "  ");
        // ****** //

        Term newTerm = new Term(term, termCount, breakdown, newPosName);
        newPos.addTerm(newTerm);

        // save this term to the termSimpleCount
        if (!termSimpleCount.containsKey(term)) termSimpleCount.put(term, new ArrayList<String>());
        ArrayList<String> newCount = (ArrayList<String>)termSimpleCount.get(term);
        newCount.add(newBucketName);
        termSimpleCount.put(term, newCount);
        if (newCount.size() > maximumTermOverallCount) {
          maximumTermOverallCount = newCount.size();
        }
        // find count of buckets
        int bucketCount = 0;
        for (String s : newCount) if (s.equals(newBucketName)) bucketCount++;
        if (bucketCount > maximumTermSingleBucketCount) {
          maximumTermSingleBucketCount = bucketCount;
        }

        // check and overwrite blankTerm
        if (blankTerm.series == null) blankTerm.series = new float[0];
        if (breakdown.length > blankTerm.series.length) blankTerm.series = breakdown;
      }
      if (isPos) newBucket.addPos(newPos);
      else if (isEntity) newBucket.addEntity(newPos);
      else if (isFiller) newBucket.addFiller(newPos);
    }

    println("going to tally for bucket: " + newBucket.name);
    newBucket.tallyThings();
    println(" tallied");
    bucketsAL.add(newBucket);
    bucketsHM.put(newBucketName, newBucket);
    println(" added new bucket");
  }

  // if manual listing then reorder the buckets by the order of the bucketsToUse
  if (manualLayerControl) {
    ArrayList<Bucket> newBucketsAL = new ArrayList<Bucket>(); 
    for (String s : bucketsToUse) {
      for (Bucket b : bucketsAL) {
        if (b.name.equals(s)) newBucketsAL.add(b);
      }
    }
    bucketsAL = newBucketsAL;
  }
} // end readInBucketData


//
//
//
//
//
//


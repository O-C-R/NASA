// 
void setupHexColors() {
  hexColors.put("debug", #ffffff);
  hexColors.put("administrative", #66ffff);
  hexColors.put("astronaut", #ff331f);
  hexColors.put("mars", #cc1166);
  hexColors.put("moon", #FF450D);
  hexColors.put("people", #f5a3cf);
  hexColors.put("research_and_development", #FFB914);
  hexColors.put("rockets", #FFDFA8);
  hexColors.put("russia", #E50C30);
  hexColors.put("satellites", #BDEEFF);
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
      for (String s : posesToUse) if (newPosName.contains(s)) isPos = true;
      for (String s : entitiesToUse) if (newPosName.contains(s)) isEntity = true;
      if (!isPos && !isEntity) continue;

      Pos newPos = new Pos(newPosName);

      String[] allLines = loadStrings(thisFile);
      for (int i = 0; i < allLines.length; i++) {

        String[] broken = split(allLines[i], ",");
        String term = "";
        int termCount = 0;
        float[] breakdown = new float[0];

        // some of the names have commas in them
        int nameIndices = 0;

        int manualBreak = 0;
        while (true) {
          try {
            int test = Integer.parseInt(broken[nameIndices + 1]);
            break;
          }
          catch (Exception e) {
            nameIndices++;
          }
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
        // ****** //

        Term newTerm = new Term(term, termCount, breakdown);
        newPos.addTerm(newTerm);

        // check and overwrite blankTerm
        if (blankTerm.series == null) blankTerm.series = new float[0];
        if (breakdown.length > blankTerm.series.length) blankTerm.series = breakdown;
      }
      if (isPos) newBucket.addPos(newPos);
      else if (isEntity) newBucket.addEntity(newPos);
    }
    newBucket.tallyThings();
    bucketsAL.add(newBucket);
    bucketsHM.put(newBucketName, newBucket);
  }
} // end readInBucketData


//
//
//
//
//
//

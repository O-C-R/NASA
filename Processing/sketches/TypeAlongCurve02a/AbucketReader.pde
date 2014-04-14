// 
void setupHexColors() {
  hexColors.put("debug", #ffffff);
  hexColors.put("administrative", #66ffff);
  hexColors.put("astronaut", #ff331f);
  hexColors.put("mars", #cc1166);
  hexColors.put("moon", #aaaaaa);
  hexColors.put("people", #f5a3cf);
  hexColors.put("research_and_development", #aaaa00);
  hexColors.put("rockets", #ffffff);
  hexColors.put("russia", #ff1133);
  hexColors.put("satellites", #2266aa);
  hexColors.put("space_shuttle", #aaf045);
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

      isValid = false;
      for (String s : posesToUse) if (newPosName.contains(s)) isValid = true;
      if (!isValid) continue;

      Pos newPos = new Pos(newPosName);

      String[] allLines = loadStrings(thisFile);
      for (int i = 0; i < allLines.length; i++) {
        String[] broken = split(allLines[i], ",");
        String term = "";
        int termCount = 0;
        float[] breakdown = new float[0];
        for (int j = 0; j < broken.length; j++) {
          if (j == 0) term = broken[j].replace("\"", "").trim(); // take out ""
          else if (j == 1) termCount = Integer.parseInt(broken[j]);
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
      newBucket.addPos(newPos);
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


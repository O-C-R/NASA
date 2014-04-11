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


    String[] files = OCRUtils.getFileNames(directory, true);
    float yearSum = 0f;
    for (String thisFile : files) {
      String newPosName = split(thisFile, "/")[split(thisFile, "/").length - 1];
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


//
void loadGrams() {
  String gramFileDirectory = sketchPath("") + "../../../Data/nytGramFrequency";
  
  String[] fileNames = getFileNames(gramFileDirectory);
  for (int i = 0; i < fileNames.length; i++) {
    String fileName = fileNames[i];
    if (fileName.contains(".json")) {
     Gram newGram = new Gram(loadJSONObject( gramFileDirectory + "/" + fileName));
     grams.add(newGram);
    }
  }
  for (Gram g : grams) println(g);
  println("finished loading " + grams.size() + " new grams");
} // end loadMaps

//
String[] getFileNames (String fileDirectory) {
  String[] validFiles = new String[0];
  try {
    // list all of the files and read in the top n files -- starting from the most recent
    File file = new File(fileDirectory);
    println("asdf");
    if (file.isDirectory()) {  
      String allFiles[] = file.list();
      for (String thisFile : allFiles) {
        if (thisFile.length() > 0 && thisFile.toLowerCase().charAt(0) != '.') {
          validFiles = (String[])append(validFiles, thisFile);
        }
      }
    }
  }
  catch (Exception e) {
    println("error getting file names for directory: " + fileDirectory);
  }
  return validFiles;
} // end getFileNames

//
//
//
//


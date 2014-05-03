import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

String fileDirectory = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAllCLEAN/";

String[] addPeriods = {
  "Dr", 
  "Rep", 
  "Jr", 
  "Capt", 
  "Maj", 
  "Prof",
  "Lt"
};
HashMap<String, Integer> addPeriodsHM = null;

void setup() {
  long startTime = millis();
  OCRUtils.begin(this);
  String[] allFiles = OCRUtils.getFileNames(fileDirectory, true);
  String[] culledFiles = new String[0];
  for (String s : allFiles) if (s.contains("Person.txt")) culledFiles = (String[])append(culledFiles, s);
  println(culledFiles);

  for (String s : culledFiles) {
    String[] broken = split(s, "/");
    String fileName =  broken[broken.length - 1];

    String[] brokenCulled = new String[broken.length - 1];
    for (int i = 0; i < brokenCulled.length; i++) brokenCulled[i] = broken[i];
    String directory = join(brokenCulled, "/");
    println("FILE: " + fileName + " dir: " + directory);

    PrintWriter output = createWriter(directory + "/z" + fileName);


    String[] lines = loadStrings(directory + "/" + fileName);
    for (int k = 0; k < lines.length; k++) {
      String[] lineBroken = split(lines[k], ",");
      String name = lineBroken[0];
      String[] nameBroken = split(name, " ");
      for (int j = 0; j < nameBroken.length; j++) {
        if (nameBroken[j].length() == 1) {
          int letterChar = nameBroken[j].charAt(0);    
          if (letterChar >= 65 && letterChar <= 90) {
            nameBroken[j] += ".";
          }
        }
        else if (checkForSpecial(nameBroken[j])) {
          nameBroken[j] += ".";
        }
      }
      name = join(nameBroken, " ");
      println(name);
      // recompose the line
      lineBroken[0] = name;
      output.println(join(lineBroken, ","));
    }

    output.flush();
    output.close();
  }

  println("done changing stuff in " + (int)(((float)millis() - startTime) / 1000) + " seconds");
  exit();
} // end setup


//
boolean checkForSpecial(String s) {
  if (addPeriodsHM == null) {
    addPeriodsHM = new HashMap<String, Integer>();
    for (String ssss: addPeriods) addPeriodsHM.put(ssss, 0);
  }
  if (addPeriodsHM.containsKey(s)) return true;
  return false;
} // end addPeriods


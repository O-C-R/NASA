


//
// this will simply order the splabels by y
ArrayList<SpLabel> orderSpLabels(ArrayList<SpLabel> topList, ArrayList<SpLabel> bottomList) {
  ArrayList<SpLabel> ordered = new ArrayList<SpLabel>();
  for (int i = topList.size() - 1; i >= 0; i--) ordered.add(topList.get(i));
  for (int i = 0; i < bottomList.size(); i++) {
    if (!ordered.contains(bottomList.get(i))) {
      ordered.add(bottomList.get(i));
    }
  }

  for (int i = 0; i < ordered.size(); i++) ordered.get(i).tempNumericalId = i;
  return ordered;
} // end orderSpLabels


//
void splitMasterSpLabelsVertically(float maxLineHeight, float splineCPDistance, float maximumPercentSplineSpacing) {
  int breakCount = 0;
  println("in splitMasterSpLabelsVertical");
  for (SpLabel sp : splabels) {

    if (currentBucketIndex < bucketsAL.size()) {
      if (!bucketsAL.get(currentBucketIndex).name.equals(sp.bucketName)) continue;
    }

    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    int distributionType = MAKE_SPLINES_MIXED;
    if (sp.isOnTop && sp.isOnBottom) distributionType = MAKE_SPLINES_MIXED; 
    else if (sp.isOnTop) distributionType = MAKE_SPLINES_TOP_ONLY;
    else if (sp.isOnBottom) distributionType = MAKE_SPLINES_BOTTOM_ONLY;
    sp.blendSPLabelSplinesVertically(dividingNumber, splineCPDistance, maximumPercentSplineSpacing, distributionType);
  }
} // end splitMasterSpLabelsVertical


//
void splitMiddleSpLabel(float divideAmount) {

  PVector shiftVector = new PVector(0, -divideAmount);


  // define the middle splabel
  // shift all splabels above this one up by the divideAmount
  // shift all middle splines of the middle splabel up by the divide amount
  // generate a new middle spline for the middle splabel for the text to be measured against for height
  SpLabel middleSpLabel = null;
  for (SpLabel sp : splabels) {
    if (sp.isMiddleSpLabel) {
      middleSpLabel = sp;
      break;
    }
  }

  // skip out if the middle label is null
  if (middleSpLabel == null) return;


  // grab the top splabels
  ArrayList<SpLabel> topLabels = new ArrayList<SpLabel>();
  for (SpLabel sp : splabels) { 
    if (sp != middleSpLabel && sp.isOnTop) {
      topLabels.add(sp);
    }
  }

  for (SpLabel sp : topLabels) {
    println("xxxx" + sp.bucketName);
  }

  // shift top spLabels by amt
  for (int i = 0; i < topLabels.size(); i++) {
    SpLabel sp = topLabels.get(i);
    sp.topSpline.shift(shiftVector); // always shift up.. because when reading in the file the top spline is diff from the previous' bottom
    sp.bottomSpline.shift(shiftVector);
    // note that only the ordered top need to be shifted since these splines are all in that list
    if (sp.orderedTopSplines != null) {
      for (ArrayList<Spline> spar : sp.orderedTopSplines) {
        if (spar != null) {
          for (Spline spline : spar) {
            if (spline != null && spline != sp.topSpline && spline != sp.bottomSpline) {
              spline.shift(shiftVector);
            }
          }
        }
      }
    }
    if (sp.middleMain != null) for (Spline spline : sp.middleMain) spline.shift(shiftVector);
  }

  // shift the middle splabel splines
  // but keep in mind that the top spline has already been moved
  SpLabel sp = middleSpLabel;
  sp.topSpline.shift(shiftVector); //
  if (sp.middleMain != null) if (sp.middleMain.size() == 2) sp.middleMain.get(0).shift(shiftVector);
  // if (sp.middleTops != null) for (ArrayList<Spline> spar : sp.middleTops) if (spar != null) for (Spline spline : spar) if (spline != null) spline.shift(shiftVector);
  if (sp.orderedTopSplines != null) {
    for (ArrayList<Spline> spar : sp.orderedTopSplines) {
      if (spar != null) {
        for (Spline spline : spar) {
          if (spline != null && spline != sp.topSpline && spline != sp.bottomSpline && spline != sp.middleMain.get(1)) {
            if (!isSameSpline(spline, sp.middleMain.get(1), 20)) { // don't shift it if it is the bottom middle spline
              spline.shift(shiftVector);
            }
          }
        }
      }
    }
  }
} // end splitMiddleSpLabel


//
float getXFromYear(int yearIn, Term t) {
  float x = map(yearIn, yearRange[0], yearRange[1], padding[3], width - padding[1]); 
  return x;
} // end getXFromYear

//
float getYearFromX(float xIn) {
  float year = map(xIn, padding[3], width - padding[1], yearRange[0], yearRange[1]);
  return year;
} // end getYearFromX


// mark the x locations of phrases
boolean termIsAlreadyAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) return false;
  else {
    HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
    if (oldHM.containsKey(t.term)) return true;
    else return false;
  }
} // end termIsAlreadyAtX

//
void markTermAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) usedTermsAtX.put(x, new HashMap<String, Integer>());
  HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
  oldHM.put(t.term, 0);
  usedTermsAtX.put(x, oldHM);
} // end markTermAtX

//  for simplicity it will check the year
boolean fillerTermIsAlreadyAtX(int year, Term t) {
  if (!usedFillerTermsAtX.containsKey(year)) return false;
  else {
    HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedFillerTermsAtX.get(year);
    if (oldHM.containsKey(t.term)) {
      return true;
    }
    else return false;
  }
} // end fillerTermIsAlreadyAtX

//
void markFillerTermAtX(int year, Term t) {
  if (!usedFillerTermsAtX.containsKey(year)) usedFillerTermsAtX.put(year, new HashMap<String, Integer>());
  HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedFillerTermsAtX.get(year);
  oldHM.put(t.term, 0);
  usedFillerTermsAtX.put(year, oldHM);
  //println(" ____marking term " + t.term + " at year: " + year);
} // end markFillerTermAtX

//
void drawDates() {
  float yMidrange = 10f;
  float linePadding = 30f;
  float centerY = height / 2 - (addMiddleDivide ? middleDivideDistance / 2f : 0f);
  strokeWeight(2);
  stroke(lerpColor(dateColor, color(255), .5));
  fill(dateColor);
  textFont(font);
  textSize(12);
  textAlign(CENTER, CENTER);
  for (int i = yearRange[0]; i <= yearRange[1]; i++) {
    if (i == yearRange[0] || i == yearRange[1] || i % 5 == 0) {
      float x = getXFromYear(i, blankTerm);
      line(x, linePadding, x, centerY - yMidrange);
      line(x, height - linePadding, x, centerY + yMidrange);
      text(i, x, centerY);
      //text(i, x, 30);
    }
  }
} // end drawDates






// special needs
// this is for special cases.. such as soviet >> Soviet
String[] capitalizeList = {
  "president", 
  "presidential", 
  "socialist", 
  "atlantic", 
  "pacific", 
  "communist", 
  "congress", 
  "contressional", 
  "apollo", 
  "american", 
  "americans", 
  "soviet", 
  "general motors", 
  "virgin islands", 
  "great plains", 
  "great lakes", 
  "grand rapids", 
  "the royal astronomical society", 
  "the southern polar region", 
  "pacific ocean", 
  "atlantic ocean",
};
String[] capitalizeAll = { // terms to be all caps  gps >> GPS
  "gps", 
  "grb",
};
String doSpecialNeeds(String term) {
  if (Arrays.asList(capitalizeList).contains(term.toLowerCase())) term = capitalizeFirstLetter(term);
  else if (Arrays.asList(capitalizeAll).contains(term.toLowerCase())) term = term.toUpperCase();
  if (term.contains("nasa")) term = term.replace("nasa", "NASA");
  if (term.contains("jpl")) term = term.replace("jpl", "JPL");
  if (term.contains("usa")) term = term.replace("usa", "USA");
  if (term.contains("soviet")) term = term.replace("soviet", "Soviet");
  if (term.contains("french")) term = term.replace("french", "French");
  if (term.contains("american")) term = term.replace("american", "American");
  if (term.contains("venus")) term = term.replace("venus", "Venus");
  if (term.contains("jupiter")) term = term.replace("jupiter", "Jupiter");
  if (term.contains("Soviet union")) term = term.replace("Soviet union", "Soviet Union");
  if (term.equals("white sands")) term = "White Sands";
  if (term.toLowerCase().equals("western unions")) term = "Western Union";
  if (term.toLowerCase().equals("the commission")) term = "the commission";
  if (term.toLowerCase().equals("western experts")) term = "western experts";
  if (term.equals("the eastern pacific ocean")) term = "the Eastern Pacific Ocean";
  if (term.equals("global positioning system")) term = "Global Positioning System";
  if (term.equals("Satellite Service")) term = term.toLowerCase();
  if (term.equals("Intercontinental Ballistic Missiles")) term = term.toLowerCase();
  if (term.equals("Space Exploration")) term = term.toLowerCase();
  if (term.equals("Aerospace industry")) term = term.toLowerCase();
  if (term.equals("Prime contractor")) term = term.toLowerCase();
  if (term.equals("Shut down")) term = term.toLowerCase();
  if (term.equals("Commercial applications")) term = term.toLowerCase();
  if (term.equals("Communications Satellite")) term = term.toLowerCase();
  if (term.equals("Remote control")) term = term.toLowerCase();
  if (term.equals("lunar orbiters")) term = term.toLowerCase();
  if (term.equals("nuclear weapons")) term = term.toLowerCase();
  if (term.equals("solar system")) term = "Solar System";
  if (term.equals("memorandum of understanding")) term = "Memorandum of Understanding";
  if (term.equals("Western analysts")) term = term.toLowerCase();

  return term;
} // end doSpecialNeeds

//
String capitalizeFirstLetter(String s) {
  if (s.length() == 0) return "";
  String[] split = split(s, " ");
  String[] rejoin = new String[0];
  for (int i = 0; i < split.length; i++) if (split[i].length() > 0) rejoin = (String[])append(rejoin, Character.toUpperCase(split[i].charAt(0)) + split[i].substring(1));
  return join(rejoin, " ");
} // end capitalizeFirstLetter


//
//
//
//







//
void outputSpLabels() {
  println("exporting out bucket text");
  for (SpLabel sp : splabels) {

    ArrayList<OutputLabelHelper> outputLabels = new ArrayList<OutputLabelHelper>();
    for (Label l : sp.labels) {
      Letter firstLetter = l.letters.get(0);
      String term = l.baseText;
      float approxYear = getYearFromX(firstLetter.pos.x);
      float middleSize = firstLetter.size;
      float fillAlpha = l.fillAlpha;
      String possiblePosName = l.term.posName;
      int horizAlign = l.labelAlign;
      OutputLabelHelper o = new OutputLabelHelper(term, approxYear, middleSize, fillAlpha, possiblePosName, horizAlign);
      outputLabels.add(o);
    }
    outputLabels = OCRUtils.sortObjectArrayListSimple(outputLabels, "approxYear");
    PrintWriter output = createWriter("bucketTextUsed/" + timeStamp + "/" + sp.bucketName + "-byYear.txt");
    if (outputLabels.size() > 0) output.println(outputLabels.get(0).printHeader());
    for (OutputLabelHelper o : outputLabels) output.println(o);
    output.flush();
    output.close();
    output = createWriter("bucketTextUsed/" + timeStamp + "/" + sp.bucketName + "-bySize.txt");
    outputLabels = OCRUtils.sortObjectArrayListSimple(outputLabels, "middleSize");
    outputLabels = OCRUtils.reverseArrayList(outputLabels);
    if (outputLabels.size() > 0) output.println(outputLabels.get(0).printHeader());
    for (OutputLabelHelper o : outputLabels) output.println(o);
    output.flush();
    output.close();
    output = createWriter("bucketTextUsed/" + timeStamp + "/" + sp.bucketName + "-byPos.txt");
    outputLabels = OCRUtils.sortObjectArrayListSimple(outputLabels, "possiblePosName");
    outputLabels = OCRUtils.reverseArrayList(outputLabels);
    if (outputLabels.size() > 0) output.println(outputLabels.get(0).printHeader());
    for (OutputLabelHelper o : outputLabels) output.println(o);
    output.flush();
    output.close();
  }
  println("end of exporting out bucket text");
} // end outputSpLabels

//
class OutputLabelHelper {
  String term = "";
  float approxYear = 0f;
  float middleSize = 0f;
  float fillAlpha = 0f;
  String possiblePosName = "";
  int horizAlign;
  String horizAlignS;
  // 
  OutputLabelHelper(String term, float approxYear, float middleSize, float fillAlpha, String possiblePosName, int horizAlign) {
    this.term = term;
    this.approxYear = approxYear;
    this.middleSize = middleSize;
    this.fillAlpha = fillAlpha;
    this.possiblePosName = possiblePosName;
    this.horizAlign = horizAlign;
    if (horizAlign == LABEL_ALIGN_LEFT) horizAlignS = "left";
    else if (horizAlign == LABEL_ALIGN_CENTER) horizAlignS = "center";
    else if (horizAlign == LABEL_ALIGN_RIGHT) horizAlignS = "right";
  } // end constructor

  //
  String printHeader() {
    return "approx year, term, approx size, fill alpha percent, possible pos name, horiz align";
  } // end printHeader

  //
  String toString() {
    return nf(approxYear, 0, 1) +","+ term +","+ middleSize +","+ fillAlpha +","+ possiblePosName +","+ horizAlignS;
  } // end toString
} // end class OutputLabel

//
//
//
//
//
//
//


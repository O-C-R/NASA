


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

//
void drawDates() {
  float yMidrange = 10f;
  float linePadding = 30f;
  float centerY = height / 2 - (addMiddleDivide ? middleDivideDistance / 2f : 0f);
  stroke(dateColor, 100);
  fill(dateColor);
  textFont(font);
  textSize(18);
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



//
//
//
//
//
//
//


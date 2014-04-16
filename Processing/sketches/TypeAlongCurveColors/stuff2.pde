


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
void makeVariationSplines() {
  for (SpLabel sp : splabels) {
    sp.makeVariationSpline();
  }
} // endmakeVariationSplines


//
void splitMasterSpLabelsByPercent(float maxLineHeight, float splineCPDistance) {
  println("in splitMasterSpLabelsByPercent");
  for (SpLabel sp : splabels) {
    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    sp.blendSPLabelSplinesByPercent(dividingNumber, splineCPDistance);
  }
} // end splitMasterSpLabelsByPercent

//
void splitMasterSpLabelsVertically(float maxLineHeight, float splineCPDistance) {
  println("in splitMasterSpLabelsVertical");
  for (SpLabel sp : splabels) {
    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    sp.blendSPLabelSplinesVertically(dividingNumber, splineCPDistance);
  }
} // end splitMasterSpLabelsVertical

//
void assignSpLabelNeighbors() {
  for (int i = 0; i < splabels.size(); i++) {
    if (i > 0) {
      if (splabels.get(i - 1).middleSplines.size() > 0) splabels.get(i).topNeighborSpline = splabels.get(i - 1).middleSplines.get(splabels.get(i - 1).middleSplines.size() - 1);
      else {
        if (splabels.get(i - 1).topSpline != null) splabels.get(i).bottomNeighborSpline = splabels.get(i - 1).topSpline;
      }
    }
    if (i < splabels.size() - 1) {
      if (splabels.get(i + 1).middleSplines.size() > 0) splabels.get(i).bottomNeighborSpline = splabels.get(i + 1).middleSplines.get(0);
      else {
        if (splabels.get(i + 1).bottomSpline != null) splabels.get(i).bottomNeighborSpline = splabels.get(i + 1).bottomSpline;
      }
    }
  }
} // end assignSpLabelNeighbors

//
void splitMiddleSpLabel(float divideAmount, PGraphics pg) {
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
  // shift top spLabels by amt
  for (SpLabel sp : topLabels) {
    sp.topSpline.shift(shiftVector);
    for (Spline spline : sp.middleSplines) {
      spline.shift(shiftVector);
    }
    if (sp.variationSpline != null) sp.variationSpline.shift(shiftVector);
  }
  
  // shift the middle splabel splines
  middleSpLabel.topSpline.shift(shiftVector);
  for (int i = 0; i < floor((float)middleSpLabel.middleSplines.size() / 2); i++) {
    middleSpLabel.middleSplines.get(i).shift(shiftVector);
  }
  // make the new middle spline for the middleSpLabel
  if (middleSpLabel.variationSpline != null) middleSpLabel.middleAdjustSpline = middleSpLabel.variationSpline;
  else {
    middleSpLabel.middleAdjustSpline = new Spline();
    middleSpLabel.middleAdjustSpline.addCurvePoint(new PVector(0, pg.height / 2));
    middleSpLabel.middleAdjustSpline.addCurvePoint(new PVector(pg.width, pg.height / 2));
    middleSpLabel.middleAdjustSpline.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
  }
} // end splitMiddleSpLabel


//
float getXFromYear(int yearIn, Term t, PGraphics pg) {
  float x = map(yearIn, yearRange[0], yearRange[1], padding[3], pg.width - padding[1]); 
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
//
//
//
//
//
//





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
//
//
//
//
//
//


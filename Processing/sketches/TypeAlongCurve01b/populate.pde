//

void populateFullForDebug() {
  //

  for (int j = 0; j < splabels.size(); j++) {
    // top one

    Label newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).topSpline);
    if (newLabel != null) splabels.get(j).addLabel(newLabel);
    while (true) {
      float spacer = minLabelSpacing; // between labels?
      float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
      if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
        newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).topSpline);
        lastEndDistance = newLabel.endDistance;
        if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          break;
        }
        else {
          if (newLabel != null) splabels.get(j).addLabel(newLabel);
        }
      }
    }

    // middle ones
    for (int i = 0; i < splabels.get(j).middleSplines.size(); i++) {
      newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).middleSplines.get(i));
      if (newLabel != null) splabels.get(j).addLabel(newLabel);
      // add more until the last label has an endDistance that is 100% of the distance... 
      while (true) {
        float spacer = minLabelSpacing; // between labels?
        float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
        if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).middleSplines.get(i));
          lastEndDistance = newLabel.endDistance;
          if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
            break;
          }
          else {
            if (newLabel != null) splabels.get(j).addLabel(newLabel);
          }
        }
      }
    }

    // bottom one
    if (j == splabels.size() - 1) {
      newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).bottomSpline);
      if (newLabel != null) splabels.get(j).addLabel(newLabel);
      while (true) {
        float spacer = minLabelSpacing; // between labels?
        float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
        if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).bottomSpline);

          lastEndDistance = newLabel.endDistance;
          if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
            break;
          }
          else { 
            if (newLabel != null) splabels.get(j).addLabel(newLabel);
          }
        }
      }
    }
  }
} // end populateFullForDebug


/**
 x -- the x location to try to place the text [assume centered?
 splabel -- the label in question
 text -- the String of text to use to make a label
 spacing -- minimum spacing from the rest of the text
 wiggleroom -- how far to deviate in the case that the spot is already taken
 
 returns true if it placed a new label, false otherwise
 */
boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {
  Spline targetSpline = null;
  int textAlign = LABEL_ALIGN_CENTER;


  // ****** scores ****** // 
  Label[] options = new Label[0];
  //float[] optionLetterHeights = new float[0];
  float[] optionScores = new float[0];
  float blankSideMaxValue = 10; // when there is no closest side value this score will be thrown to it


  for (int i = 0; i < splabel.middleSplines.size() + 2; i++) {
    Spline splineToUse = null;
    if (i == 0) splineToUse = splabel.topSpline;
    else if (i == splabel.middleSplines.size() + 1) splineToUse = splabel.bottomSpline;
    else splineToUse = splabel.middleSplines.get(i - 1);

    // check center, then right, then left
    ArrayList<PVector> intersectionPointAr = splineToUse.getPointByAxis("x", new PVector(xIn, 0));
    if (intersectionPointAr == null) continue;

    PVector intersectionPoint = intersectionPointAr.get(0); 
    float percentPoint = splineToUse.getPercentByAxis("x", new PVector(xIn, 0));
    float distanceToUse = percentPoint * splineToUse.totalDistance;

    Label centerLabel = splabel.makeCharLabel(text, LABEL_ALIGN_CENTER, distanceToUse, wiggleRoom, splineToUse);
    float centerLabelHeight = centerLabel.getApproxLetterHeightAtPoint(intersectionPoint);

    // keep track of the center spacing to use for the wiggle room when finding valid left and right side Labels
    float centerEndDistance = centerLabel.endDistance + spacing;
    float centerStartDistance = centerLabel.startDistance - spacing;

    // verify that center will fit
    boolean centerWillFit = splabel.spacingIsOpen(splineToUse, centerStartDistance, centerEndDistance);

    // get the rightmost side
    Label rightLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse - wiggleRoom, true);
    Label rightSideLabel = null;
    float rightLabelHeight = defaultFontSize;
    boolean rightSideWillFit = false;
    if (rightLabelExisting != null) {
      float rightDistanceToUse = rightLabelExisting.startDistance - spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (rightDistanceToUse < centerEndDistance + wiggleRoom) {
        rightSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_RIGHT, rightDistanceToUse, wiggleRoom, splineToUse);
        rightSideWillFit = splabel.spacingIsOpen(splineToUse, rightSideLabel.startDistance - spacing, rightSideLabel.endDistance);
        rightLabelHeight = rightSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
      }
    }

    // get the leftmost side
    Label leftLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse + wiggleRoom, false);
    Label leftSideLabel = null;
    float leftLabelHeight = defaultFontSize;
    boolean leftSideWillFit = false;
    if (leftLabelExisting != null) {
      float lefttDistanceToUse = leftLabelExisting.endDistance + spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (lefttDistanceToUse > centerStartDistance - wiggleRoom) {
        leftSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_LEFT, lefttDistanceToUse, wiggleRoom, splineToUse);
        leftSideWillFit = splabel.spacingIsOpen(splineToUse, leftSideLabel.startDistance, leftSideLabel.endDistance + spacing);
        leftLabelHeight = leftSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
      }
    }

    // SCORING
    //if (centerWillFit) splabel.addLabel(centerLabel); // debug
    // center
    if (centerWillFit) {
      options = (Label[])append(options, centerLabel);
      float centerToRightDistance = blankSideMaxValue;
      float centerToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        centerToRightDistance = constrain(map(rightLabelExisting.startDistance - centerLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        centerToLeftDistance = constrain(map(centerLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(centerLabelHeight, centerToLeftDistance, centerToRightDistance));
    }

    // if (rightSideWillFit) splabel.addLabel(rightSideLabel); // debug
    // right
    if (rightSideWillFit && rightSideLabel != null) {
      options = (Label[])append(options, rightSideLabel);
      float rightToRightDistance = blankSideMaxValue;
      float rightToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        rightToRightDistance = constrain(map(rightLabelExisting.startDistance - rightSideLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        rightToLeftDistance = constrain(map(rightSideLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(rightLabelHeight, rightToLeftDistance, rightToRightDistance));
    }

    //if (leftSideWillFit) splabel.addLabel(leftSideLabel); // debug
    // left
    if (leftSideWillFit && leftSideLabel != null) {
      options = (Label[])append(options, leftSideLabel);
      float leftToRightDistance = blankSideMaxValue;
      float leftToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        leftToRightDistance = constrain(map(rightLabelExisting.startDistance - leftSideLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        leftToLeftDistance = constrain(map(leftSideLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(leftLabelHeight, leftToLeftDistance, leftToRightDistance));
    }

    // use the one with either the tallest letter size or smallest abs(distance between it and its neighbor
    // determined by the weird makePopulationScore() function
  }


  for (int k = 0; k < optionScores.length; k++) {
    // println(" k: " + k + " -- score: " + optionScores[k]);
  }
  // lastly take the one with the lowest score
  if (optionScores.length <= 0) return false;
  else {
    Label currentFavorite = null;
    float currentLowScore = 0f;
    for (int i = 0; i < optionScores.length; i++) {
      if (i == 0 || optionScores[i] < currentLowScore) {
        currentFavorite = options[i];
        currentLowScore = optionScores[i];
      }
    }

    if (currentFavorite != null) {
      splabel.addLabel(currentFavorite);
    }
    return true;
  }
} // end populateBiggestSpaceAlongX


//
// this will arbitrarily decide a numerical score based on the distance from other labels to the sides and the letter size
// this score is calculated through random guesswork on my part
float makePopulationScore(float letterHt, float leftSide, float rightSide) {
  float score = 30 * 1 / letterHt;
  score += leftSide;
  score += rightSide;
  return score;
} // end makePopulationScore



//
//
//
//
//
//
//


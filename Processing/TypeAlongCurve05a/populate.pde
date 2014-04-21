//
//
void snap() {
  println("snap!");
} // end snap


void populateFullForDebug() {
  //
  /*
  for (int j = 0; j < splabels.size(); j++) {
   println("populating: " + splabels.get(j).bucketName + " :: " + j + "/" + splabels.size());
   // top one
   
   Label newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).topSpline);
   if (newLabel != null) splabels.get(j).addLabel(newLabel);
   while (true) {
   float spacer = minLabelSpacing * random(1, 1.2); // between labels?
   float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
   if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).topSpline);
   lastEndDistance = newLabel.endDistance;
   if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   break;
   }
   else {
   if (newLabel != null) {
   splabels.get(j).addLabel(newLabel);
   print(".");
   }
   }
   }
   }
   println("_done with top");
   
   // middle ones
   for (int i = 0; i < splabels.get(j).middleSplines.size(); i++) {
   newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).middleSplines.get(i));
   if (newLabel != null) splabels.get(j).addLabel(newLabel);
   // add more until the last label has an endDistance that is 100% of the distance... 
   while (true) {
   float spacer = minLabelSpacing * random(1, 1.2); // between labels?
   float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
   if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).middleSplines.get(i));
   lastEndDistance = newLabel.endDistance;
   if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   break;
   }
   else {
   if (newLabel != null) {
   splabels.get(j).addLabel(newLabel);
   print(".");
   }
   }
   }
   }
   println("_done with middle: " + i + "/" + splabels.get(j).middleSplines.size());
   }
   
   // bottom one
   if (j == splabels.size() - 1) {
   newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).bottomSpline);
   if (newLabel != null) splabels.get(j).addLabel(newLabel);
   while (true) {
   float spacer = minLabelSpacing * random(1, 1.2); // between labels?
   float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
   if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).bottomSpline);
   
   lastEndDistance = newLabel.endDistance;
   if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
   break;
   }
   else { 
   if (newLabel != null) {
   splabels.get(j).addLabel(newLabel);
   print(".");
   }
   }
   }
   }
   println("_done with bottom");
   }
   }
   */
} // end populateFullForDebug



//
String tryToPopulateBucketWithNextTerm(Bucket b) {
  //println("in tryToPopulateBucketWithNextTerm for bucket: " + b.name);
  Term termToTryToPlace = null;
  String status = null;
  if (b.bucketTermsRemainingAL.size() == 0) return POPULATE_STATUS_EMPTY;
  else {
    termToTryToPlace = b.bucketTermsRemainingAL.get(0);
  }

  //println("   trying to place term: " + termToTryToPlace.term);

  boolean didPlace = placeNextTermForBucket(b, termToTryToPlace);
  if (didPlace) {
    //println("placed term: " + termToTryToPlace.term + " for bucket: " + b.name);
    //println("  " + b.name + " has " + b.bucketTermsRemainingAL.size() + " terms left to place");

    usedTerms.put(termToTryToPlace.term, termToTryToPlace);
    usedTermsSimple.put(b.name + "-" + termToTryToPlace.term, termToTryToPlace);

    //println("just placed term: " + termToTryToPlace.term + " and now size is: " + usedTerms.size());

    status = POPULATE_STATUS_SUCCESS;
  }
  else {
    //println("could not place term: " + termToTryToPlace.term + " .. option bucket.size for " + b.name + ": " + b.bucketTermsRemainingAL.size());
    print("x-" + b.name);

    b.failedTerms.put(termToTryToPlace.term, termToTryToPlace);

    status = POPULATE_STATUS_FAIL;
  }

  // if it got this far then remove this term from all buckets
  if (status.equals(POPULATE_STATUS_SUCCESS)) {
    //println("TAKING OUT TERM: " + termToTryToPlace.term);
    for (Bucket everyB : bucketsAL) {
      everyB.takeOutTerm(termToTryToPlace);
    }
    b.bucketTermsRemainingAL.remove(termToTryToPlace); // keep it in?
  }
  else if (status.equals(POPULATE_STATUS_FAIL)) {
    b.bucketTermsRemainingAL.remove(termToTryToPlace); // keep it in?
  }
  return status;
} // end tryToPopulateBucketWithNextTerm 



//
boolean placeNextTermForBucket(Bucket b, Term t) {
  //println("in placeNextTermForBucket for bucket: " + b.name + " and term: " + t.term);
  boolean didPlace = false;
  SpLabel splabel = null;
  for (SpLabel l : splabels) if (l.bucketName.equals(b.name)) splabel = l;
  if (splabel == null) return false; // cut out if for some reason this bucket is not associated with an splabel 

  //boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {
  // figure out the x

  int seriesTracker = 0; // all iterations
  int seriesTries = 0; // only the iterations where it tried to place it
  int seriesSkipTracker = 0; // the skipped iterations

  textFont(font);
  textSize(defaultFontSize);
  float basicTextSize = textWidth(t.term);


  for (int i = 0; i < t.seriesOrderedIndices.length; i++) {
    float seriesValue = t.series[t.seriesOrderedIndices[i]];
    // skip out if the value is 0;
    if (seriesValue == 0) return false;
    // otherwise try to place it at the appropriate x

    //float x = map(t.seriesOrderedIndices[i], 0, t.series.length - 1, padding[3], width - padding[1]);
    float x = getXFromYear(yearRange[0] + t.seriesOrderedIndices[i], t);

    // check the constrainRangeX
    if (x < constrainRangeX[0] || x > constrainRangeX[1]) continue;

    // check if that term is already at this x location
    if (termIsAlreadyAtX((int)x, t)) continue;

    // look for skip option here
    boolean shouldSkip = splabel.shouldSkip(x, basicTextSize);

    if (!shouldSkip) {
      didPlace = populateBiggestSpaceAlongX(x, splabel, t.term, minLabelSpacing, wiggleRoom);
      seriesTries++;
    }
    else {
      seriesSkipTracker++;
      //println("SKIPPING: " + t.term + " at " + (int)x);
    }

    seriesTracker = i;
    if (didPlace) {
      // mark that the term was placed at this x
      markTermAtX((int)x, t);
      break;
    }
    else {
      // try to mark it as a skip location for the splabel
      //println("XXXXX MARKING SKIP ZONE FOR " + t.term + " at: " + (int)x);
      splabel.markSkipZone((int)x, basicTextSize);
    }
  } // end for time series
  return didPlace;
} // end placeNextTermForBucket

//
/*
// broken, need to fix with the new entity pos array
 void repopulateFromFailedHM() {
 for (Bucket b : bucketsAL) {
 for (Map.Entry me : b.failedTerms.entrySet()) {
 Term failedTerm = (Term)me.getValue();
 b.bucketTermsRemainingAL.add(failedTerm);
 }
 b.failedTerms.clear();
 }
 } // end repopulateFromFailedHM 
 */




/**
 x -- the x location to try to place the text [assume centered?
 splabel -- the label in question
 text -- the String of text to use to make a label
 spacing -- minimum spacing from the rest of the text
 wiggleroom -- how far to deviate in the case that the spot is already taken
 
 returns true if it placed a new label, false otherwise
 */
 // an attempt to reuse these things
ArrayList<PVector> intersectionPointAr = new ArrayList<PVector>();
PVector intersectionPoint = new PVector();
//
boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {
  long startTime = millis();
  //println("in populateBiggestSpaceAlongX for splabel: " + splabel.bucketName + " and xIn: " + xIn);

  int textAlign = LABEL_ALIGN_CENTER;

  // ****** scores ****** // 
  Label[] options = new Label[0];
  //float[] optionLetterHeights = new float[0];
  float[] optionScores = new float[0];
  float blankSideMaxValue = 10; // when there is no closest side value this score will be thrown to it

  ArrayList<Spline> splineOptions = new ArrayList<Spline>();

  for (ArrayList<Spline> ar : splabel.orderedTopSplines) { 
    for (Spline s : ar) {
      float startX = s.facetPoints[0].x;
      float endX = s.facetPoints[s.facetPoints.length - 1].x;
      if ((xIn >= startX && xIn <= endX) || (xIn >= endX && xIn <= startX)) {
        splineOptions.add(s);
      }
    }
  }
  for (ArrayList<Spline> ar : splabel.orderedBottomSplines) {
    for (Spline s : ar) {
      float startX = s.facetPoints[0].x;
      float endX = s.facetPoints[s.facetPoints.length - 1].x;
      if ((xIn >= startX && xIn <= endX) || (xIn >= endX && xIn <= startX)) {
        splineOptions.add(s);
      }
    }
  }

  //println(" found total splineOptions: " + splineOptions.size() +  " for term: " + text);
  // cut out if there arent any options available
  if (splineOptions.size() == 0) return false;



  // run through the options and see if a label can be made, if so, then do the whole scoring thing



  for (Spline splineToUse : splineOptions) {

    //long debugTime = millis();
    //long debugTime2 = millis();

    // check center, then right, then left
    intersectionPointAr = splineToUse.getPointByAxis("x", new PVector(xIn, 0));
    //println("    time taken to get x intersection point: " + (debugTime2 - millis()) + "ms");
    //debugTime2 = millis();
    intersectionPoint = intersectionPointAr.get(0); 
    float percentPoint = splineToUse.getPercentByAxis("x", new PVector(xIn, 0));
    float distanceToUse = percentPoint * splineToUse.totalDistance;



    Label centerLabel = splabel.makeCharLabel(text, LABEL_ALIGN_CENTER, (splineToUse.useUpHeight ? LABEL_VERTICAL_ALIGN_BASELINE : LABEL_VERTICAL_ALIGN_TOP), distanceToUse, wiggleRoom, splineToUse);
    //println("    time taken to MAKE center label: " + (debugTime2 - millis()) + "ms");
    //debugTime2 = millis();
    float centerLabelHeight = 0f;
    float centerLabelSmallestHeight = 0f;
    if (centerLabel != null) {
      centerLabelHeight = centerLabel.getApproxLetterHeightAtPoint(intersectionPoint);
      centerLabelSmallestHeight = centerLabel.getMinimumLetterHeight();
    }
    
    //println("    time taken to get center label numbers: " + (debugTime2 - millis()) + "ms");
    //debugTime2 = millis();
    
    // keep track of the center spacing to use for the wiggle room when finding valid left and right side Labels
    float centerEndDistance = 0f;
    if (centerLabel != null) centerEndDistance = centerLabel.endDistance + spacing;
    float centerStartDistance = 0f;
    if (centerLabel != null) centerStartDistance = centerLabel.startDistance - spacing;

    // verify that center will fit
    boolean centerWillFit = splabel.spacingIsOpen(splineToUse, centerStartDistance, centerEndDistance);
    
    //println("    time taken to check center label will fit: " + (debugTime2 - millis()) + "ms");
    //debugTime2 = millis();

    // get the rightmost side
    //debugTime2 = millis();
    Label rightLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse - wiggleRoom, true);
    //println("    time taken to check for right labels: " + (debugTime2 - millis()) + "ms");
    //debugTime2 = millis();
    //Label rightLabelExisting = null; /// debug
    Label rightSideLabel = null;
    float rightLabelHeight = defaultFontSize;
    float rightLabelSmallestHeight = 0f;
    boolean rightSideWillFit = false;

    if (rightLabelExisting != null) {
      float rightDistanceToUse = rightLabelExisting.startDistance - spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (rightDistanceToUse < centerEndDistance + wiggleRoom) {
        rightSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_RIGHT, (splineToUse.useUpHeight ? LABEL_VERTICAL_ALIGN_BASELINE : LABEL_VERTICAL_ALIGN_TOP), rightDistanceToUse, wiggleRoom, splineToUse);
        //println("    time taken to MAKE right label: " + (debugTime2 - millis()) + "ms");
        //debugTime2 = millis();
        //rightSideLabel = null;
        if (rightSideLabel != null) rightSideWillFit = splabel.spacingIsOpen(splineToUse, rightSideLabel.startDistance - spacing, rightSideLabel.endDistance);
        if (rightSideLabel != null) {
          rightLabelHeight = rightSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
          rightLabelSmallestHeight = rightSideLabel.getMinimumLetterHeight();
        }
        //println("    time taken to check right label fit: " + (debugTime2 - millis()) + "ms");
      }
    }
    // get the leftmost side

    //debugTime2 = millis();
    Label leftLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse + wiggleRoom, false);
    //println("    time taken to check for left labels: " + (debugTime2 - millis()) + "ms");
    //Label leftLabelExisting = null; // debug
    Label leftSideLabel = null;
    float leftLabelHeight = defaultFontSize;
    float leftLabelSmallestHeight = 0f;
    boolean leftSideWillFit = false;
    if (leftLabelExisting != null) {
      float lefttDistanceToUse = leftLabelExisting.endDistance + spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (lefttDistanceToUse > centerStartDistance - wiggleRoom) {
        leftSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_LEFT, (splineToUse.useUpHeight ? LABEL_VERTICAL_ALIGN_BASELINE : LABEL_VERTICAL_ALIGN_TOP), lefttDistanceToUse, wiggleRoom, splineToUse);
        //println("    time taken to MAKE left label: " + (debugTime2 - millis()) + "ms");
        //debugTime2 = millis();
        if (leftSideLabel != null) leftSideWillFit = splabel.spacingIsOpen(splineToUse, leftSideLabel.startDistance, leftSideLabel.endDistance + spacing);
        if (leftSideLabel != null) {
          leftLabelHeight = leftSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
          leftLabelSmallestHeight = leftSideLabel.getMinimumLetterHeight();
        }
        //println("    time taken to check left label fit: " + (debugTime2 - millis()) + "ms");
      }
    }



    //println(" time taken to make labels: " + (debugTime - millis()) + "ms  text: " + text + "  left null? " + (leftLabelExisting == null) + " right null? " + (rightLabelExisting == null));
    //println("   leftSideLabel is null? " + (leftSideLabel == null) + "   rightSideLabel is null? " + (rightSideLabel == null));
    //debugTime = millis();

    // SCORING
    //if (centerWillFit) splabel.addLabel(centerLabel); // debug
    // center
    if (centerLabel != null && centerWillFit && centerLabelHeight > minCharHeight && centerLabelSmallestHeight >= minCharHeight) {
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
    if (rightSideWillFit && rightSideLabel != null && rightLabelHeight> minCharHeight && rightLabelSmallestHeight >= minCharHeight) {
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
    if (leftSideWillFit && leftSideLabel != null && leftLabelHeight > minCharHeight && leftLabelSmallestHeight >= minCharHeight) {
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


    //println(" time taken to get to do scoring: " + (debugTime - millis()) + "ms  text: " + text);
  } // end for to go through the spline options

  // check the option scores, if any, and pick the one with the lowest score

  for (int k = 0; k < optionScores.length; k++) {
    //println(" k: " + k + " -- score: " + optionScores[k] + " for optionScores.length: " + optionScores.length);
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

    //println(" total time taken to make options: " + (startTime - millis()) + "ms  text: " + text + "  total options: " + options.length);

    // clean it all up?
    if (currentFavorite != null) {
      for (int i = 0; i < options.length; i++) {
        if (options[i] != currentFavorite) options[i] = null;
      }
    }

    if (currentFavorite != null) {
      splabel.addLabel(currentFavorite);
      //println("ADDING TERM");

      return true;
    }
    else return false;
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

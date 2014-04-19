//
//
void snap() {
  println("snap!");
} // end snap


void populateFullForDebug() {
  //

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
} // end populateFullForDebug



//
String tryToPopulateBucketWithNextTerm(Bucket b) {
  Term termToTryToPlace = null;
  String status = null;
  if (b.bucketTermsRemainingAL.size() == 0) return POPULATE_STATUS_EMPTY;
  else {
    termToTryToPlace = b.bucketTermsRemainingAL.get(0);
  }
  boolean didPlace = placeNextTermForBucket(b, termToTryToPlace);
  if (didPlace) {
    //println("placed term: " + termToTryToPlace.term + " for bucket: " + b.name);
    //println("  " + b.name + " has " + b.bucketTermsRemainingAL.size() + " terms left to place");
    usedTerms.put(termToTryToPlace.term, termToTryToPlace);
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
    }

    seriesTracker = i;
    if (didPlace) {
      // mark that the term was placed at this x
      markTermAtX((int)x, t);
      break;
    }
    else {
      // try to mark it as a skip location for the splabel
      splabel.markSkipZone(x, basicTextSize);
    }
  }
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
boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {

  int textAlign = LABEL_ALIGN_CENTER;

  // ****** scores ****** // 
  Label[] options = new Label[0];
  //float[] optionLetterHeights = new float[0];
  float[] optionScores = new float[0];
  float blankSideMaxValue = 10; // when there is no closest side value this score will be thrown to it


  // assume that the middle and middleTops and middleBottoms has been made
  int totalLayers = 1 + 2 + splabel.middleTops.size() + splabel.middleBottoms.size(); // bottom + middles + middleTops and middleBottoms

  for (int i = 0; i < totalLayers; i++) {
    ArrayList<Spline> targetLayer = new ArrayList<Spline>();
    ArrayList<Spline> nextLayer = new ArrayList<Spline>();
    Spline targetSpline = null;
    Spline nextSpline = null;
    Spline topSpline = splabel.topSpline;
    if (i == 0) {
      targetLayer.add(splabel.bottomSpline);
      // bottom spline
      if (splabel.middleBottoms.size() > 0) {
        nextLayer = splabel.middleBottoms.get(splabel.middleBottoms.size() - 1);
      }
      else {
        nextLayer.add(splabel.middleMain.get(1)); // if there arent any middle bottoms, then get the bottom middle spline
      }

      for (Spline s : nextLayer) {
        fill(0, 127, 177);
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
        fill(255);
        textSize(15);
        //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
        noFill();
      }
    }
    else if (i > 0 && i < 1 + splabel.middleBottoms.size() - 2) {
      targetLayer = splabel.middleBottoms.get(splabel.middleBottoms.size() - i - 1);
      // bottom middles that is not the bottom middle closest to the center
      nextLayer = splabel.middleBottoms.get(splabel.middleBottoms.size() - i - 2);

      for (Spline s : nextLayer) {
        fill(0, 177, 127);
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
        fill(255);
        textSize(15);
        //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
        noFill();
      }
    }
    else if (splabel.middleBottoms.size() > 0 && i == splabel.middleBottoms.size() - 1) {
      targetLayer = splabel.middleBottoms.get(splabel.middleBottoms.size() - i - 1);
      // the bottom layer of the middleBottoms
      nextLayer.add(splabel.middleMain.get(1));


      for (Spline s : nextLayer) {
        fill(200, 177, 7);
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
        fill(255);
        textSize(15);
        //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
        noFill();
      }
    } 
    else if (splabel.middleBottoms.size() > 0 && i == splabel.middleBottoms.size()) {
      targetLayer.add(splabel.middleMain.get(1));
      // the bottom middle
      nextLayer.add(splabel.middleMain.get(0));

      for (Spline s : nextLayer) {
        fill(150, 177, 7);
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
        fill(255);
        textSize(15);
        //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
        noFill();
      }
    }
    else if (i >= splabel.middleBottoms.size() + 1 && i < totalLayers - 1) {
      // working somewhere in the middleTops
      if (splabel.middleTops.size() > 0 && i < totalLayers - 2) {
        nextLayer = splabel.middleTops.get(i - (1 + splabel.middleBottoms.size()));
      }
      else if (splabel.middleTops.size() > 0 && i == totalLayers - 2) {
        nextLayer.add(topSpline);
      }
      else {
        nextLayer.add(topSpline); // if there arent any middle tops, then just use the topSpline
      }
      if (i > splabel.middleBottoms.size() + 1 && splabel.middleTops.size() > 0 && i < splabel.middleBottoms.size() + 2 + splabel.middleTops.size()) {
        targetLayer = splabel.middleTops.get(i - (2 + splabel.middleBottoms.size()));
      }
      else {
        targetLayer.add(splabel.middleMain.get(0));
      }
      
       for (Spline s : nextLayer) {
        fill(255, 0, 255);
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
        fill(255);
        textSize(15);
        //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
        noFill();
      }
    }
    else {
      if (i > splabel.middleBottoms.size() + 2 && splabel.middleTops.size() > 0 && i <= splabel.middleBottoms.size() + 2 + splabel.middleTops.size()) {
        targetLayer = splabel.middleTops.get(splabel.middleTops.size() - 1);
      }
      else {
        targetLayer.add(splabel.middleMain.get(0));
      }
      // the top middleTop
      nextLayer.add(topSpline); // if there arent any middle tops, then just use the topSpline
    }



    println("i: " + i + " splabel.middleBottoms.size(): " + splabel.middleBottoms.size() + " splabel.middleTops.size(): " + splabel.middleTops.size() + " targetLayer.size(): " + targetLayer.size() + " nextLayer.size(): " + nextLayer.size());
    // check whether or not the x position is even within the options per layer

    for (Spline s : nextLayer) {
      fill(250, 77, 255);
      ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 10, 10);
      if (i == 13) {
        //ellipse(s.curvePoints.get(3).x, s.curvePoints.get(3).y, 30, 30);
      }
      fill(255);
      textSize(15);
      //text(i, s.curvePoints.get(3).x + 20 + i * 4, s.curvePoints.get(3).y );
      noFill();
    }

    // cut out if no target
    //if (targetSpline == null) continue;
    if (targetLayer.size() == 0) continue;
    targetSpline = targetLayer.get(0);



    stroke(255);
    //line(targetSpline.curvePoints.get(0).x, targetSpline.curvePoints.get(0).y, 100, 200);

    for (Spline s : nextLayer) {
      float startX = s.curvePoints.get(1).x;
      float endX = s.curvePoints.get(s.curvePoints.size() - 2).x;
      if ((xIn >= startX && xIn <= endX) || (xIn >= endX && xIn <= startX)) {
        nextSpline = s;
        // break;
      }
      ellipse(s.curvePoints.get(1).x, s.curvePoints.get(1).y, 3, 3);
    }


    // test
    if ( nextSpline != null) {
      ArrayList<PVector> aAL = targetSpline.getPointByAxis("x", new PVector(i * 14, 0));
      ArrayList<PVector> bAL = nextSpline.getPointByAxis("x", new PVector((1 + i) * 34, 0));
      if (aAL != null && bAL != null) {
        stroke(0, 255, 0);
        line(aAL.get(0).x, aAL.get(0).y, bAL.get(0).x, bAL.get(0).y);
        noFill();
        stroke(0, 0, 255);
        ellipse(aAL.get(0).x, aAL.get(0).y, 10, 10);
      }
    }
  } // end i layer for



  /*
  for (int i = 0; i < splabel.middleSplines.size() + 2; i++) {
   // skip the top one if it is not the top splabel!
   if (i == 0 && splabel.topNeighborSpline != null) continue;
   
   Spline splineToUse = null;
   if (i == 0) splineToUse = splabel.topSpline;
   else if (i == splabel.middleSplines.size() + 1) splineToUse = splabel.bottomSpline;
   else splineToUse = splabel.middleSplines.get(i - 1);
   
   // check center, then right, then left
   ArrayList<PVector> intersectionPointAr = splineToUse.getPointByAxis("x", new PVector(xIn, 0));
   if (intersectionPointAr == null || intersectionPointAr.size() == 0) continue;
   
   PVector intersectionPoint = intersectionPointAr.get(0); 
   float percentPoint = splineToUse.getPercentByAxis("x", new PVector(xIn, 0));
   float distanceToUse = percentPoint * splineToUse.totalDistance;
   
   Label centerLabel = splabel.makeCharLabel(text, LABEL_ALIGN_CENTER, distanceToUse, wiggleRoom, splineToUse);
   float centerLabelHeight = 0f;
   float centerLabelSmallestHeight = 0f;
   if (centerLabel != null) {
   centerLabelHeight = centerLabel.getApproxLetterHeightAtPoint(intersectionPoint);
   centerLabelSmallestHeight = centerLabel.getMinimumLetterHeight();
   }
   
   // keep track of the center spacing to use for the wiggle room when finding valid left and right side Labels
   float centerEndDistance = 0f;
   if (centerLabel != null) centerEndDistance = centerLabel.endDistance + spacing;
   float centerStartDistance = 0f;
   if (centerLabel != null) centerStartDistance = centerLabel.startDistance - spacing;
   
   // verify that center will fit
   boolean centerWillFit = splabel.spacingIsOpen(splineToUse, centerStartDistance, centerEndDistance);
   
   // get the rightmost side
   Label rightLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse - wiggleRoom, true);
   Label rightSideLabel = null;
   float rightLabelHeight = defaultFontSize;
   float rightLabelSmallestHeight = 0f;
   boolean rightSideWillFit = false;
   if (rightLabelExisting != null) {
   float rightDistanceToUse = rightLabelExisting.startDistance - spacing;
   // check that the rightDistanceToUse is within the wiggle room
   if (rightDistanceToUse < centerEndDistance + wiggleRoom) {
   rightSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_RIGHT, rightDistanceToUse, wiggleRoom, splineToUse);
   if (rightSideLabel != null) rightSideWillFit = splabel.spacingIsOpen(splineToUse, rightSideLabel.startDistance - spacing, rightSideLabel.endDistance);
   if (rightSideLabel != null) {
   rightLabelHeight = rightSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
   rightLabelSmallestHeight = rightSideLabel.getMinimumLetterHeight();
   }
   }
   }
   
   // get the leftmost side
   Label leftLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse + wiggleRoom, false);
   Label leftSideLabel = null;
   float leftLabelHeight = defaultFontSize;
   float leftLabelSmallestHeight = 0f;
   boolean leftSideWillFit = false;
   if (leftLabelExisting != null) {
   float lefttDistanceToUse = leftLabelExisting.endDistance + spacing;
   // check that the rightDistanceToUse is within the wiggle room
   if (lefttDistanceToUse > centerStartDistance - wiggleRoom) {
   leftSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_LEFT, lefttDistanceToUse, wiggleRoom, splineToUse);
   if (leftSideLabel != null) leftSideWillFit = splabel.spacingIsOpen(splineToUse, leftSideLabel.startDistance, leftSideLabel.endDistance + spacing);
   if (leftSideLabel != null) {
   leftLabelHeight = leftSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
   leftLabelSmallestHeight = leftSideLabel.getMinimumLetterHeight();
   }
   }
   }
   
   
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
   }
   
   // check the option scores, if any, and pick the one with the lowest score
   for (int k = 0; k < optionScores.length; k++) {
   //println(" k: " + k + " -- score: " + optionScores[k]);
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
   */

  return false;
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


//
void fillInTheGapsForBucket(Bucket b) {
  println("in fillInTheGapsForBucket for bucket: " + b.name);
  long startTime = millis();
  int count = 0;

  int optionTries = 20; // will make this many labels before picking the one that has the 'highest' score

  float automaticWin = minLabelSpacing * 1.75; // when a label is made that is within this distance of the endDistance [without going over] then Bob Barker declares it to be the winner
  float closestCutoff = 3 * minLabelSpacing; // when the options are all greater than this then it will choose the first one


  // make a list of the available splines for this bucket based on the highest avg ht value
  ArrayList<Spline> orderedSplines = new ArrayList<Spline>();
  SpLabel targetSpLabel = null;
  for (SpLabel sp : splabels) if (b.name.equals(sp.bucketName)) targetSpLabel = sp;
  if (targetSpLabel == null) return; // cut out if there is no splabel

  ArrayList<Spline> usedSplines = new ArrayList<Spline>();
  for (ArrayList<Spline> spar : targetSpLabel.orderedTopSplines) usedSplines.addAll(spar);
  for (ArrayList<Spline> spar : targetSpLabel.orderedBottomSplines) usedSplines.addAll(spar);

  for (int i = 0; i < usedSplines.size(); i++) {
    // skip the middle bottom
    if (skipMiddleLine && targetSpLabel.isOnTop && targetSpLabel.isOnBottom) {
      if (usedSplines.get(i).useUpHeight && isSameSpline(usedSplines.get(i), targetSpLabel.middleMain.get(1), 20)) {
        continue;
      }
    }
    float thisAvgHt = getAvgSplineHeight(usedSplines.get(i));
    if (thisAvgHt == 0) continue; // skip out if its a wimpy spline
    boolean foundSpot = false;
    for (int j = 0; j < orderedSplines.size(); j++) {
      float otherAvgHeight = getAvgSplineHeight(orderedSplines.get(j));
      if (thisAvgHt > otherAvgHeight) {
        orderedSplines.add(j, usedSplines.get(i));
        foundSpot = true;
        break;
      }
    }
    if (!foundSpot) {
      orderedSplines.add(usedSplines.get(i));
    }
  } 

  println("finished ordering splines with total of " + orderedSplines.size() + " of a total usedSplines: " + usedSplines.size());
  println("  highest avg height as: " + getAvgSplineHeight(orderedSplines.get(0)) + " and lowest as: " + getAvgSplineHeight(orderedSplines.get(orderedSplines.size() - 1)));

  // now go through from left to right and try to fill in the gaps...

  for (int i = 0; i < orderedSplines.size(); i++) {
    //if (i != 10) continue;

    Label currentLastLabel = null;
    Label currentNextLabel = null;
    int currentNextLabelIndex = 0;

    Spline s = orderedSplines.get(i);
    ArrayList<Label> splineLabels = targetSpLabel.getOrderedLabelsOnSpline(s);
    if (splineLabels.size() > 0) currentNextLabel = splineLabels.get(currentNextLabelIndex); 
    //println("spline: " + i + " has " + splineLabels.size() + " labels and avg ht: " + getAvgSplineHeight(s));
    // note: the minimum distance will be 3 * minLabelSpacing


    float startDistance = 0f;
    float endDistance = s.totalDistance;
    int manualBreak = 0;
    while (true) {
      if (currentLastLabel == null) {
        // nothing
      }
      else {
        startDistance = currentLastLabel.endDistance + minLabelSpacing;
      }
      if (currentNextLabel == null || splineLabels.size() == 0) {
        // nothing
      }
      else {
        endDistance =  currentNextLabel.startDistance - minLabelSpacing;
      }
      if (startDistance >= s.totalDistance) break; // SKIP OUT IF THE DIST IS GREATER THAN THE SPLINE DISTANCE

      // if there just isnt enough room then move on to the next label
      if (endDistance - startDistance < 3 * minLabelSpacing) {
      }

      ArrayList<Term> termOptions = getOrderedTermOptionsForDistance(startDistance, endDistance, s, b);
      if (termOptions.size() == 0) break; // SKIP OUT IF THERE ARE NO MORE OPTIONS

      // do a loop to make labels for each of the options, 
      // take the one that gets closest to the target endDistance without going over


      // just use the first termOption
      Label successfulLabel = null;
      Term targetTerm = null;
      boolean isAtEnd = false; // mark this when at the end
      boolean isUpAgainstNextLabel = false; // mark this when it tries and fails to place a term at a spot due to an existing label there
      // case of an empty line where there is no next label or the system is past the last label 
      if (currentNextLabel == null) {
        // String label, int textAlign, int labelAlignVertical, float targetDistance, float wiggleRoom, Spline s, boolean straightText, boolean varySize) {
        // try to get a label in..
        for (int k = 0; k < optionTries; k++) {
          if (k >= termOptions.size()) break;
          targetTerm = termOptions.get(k);
          Label newLabel = targetSpLabel.makeLabel(targetTerm, targetTerm.term, LABEL_ALIGN_LEFT, (s.useUpHeight ? LABEL_VERTICAL_ALIGN_BASELINE : LABEL_VERTICAL_ALIGN_TOP), startDistance, 0f, s, false, true);
          if (newLabel != null) {
            if (newLabel.endDistance < s.totalDistance) {
              successfulLabel = newLabel;
              break;
            }
            else {
              isAtEnd = true;
            }
          }
        }
      }
      // but if there is a next label do more complicated stuff
      else {
        float bestOptionDistToNext = 0f;
        Term bestOptionTerm = null;
        Label bestOptionLabel = null;
        float firstOptionDistToNext = 0f;
        Term firstOptionTerm = null;
        Label firstOptionLabel = null;
        for (int k = 0; k < optionTries; k++) {
          if (k >= termOptions.size()) break;
          targetTerm = termOptions.get(k);
          Label newLabel = targetSpLabel.makeLabel(targetTerm, targetTerm.term, LABEL_ALIGN_LEFT, (s.useUpHeight ? LABEL_VERTICAL_ALIGN_BASELINE : LABEL_VERTICAL_ALIGN_TOP), startDistance, 0f, s, false, true);
          if (newLabel != null) {
            float distToNext = currentNextLabel.startDistance - newLabel.endDistance;
            if (distToNext > minLabelSpacing) {
              if (distToNext < automaticWin) {
                successfulLabel = newLabel;
                break;
              }
              else {
                if (distToNext < bestOptionDistToNext || bestOptionTerm == null) {
                  bestOptionDistToNext = distToNext;
                  bestOptionTerm = targetTerm;
                  bestOptionLabel = newLabel;
                  if (firstOptionTerm == null) {
                    firstOptionDistToNext = distToNext;
                    firstOptionTerm = bestOptionTerm;
                    firstOptionLabel = bestOptionLabel;
                  }
                }
              }
            }
          }
        }

        if (bestOptionTerm == null) {
          isUpAgainstNextLabel = true;
        }
        else {
          if (bestOptionDistToNext > closestCutoff) {
            successfulLabel = firstOptionLabel;
            targetTerm = firstOptionTerm;
          }
          else {
            successfulLabel = bestOptionLabel;
            targetTerm = bestOptionTerm;
          }
        }
      }





      // if a good label was made, then record it
      if (successfulLabel != null && doesntIntersectWithBlockImage(successfulLabel)) {
        currentLastLabel = successfulLabel;
        targetSpLabel.addLabel(successfulLabel);
        // take out of bucket options
        b.takeOutTerm(targetTerm);
        // also somehow mark the x location...
        markFillerTermAtX(floor(getYearFromX((successfulLabel.spline.getPointByDistance(successfulLabel.startDistance)).get(0).x)), targetTerm);
      }
      else {
        if (isAtEnd) break; // SKIP OUT IF REACHED THE END
        else if (isUpAgainstNextLabel) {
          currentLastLabel = currentNextLabel;
          currentNextLabelIndex++;
          if (currentNextLabelIndex < splineLabels.size()) currentNextLabel = splineLabels.get(currentNextLabelIndex);
          else currentNextLabel = null;
        }
        else {
          // skip ahead by a certain amount
          startDistance += 3 * closestCutoff;
          currentLastLabel = null;
          //println("asdfasdfasdfasf " + startDistance);
        }
      }

      // if a new label is placed then remove that term from the options list

      // also add it to the x list so it wont get placed in other buckets at a similar x position???

      if (manualBreak++ >= 1615) {
        println("DEBUG BREAK");
        break; // SKIP OUT DEBUG
      }
    }
    // manualBreak
    //if (i == 6) break;
    println("    done with filling spline " + (1 + i) + " of " + orderedSplines.size());
  } 

  println("done filling in the gaps, placed " + count + " terms, total time taken: " + ((float)(millis() - startTime) / 1000) + " seconds");
} // end fillInTheGapsForBucket


//
boolean doesntIntersectWithBlockImage(Label newLabel) {
  boolean validLabel = true;
  if (skipLabelsDueToBlockImage) {
    for (Letter l : newLabel.letters) {
      PVector centerPt = l.getLetterCenter();
      color blockColor = blockImage.get((int)centerPt.x, (int)centerPt.y);
      if (blockColor == blockImageColor) {
        validLabel = false;
        break;
      }
    }
  }
  return validLabel;
} // end doestnIntersectWithBlockImage


//
// this will go into the Bucket, get the available filler terms, and then order them according to some arbitrary formula related to the x position
ArrayList<Term> getOrderedTermOptionsForDistance(float startDistance, float endDistance, Spline s, Bucket b) {
  //println("in getOrderedTermOptionsForDistance");
  ArrayList<Term> options = new ArrayList<Term>();
  ArrayList<Term> allAvailableOptions = (ArrayList<Term>)b.fillersTermsRemainingAL.clone();
  //println("allAvailableOptions.size(): " + allAvailableOptions.size());
  if (allAvailableOptions.size() == 0) return options; // SKIP OUT IF THERE ARENT ANY OPTIONS AVAILABLE

  ArrayList<PVector> splinePointAr = s.getPointByDistance(startDistance);
  if (splinePointAr == null) return options; // SKIP OUT IF THERE IS NO POINT AVAILABLE

  PVector splinePoint = splinePointAr.get(0);
  if (splinePoint == null) return options;
  float yearMarker = getYearFromX(splinePoint.x);
  //println("startDistanceIn: " + startDistance + " and yearMarker: " + yearMarker);

  ArrayList<Float> scores = new ArrayList<Float>();
  for (int i = 0; i < allAvailableOptions.size(); i++) {
    boolean foundSpot = false;
    float thisScore = calculateArbitraryScoreForTermAndYear(allAvailableOptions.get(i), yearMarker);
    for (int j = 0; j < options.size(); j++) {
      if (thisScore > scores.get(j)) {
        scores.add(j, thisScore);
        options.add(j, allAvailableOptions.get(i));
        foundSpot = true;
        break;
      }
    }
    if (!foundSpot) {
      options.add(allAvailableOptions.get(i));
      scores.add(thisScore);
    }
  }

  // take out the ones that are already sort of in an equivalent x position
  for (int i = options.size() - 1; i >= 0; i--) {
    if (fillerTermIsAlreadyAtX((int)floor(yearMarker), options.get(i))) {
      options.remove(i);
    }
  }
  return options;
} // end getOrderedTermOptionsForDistance


//
float calculateArbitraryScoreForTermAndYear(Term t, float year) {
  float yearScoreLow = 0f;
  float yearScoreHigh = 0f;
  float score = 0f;
  if (t.series.length == 0) return score; // cut out if this word for some reason has no series
  int startYearIndex = 0;
  int endYearIndex = 1;
  for (int i = yearRange[0]; i < yearRange[1] - 1; i++) {
    if (i == floor(year)) {
      startYearIndex = i - yearRange[0];
      endYearIndex = startYearIndex + 1;
      break;
    }
    if (i == yearRange[1] - 2) {
      // means it isnt in range, too high or too low
      // tough luck
      return score;
    }
  }
  if (startYearIndex < t.series.length) yearScoreLow = t.series[startYearIndex];
  if (endYearIndex < t.series.length) yearScoreHigh = t.series[endYearIndex];
  score = (1 - (year % 1)) * yearScoreLow + (year % 1) * yearScoreHigh;
  return score;
} // end calculateArbitraryScoreForTermAndYear

//
//
//
//


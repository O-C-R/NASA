//
void populateFlares() {
  println("in populateFlares");
  long startTime = millis();


  HashMap<String, Term> freeVerbageHM = new HashMap<String, Term>();
  ArrayList<Term> freeVerbageAL = new ArrayList<Term>();

  for (Bucket b : bucketsAL) {
    for (Term t : b.fillersTermsRemainingAL) {
      String term = t.term.toLowerCase().trim();
      if (!freeVerbageHM.containsKey(term) && !usedTerms.containsKey(term)) {
        freeVerbageHM.put(term, t);
      }
    }
  }

  for (Map.Entry me : freeVerbageHM.entrySet()) freeVerbageAL.add((Term)me.getValue());
  freeVerbageAL = OCRUtils.sortObjectArrayListSimple(freeVerbageAL, "totalCount");
  freeVerbageAL = OCRUtils.reverseArrayList(freeVerbageAL);

  println("made new list of free verbage: " + freeVerbageAL.size());

  int manualBreakout = 0;

  int roundsPerLevel = 2; // multiplied by 1.5 * the level number
  float roundsToUseMultiplier = 1.5; // this number sort of determines how many rounds to do per level
  int roundsToUse = roundsPerLevel;
  int roundCounter = 0;
  int currentLevel = 0;
  int[] flareIndexTracker = new int[flares.size()];
  for (int i = 0; i < flareIndexTracker.length; i++) flareIndexTracker[i] = 0;

  while (true) {

    for (int i = 0; i < flares.size(); i++) {
      Flare f = flares.get(i);
      if (freeVerbageAL.size() == 0) break;
      Term targetTerm = freeVerbageAL.get(0);
      while (true) {
        if (flareIndexTracker[i] >= f.flareSplines.get(currentLevel).size()) break; // cut out if there are no more splines at this level to populate
        if (placeFlareTerm((f.name.equals("topSpline") ? true : false), f, flareIndexTracker[i], currentLevel, targetTerm)) {
          flareIndexTracker[i]++;
          freeVerbageAL.remove(targetTerm);
          usedTerms.put(targetTerm.term, targetTerm); // keep track that it was used
          //println("round: " + roundCounter + " in placeFlare for flare: " + f.name + " at level: " + currentLevel + " and index: " + flareIndexTracker[i] + " out of size: " + f.flareSplines.get(currentLevel).size() + " freeVerbageAL.size(): " + freeVerbageAL.size());
          print(".");
          break;
        }
        else {
          flareIndexTracker[i]++;
        }
      } // end while
    }

    // check that they're not all full
    boolean allFull = true;
    for (int i = 0; i < flares.size(); i++) {
      Flare f = flares.get(i);
      if (flareIndexTracker[i] < f.flareSplines.get(currentLevel).size()) {
        allFull = false;
        break;
      }
    }
    if (freeVerbageAL.size() == 0) break;

    // if they are then jump to the next level
    if (allFull) {
      roundCounter++; 
      for (int k = 0; k < flareIndexTracker.length; k++) flareIndexTracker[k] = 0; // reset
      if (roundCounter >= roundsToUse) {
        currentLevel++;
        if (currentLevel == flareLayers) break;
        if (freeVerbageAL.size() == 0 || manualBreakout++ > 130) break;
        roundCounter = 0;
        roundsToUse = floor(currentLevel * roundsPerLevel * roundsToUseMultiplier);
      }
    }

    //if (manualBreakout++ >= 30) break;
  } // end while


  println("\n done populating edge flares.  took " + nf(((float)millis() - startTime) / 1000, 0, 2) + " seconds");
  for (Flare f : flares) f.printLabelCounts();
} // end populateFlares




//
boolean placeFlareTerm(boolean leftAligned, Flare f, int index, int level, Term t) {
  FlareSpline fs = f.flareSplines.get(level).get(index);

  if (fs.spline.totalDistance == 0) return false; // mal formed spline.  hack.

  Label lastLabel = fs.getLastLabel();
  float lastDistance = fs.getLastDistance(leftAligned);

  //println("lastDistance was: " + lastDistance);
  //println("lastLabel as null? " + (lastLabel == null));
  //println("totalDistance as: " + fs.spline.totalDistance);
  float newEndDistance = 0f;
  if (lastLabel == null) {
    newEndDistance = fs.spline.totalDistance - random(.05, .3) * ((float)(1 + level) / flareLayers) * fs.spline.totalDistance; // give it a bit of wiggle room on the get go.  start distance increases with each level
  }
  else {
    //newEndDistance = lastDistance + 2 * minLabelSpacing + random(.5, 1) * abs(lastLabel.endDistance - lastLabel.startDistance);
    newEndDistance = lastDistance - (minLabelSpacing + random(.15, 1) * abs(lastLabel.endDistance - lastLabel.startDistance));
    //newEndDistance = lastDistance;
  }


  // try this a few times, increase the end distance just in case
  // do a check for the ending
  boolean validLabel = true;
  Label newLabel = null;
  for (int i = 0; i < 5; i++) {

    //newEndDistance = fs.spline.totalDistance - 3f;

    //println("newEndDistance: " + newEndDistance);

    // Label(Term term, String baseText, int labelAlign, int labelAlignVertical) {
    newLabel = new Label(t, t.term, (leftAligned ? LABEL_ALIGN_LEFT : LABEL_ALIGN_RIGHT), LABEL_VERTICAL_ALIGN_BASELINE, "");
    newLabel.assignSplineAndLocation(fs.spline, newEndDistance / fs.spline.totalDistance);
    newLabel.makeLetters(-1);

    if (newLabel.endDistance >= (fs.spline.totalDistance - minLabelSpacing) || newLabel.startDistance >= (fs.spline.totalDistance - minLabelSpacing)) validLabel = false;
    if (newLabel.endDistance <= minLabelSpacing || newLabel.startDistance <= minLabelSpacing) validLabel = false;

    //println("  newLabel.end: " + newLabel.endDistance + " newLabel.start: " + newLabel.startDistance + " valid? " + validLabel);


    validLabel = true;
    // check vs the blockImage
    if (validLabel) {
      for (Letter l : newLabel.letters) {
        ArrayList<PVector> corners = l.getLetterCorners();
        for (PVector p : corners) {
          if (p.x < blockImage.width && p.y < blockImage.height && p.x > 0 && p.y > 0) {
            color blockColor = blockImage.get((int)p.x, (int)p.y);
            //if (blockColor == blockImageColor || blockColor == color(fs.splineGray)) {
            if (blockColor != color(255)) {
              validLabel = false;
              break;
            }
          }
          if (!validLabel) break;
        }
      }
    }

    if (validLabel) break; // get out of this loop
    else {
      newEndDistance = fs.spline.totalDistance - random(.1, .7) * fs.spline.totalDistance; // give it a huge range of options
    }
  } // end i for

  if (!validLabel) {
    for (Letter l : newLabel.letters) l = null;
    newLabel = null;
    return false;
  }
  else {
    fs.addLabel(newLabel);
    // draw it to the block map for future reference
    newLabel.displayBlock(blockImage, color(fs.splineGray));
    return true;
  }
} // end placeFlareTerm


//
//
//
//
//
//
//


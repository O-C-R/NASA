


ArrayList<PVector> newPoint = new ArrayList<PVector>();  // for use in making the letters... to reduce memory?

//
class Label {
  String baseText = "";
  ArrayList<Letter> letters = new ArrayList<Letter>();
  int labelAlign = LABEL_ALIGN_LEFT;
  int labelAlignVertical = LABEL_VERTICAL_ALIGN_BASELINE;
  Spline spline = null;
  int splineID = -1;
  //Spline aboveSpline = null;
  //Spline belowSpline = null;
  float splinePercent = .5f; // where the text should be .. either left, center, or right
  float startDistance = 0f; // keep track of where this label starts and stops
  float endDistance = 0f;

  float fillAlpha = random(1);
  Term term = null;

  String bucketName = "";
  boolean cleaned = false; // set to true after the letters are adjusted and such


  //
  Label(Term term, String baseText, int labelAlign, int labelAlignVertical, String bucketName) {
    this.term = term.get();
    this.fillAlpha = term.fillAlphaPercent;
    this.baseText = baseText;
    this.labelAlign = labelAlign;
    this.labelAlignVertical = labelAlignVertical;
    this.bucketName = bucketName;
  } // end constructor


  //
  Label(JSONObject json) {
    if (json.hasKey("baseText")) baseText = json.getString("baseText");
    if (json.hasKey("letters")) {
      letters.clear();
      JSONArray lettersJAR = json.getJSONArray("letters");
      for (int i = 0; i < lettersJAR.size(); i++) {
        JSONObject letterJ = lettersJAR.getJSONObject(i);
        letters.add(new Letter(letterJ, this));
      }
    }

    if (json.hasKey("labelAlign")) labelAlign = json.getInt("labelAlign");
    if (json.hasKey("labelAlignVertical")) labelAlignVertical = json.getInt("labelAlignVertical");
    if (json.hasKey("splinePercent")) splinePercent = json.getFloat("splinePercent");
    if (json.hasKey("startDistance")) startDistance = json.getFloat("startDistance");
    if (json.hasKey("endDistance")) endDistance = json.getFloat("endDistance");
    if (json.hasKey("fillAlpha")) fillAlpha = json.getFloat("fillAlpha");
    if (json.hasKey("bucketName")) bucketName = json.getString("bucketName");
    if (json.hasKey("cleaned")) cleaned = json.getBoolean("cleaned");

    if (json.hasKey("splineID")) {
      spline = null;
      splineID = json.getInt("splineID");
      for (Spline s : allSplines) {
        if (s.id == splineID) {
          spline = s;
          break;
        }
      }
    }

    // make the term
    term = new Term();
    term.term = baseText;
    term.fillAlphaPercent = fillAlpha;
  } // end JSON constructor

  //
  //void assignSplineAndLocation(Spline spline, Spline aboveSpline, Spline belowSpline, float splinePercent) {
  void assignSplineAndLocation(Spline spline, float splinePercent) {
    this.spline = spline;
    //this.aboveSpline = aboveSpline;
    //this.belowSpline = belowSpline;
    this.splinePercent = splinePercent;
    splineID = spline.id;
  } // end assignSplineAndLocation

  //
  // pass in -1 for letterHeight if the characters will take on the spline height
  void makeLetters(float letterHeight) {
    //long debugTime = millis();
    //print("    in makeLetters.  ");
    letters = new ArrayList<Letter>();
    splinePercent = constrain(splinePercent, 0, 1);
    newPoint = new ArrayList<PVector>();
    float letterWidth = 0f;
    float totalLength = spline.totalDistance;
    float distanceMarker = splinePercent * totalLength;
    float thinkAheadRotationDistance = .4; // multiply the letterHt by this to look ahead and find that rotation
    // assume for now that the text will fit on the line...
    switch(labelAlign) {
    case LABEL_ALIGN_LEFT:
      startDistance = distanceMarker;
      for (int i = 0; i < baseText.length(); i++) {
        newPoint = spline.getPointByDistance(distanceMarker);
        float letterHt = getLetterHeight(letterHeight, newPoint);
        textSize(letterHt);
        PVector forwardRotation = spline.getPointByDistance(distanceMarker + thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
        Letter newLetter = new Letter(this, baseText.charAt(i) + "", distanceMarker, letterHt, newPoint.get(0), forwardRotation, newPoint.get(2), labelAlign, labelAlignVertical);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
        endDistance = distanceMarker;
      }
      break;
    case LABEL_ALIGN_CENTER:
      int divisorIndex = floor((float)baseText.length() / 2); // not perfect,but good enough for now
      String rightHalf = baseText.substring(divisorIndex);
      String leftHalf = baseText.substring(0, divisorIndex);
      // essentially a copy of the left and right code
      for (int i = 0; i < rightHalf.length(); i++) {
        newPoint = spline.getPointByDistance(distanceMarker);        
        float letterHt = getLetterHeight(letterHeight, newPoint);
        textSize(letterHt);
        PVector forwardRotation = spline.getPointByDistance(distanceMarker + thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
        Letter newLetter = new Letter(this, rightHalf.charAt(i) + "", distanceMarker, letterHt, newPoint.get(0), forwardRotation, newPoint.get(2), LABEL_ALIGN_LEFT, labelAlignVertical);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
        endDistance = distanceMarker;
      }
      distanceMarker = splinePercent * totalLength;
      if (leftHalf.length() - 1 >= 0) {
        Letter spacerLetter = new Letter(this, leftHalf.charAt(leftHalf.length() - 1) + "", distanceMarker, getLetterHeight(letterHeight, newPoint), newPoint.get(0), newPoint.get(1), newPoint.get(2), labelAlign, labelAlignVertical);
        distanceMarker -= spacerLetter.getLetterWidth() / 4;
        for (int i = leftHalf.length() - 1; i >= 0; i--) {
          newPoint = spline.getPointByDistance(distanceMarker);
          float letterHt = getLetterHeight(letterHeight, newPoint);
          textSize(letterHt);
          PVector forwardRotation = spline.getPointByDistance(distanceMarker - thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
          Letter newLetter = new Letter(this, leftHalf.charAt(i) + "", distanceMarker, letterHt, newPoint.get(0), forwardRotation, newPoint.get(2), LABEL_ALIGN_RIGHT, labelAlignVertical);
          letters.add(0, newLetter);
          //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
          //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
          distanceMarker -= newLetter.getLetterWidth();
          startDistance = distanceMarker;
        }
      }
      break;
    case LABEL_ALIGN_RIGHT:
      endDistance = distanceMarker;
      for (int i = baseText.length() - 1; i >= 0; i--) {
        newPoint = spline.getPointByDistance(distanceMarker);
        float letterHt = getLetterHeight(letterHeight, newPoint);
        textSize(letterHt);
        PVector forwardRotation = spline.getPointByDistance(distanceMarker - thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
        Letter newLetter = new Letter(this, baseText.charAt(i) + "", distanceMarker, letterHt, newPoint.get(0), forwardRotation, newPoint.get(2), labelAlign, labelAlignVertical);
        letters.add(0, newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker -= newLetter.getLetterWidth();
        startDistance = distanceMarker;
      }
      break;
    } // end switch

    // note: may need to double check this for the centered version
    for (int i = 0; i < letters.size(); i++) {
      if (i > 0) letters.get(i).previousLetter = letters.get(i - 1);
      if (i < letters.size() - 1) letters.get(i).nextLetter = letters.get(letters.size() - 1);
    }
  } // end makeLetters


  //
  // spline stuff only occurs when letterHeightIn < 0
  float getLetterHeight(float letterHeightIn, ArrayList<PVector> splineComponents) {
    float topIntersectionHeight = minimumSplineSpacing;
    if (letterHeightIn >= 0) return letterHeightIn;
    else {
      // option 3 of the splineComponents it the height position
      float thisDist = splineComponents.get(0).dist(splineComponents.get(3));
      topIntersectionHeight = (thisDist > minimumSplineSpacing ? thisDist : minimumSplineSpacing);
    }
    return topIntersectionHeight;
  } // end getLetterHeight

    //
  // this will return the height of the letter closest to the given point.  useful to measure how tall a Label option is at a given point
  float getApproxLetterHeightAtPoint(PVector ptIn) {
    float ht = defaultFontSize;
    float lastClosestDist = 0f;
    for (int i = 0; i < letters.size(); i++) {
      float thisDist = letters.get(i).pos.dist(ptIn);
      if (thisDist < lastClosestDist || i == 0) {
        lastClosestDist = letters.get(i).pos.dist(ptIn);
        ht = letters.get(i).size;
      }
    }
    return ht;
  } // getApproxLetterHeightAtPoint

    //
  // this will just get the smallest letter height for the label
  float getMinimumLetterHeight() {
    float minHt = 0f;
    for (int i = 0; i < letters.size(); i++) {
      if (letters.get(i) == null) continue;
      if (i == 0) minHt = letters.get(i).size;
      else {
        minHt = (letters.get(i).size < minHt ? letters.get(i).size : minHt);
      }
    }
    return minHt;
  } // end getMinimumLetterHeight

    //
  void display(color c) {
    //fill(c, map(term.fillAlphaPercent, 0, 1, minimumFillAlpha, maximumFillAlpha));
    // 2014_05_07 use fillAlphaPercent to instead lerp to white

    if (term.fillAlphaPercent == 1) fill(c); // for flare making
    else {
      //println("term: " + term.term + " alphaPercent: " + term.fillAlphaPercent);
      color newColor = lerpColor(color(255), c, map(term.fillAlphaPercent, 0, 1, minimumFillAlpha, maximumFillAlpha));
      fill(newColor);
    }
    for (Letter l : letters) l.display();
  } // end display

    // 
  void displayBlock(PGraphics pg) {
    displayBlock(pg, blockImageColor);
  } // end displayBlock
  //
  void displayBlock(PGraphics pg, color c) {
    for (Letter l : letters) l.displayBlock(pg, c);
  } // end displayBlock




  //
  void spaceLettersFromCenter() {
    //println("in spaceLettersFromCenter for " + baseText + " which was " + letters.size() + " letters");
    //println("spline is null?? " + (spline == null));
    if (spline == null) {
      print("n");
      return;
    }
    int centerIndex = floor((int)letters.size() / 2);
    Letter centerLetter = letters.get(centerIndex);
    Letter lastLetter = centerLetter;
    ArrayList<Letter> endLetters = new ArrayList<Letter>();
    ArrayList<Letter> startLetters = new ArrayList<Letter>();
    for (int i = centerIndex + 1; i < letters.size(); i++) endLetters.add(letters.get(i)); // end letters will go from center out
    for (int i = centerIndex - 1; i >= 0; i--) startLetters.add(letters.get(i)); // start letters will go from center out
    //println("center letter as: " + centerLetter.letter);
    //println("end count as: " + endLetters.size());
    //println("startLetters as: " + startLetters.size());


    // ****** //
    // ****** //// ****** //
    // ****** //
    // ****** //
    // ****** //
    float smallLetterMultiplier = 6.0;
    //float smallLetterMultiplier = 1.0;
    //if(getMinimumLetterHeight() < 3 * minCharHeight) smallLetterMultiplier = 6f;
    // ****** //
    // ****** //// ****** //
    // ****** //
    // ****** //
    // ****** //


    //println("oldSpline totalDistance: " + oldSpline.totalDistance + " new: " + splineCopy.totalDistance);
    // redistribute all letters based on this new spline.... and new heights
    float[] letterDistanceMarkerPercents = new float[letters.size()];
    for (int i = 0; i < letters.size(); i++) letterDistanceMarkerPercents[i] = letters.get(i).distanceMarker / spline.totalDistance;
    // replace the spline
    Spline oldSpline = spline.getCopy();
    Spline splineCopy = spline.getCopy();
    splineCopy.multiplyFromPoint(centerLetter.pos, smallLetterMultiplier);
    splineCopy.makeDistances();    
    spline = splineCopy; 
    // mark the new distances and re-place the letters
    ArrayList<PVector> pt;
    for (int i = 0; i < letters.size(); i++) {
      letters.get(i).distanceMarker = splineCopy.totalDistance * letterDistanceMarkerPercents[i];
      pt = splineCopy.getPointByDistance(letters.get(i).distanceMarker);
      letters.get(i).pos = pt.get(0).get();
    }
    // multiply all letter sizes
    for (int i = 0; i < letters.size(); i++) letters.get(i).size *= smallLetterMultiplier;


    // do the actual shifting
    PVector[] edges = getEdges(centerLetter, false, 0f);
    //println(" got: " + edges.length + " edges");
    pushMatrix();
    translate(centerLetter.pos.x, centerLetter.pos.y);
    rotate(centerLetter.rotationF);
    for (PVector p : edges) {
      //stroke(255, 0, 0, 100);
      //ellipse(p.x, p.y, 13, 13); 
      //println("p.x: " + p.x + " p.y: " + p.y);
    }
    popMatrix();


    String spacingLetter = "i"; // should this be an o?
    float spacerMultiplier = .33;//.25; // this times the letterwidth of the spacing letter is the goal for what to space
    float targetSpacing = 0f;
    float targetSpacingWiggleRoom = 0f; // will be maybe .25 * targetSpacing
    float newShiftAmount = 0f;
    int breakoutLimit = 25;
    PVector dir = lastLetter.direction.get();
    float neighborDistance = 0f;

    // cheat by replaceing all spaces with a symbol
    //for (Letter l : letters) if (l.letter.equals(" ")) l.letter = "*";

    while (true) {
      textSize(lastLetter.size);
      targetSpacing = textWidth(spacingLetter) * spacerMultiplier;
      targetSpacingWiggleRoom = .15 * targetSpacing;
      int breakout = 0;
      edges = getEdges(lastLetter, false, 0f);
      while (true) {
        if (endLetters.size() <= 0) break;
        neighborDistance = getDistanceToNeighbor(edges, lastLetter.direction, lastLetter, endLetters.get(0));

        //println(endLetters.size()  + " : " + breakout + " : " + neighborDistance + " goal: " + targetSpacing);

        if (abs(neighborDistance - targetSpacing) < targetSpacingWiggleRoom || breakout++ > breakoutLimit) {
          //println("____" + abs(neighborDistance - targetSpacing) + " < " + targetSpacingWiggleRoom);
          break;
        }
        else {
          newShiftAmount = .85 * (targetSpacing - neighborDistance);

          //println("will try to shift by " + newShiftAmount);
          shiftLetters(endLetters, newShiftAmount);
        }
      }
      lastLetter = endLetters.get(0);
      endLetters.remove(0);
      if (endLetters.size() <= 0) break;
      //println("iterate");
    }


    lastLetter = centerLetter;
    while (true) {
      if (startLetters.size() <= 0) break;
      textSize(lastLetter.size);
      targetSpacing = textWidth(spacingLetter) * spacerMultiplier;
      targetSpacingWiggleRoom = .15 * targetSpacing;
      int breakout = 0;
      edges = getEdges(lastLetter, true, 0f);
      while (true) {
        dir = lastLetter.direction.get();
        dir.mult(-1);
        neighborDistance = getDistanceToNeighbor(edges, dir, lastLetter, startLetters.get(0));
        //println(startLetters.size()  + " : " + breakout + " : " + neighborDistance + " goal: " + targetSpacing);
        if (abs(neighborDistance - targetSpacing) < targetSpacingWiggleRoom || breakout++ > breakoutLimit) {
          //println("____" + abs(neighborDistance - targetSpacing) + " < " + targetSpacingWiggleRoom);
          break;
        }
        else {
          newShiftAmount = .85 * (targetSpacing - neighborDistance);
          //println("will try to shift by " + newShiftAmount);
          shiftLetters(startLetters, -newShiftAmount);
        }
      }
      lastLetter = startLetters.get(0);
      startLetters.remove(0);
      if (startLetters.size() <= 0) break;
      //println("iterate");
    }

    // cheat by replaceing all spaces with a symbol
    //for (Letter l : letters) if (l.letter.equals("*")) l.letter = " ";

    // then go back and unmultiply if required
    // ********* //
    // ********* //
    // ********* //
    // ********* //
    if (smallLetterMultiplier != 1) {
      //println("going to shrink the text");

      // divide all of the letter sizes
      for (int i = 0; i < letters.size(); i++) letters.get(i).size /= smallLetterMultiplier;

      // save the position percentages
      for (int i = 0; i < letters.size(); i++) letterDistanceMarkerPercents[i] = letters.get(i).distanceMarker / spline.totalDistance;
      // replace the spline
      spline = oldSpline;
      // assign the positions to the letters

      for (int i = 0; i < letters.size(); i++) {
        letters.get(i).distanceMarker = spline.totalDistance * letterDistanceMarkerPercents[i];
        pt = spline.getPointByDistance(letters.get(i).distanceMarker);
        letters.get(i).pos = pt.get(0).get();
      }
    }
    // ********* //
    // ********* //
    // ********* //
    // ********* //

    // update the different positions for this Label
    startDistance = letters.get(0).distanceMarker;
    endDistance = letters.get(letters.size() - 1).distanceMarker;

    // DRAW BLOCKS
    displayBlock(blockImage);

    // set the cleaned boolean
    cleaned = true;
  } // end spaceLettersFromCenter

  //
  void shiftLetters(ArrayList<Letter> lettersToShift, float amount) {
    //println("shifting " + lettersToShift.size() + " letters by " + amount);
    for (Letter l : lettersToShift) {
      float oldDistance = l.distanceMarker;
      float newDistance = oldDistance + amount;
      if (newDistance <= 0f || newDistance >= spline.totalDistance) return;
      ArrayList<PVector> newPoint = spline.getPointByDistance(newDistance);
      if (newPoint != null) {
        l.pos = newPoint.get(0);
        l.rotation = newPoint.get(1);
        l.rotationF = l.getAdjustedRotation(l.rotation);
        l.direction = newPoint.get(2);
        l.directionF = l.getAdjustedRotation(l.direction);
        l.size = l.pos.dist(newPoint.get(3));
        l.distanceMarker = newDistance;
        l.makeAverageRotationAndDirection(spline);
      }
    }
    cleaned = false;
  } // end shiftLetters  


  //
  JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setString("baseText", baseText);
    JSONArray lettersJAR = new JSONArray();
    for (int i = 0; i < letters.size(); i++) {
      lettersJAR.setJSONObject(i, letters.get(i).getJSON());
    }
    json.setJSONArray("letters", lettersJAR);    

    json.setInt("labelAlign", labelAlign);
    json.setInt("labelAlignVertical", labelAlignVertical);
    json.setFloat("splinePercent", splinePercent);
    json.setFloat("startDistance", startDistance);
    json.setFloat("endDistance", endDistance);
    json.setFloat("fillAlpha", fillAlpha);
    json.setString("bucketName", bucketName);
    json.setInt("splineID", splineID);

    json.setBoolean("cleaned", cleaned);

    return json;
  } // end JSON constructor
} // end class Label




















//
class Letter {
  String letter = "";
  PVector pos = new PVector();
  float size = 12f;
  PVector rotation = new PVector();
  float rotationF = 0f;
  PVector direction = new PVector();
  float directionF = 0f;
  float distanceMarker = 0f;
  int letterAlign = LABEL_ALIGN_LEFT;
  int letterVerticalAlign = LABEL_VERTICAL_ALIGN_BASELINE;

  Label parentLabel;

  Letter previousLetter = null;
  Letter nextLetter = null;

  boolean angleSmoothingOn = true; // when true will use the previous and next letters [if available] to smooth out the angle a bit

  //
  Letter() {
  } // end blank constructor

    //
  Letter(JSONObject json, Label parentLabel) {
    this.parentLabel = parentLabel;
    if (json.hasKey("letter")) letter = json.getString("letter");
    if (json.hasKey("distanceMarker")) distanceMarker = json.getFloat("distanceMarker");
    if (json.hasKey("size")) size = json.getFloat("size");
    if (json.hasKey("direction")) {
      JSONObject pt = json.getJSONObject("direction");
      direction = new PVector(pt.getFloat("x"), pt.getFloat("y"));
    }
    if (json.hasKey("pos")) {
      JSONObject pt = json.getJSONObject("pos");
      pos = new PVector(pt.getFloat("x"), pt.getFloat("y"));
    }
    if (json.hasKey("rotation")) {
      JSONObject pt = json.getJSONObject("rotation");
      rotation = new PVector(pt.getFloat("x"), pt.getFloat("y"));
    }
    if (json.hasKey("letterAlign")) letterAlign = json.getInt("letterAlign");
    if (json.hasKey("letterVerticalAlign")) letterVerticalAlign = json.getInt("letterVerticalAlign");
    if (json.hasKey("rotationF")) rotationF = json.getFloat("rotationF");
    if (json.hasKey("directionF")) directionF = json.getFloat("directionF");
  } // end JSON constructor


  //
  Letter(Label parentLabel, String letter, float distanceMarker, float size, PVector pos, PVector rotation, PVector direction, int letterAlign, int letterVerticalAlign) {
    this.parentLabel = parentLabel;
    this.letter = letter;
    this.distanceMarker = distanceMarker;
    this.size = size;
    this.direction = direction;
    this.pos = pos;
    this.rotation = rotation;
    this.letterAlign = letterAlign;
    this.letterVerticalAlign = letterVerticalAlign;
    rotationF = getAdjustedRotation(rotation);
    directionF = getAdjustedRotation(direction);
  } // end constructor

  // 
  /*
  void makeAverageRotationAndDirection() {
   // make an adjusted rotation?
   ArrayList<PVector> endPt = null;
   if (letterAlign == LABEL_ALIGN_LEFT) endPt = parentLabel.spline.getPointByDistance(distanceMarker + getLetterWidth());
   else if (letterAlign == LABEL_ALIGN_RIGHT) endPt = parentLabel.spline.getPointByDistance(distanceMarker - getLetterWidth());
   if (endPt == null) return;
   if (endPt.get(1) != null) {
   rotation.add(endPt.get(1));
   rotation.div(2);
   rotationF = getAdjustedRotation(rotation);
   }
   if (endPt.get(2) != null) {
   direction.add(endPt.get(2));
   direction.div(2);
   directionF = getAdjustedRotation(direction);
   }
   } // end makeAverageRotationAndDirection
   */
  // 
  void makeAverageRotationAndDirection(Spline spline) {
    // make an adjusted rotation?
    ArrayList<PVector> endPt = null;
    if (letterAlign == LABEL_ALIGN_LEFT) endPt = spline.getPointByDistance(distanceMarker + getLetterWidth());
    else if (letterAlign == LABEL_ALIGN_RIGHT) endPt = spline.getPointByDistance(distanceMarker - getLetterWidth());
    if (endPt == null) return;
    if (endPt.get(1) != null) {
      rotation.add(endPt.get(1));
      rotation.div(2);
      rotationF = getAdjustedRotation(rotation);
    }
    if (endPt.get(2) != null) {
      direction.add(endPt.get(2));
      direction.div(2);
      directionF = getAdjustedRotation(direction);
    }
  } // end makeAverageRotationAndDirection

    //
  float getLetterWidth() {
    textFont(font, size);
    return textWidth(letter);
  } // end getLetterWidth

  //
  float getAdjustedLetterWidth(Letter neighbor) {
    float letterWidth = getLetterWidth();

    float signedAngle = atan2( rotation.x * neighbor.rotation.y - rotation.y* neighbor.rotation.x, rotation.x * neighbor.rotation.x + rotation.y * neighbor.rotation.y );
    float adjustment = constrain(map(signedAngle, -PI/8, PI/8, .75, 1.5), .75, 1.5);
    return letterWidth * adjustment;
  } // end getAdjustedLetterWidth

  //
  void display() {
    textFont(font, size);
    textAlign(letterAlign, letterVerticalAlign);

    float rotationToUse = rotationF;

    // ****** //
    // replace the letters using replacementLetters
    String letterToUse = letter;
    for (Map.Entry me : replacementLetters.entrySet()) {
      String origTerm = (String)me.getKey();
      String replacementTerm = (String)me.getValue();
      if (letterToUse.equals(replacementTerm)) {
        letterToUse = origTerm;
        break;
      }
    }

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(rotationToUse);
    text(letterToUse, 0, 0);
    popMatrix();
  } // end display

  //
  void displayBlock(PGraphics pg, color c) {
    textFont(font, size);
    textAlign(letterAlign, letterVerticalAlign);

    float letterWidth = textWidth(letter);
    float letterHeight = size;

    float heightOffset = 0f;
    float widthOffset = 0;
    float blockWidth = letterWidth;
    if (letterAlign == RIGHT) {
      widthOffset = -blockWidth;
    }
    else if (letterAlign == CENTER) {
      widthOffset = -blockWidth / 2;
    }
    if (letterVerticalAlign == BASELINE) {
      heightOffset = .18 * size;
    }
    else if (letterVerticalAlign == TOP) {
      heightOffset = size;
    }

    pg.fill(c);
    pg.noStroke();
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate(rotationF);
    pg.translate(widthOffset, heightOffset);
    pg.rect(0, 0, blockWidth, -size * .85);
    pg.popMatrix();
  } // end displayBlock

  //
  PVector getLetterCenter() {
    // approx center of the letter, not exact
    ArrayList<PVector> corners = getLetterCorners();
    PVector letterCenter = new PVector();
    for (PVector p : corners) letterCenter.add(p);
    letterCenter.div(corners.size());
    return letterCenter;
  } // end getLetterCenter

    //
  ArrayList<PVector> getLetterCorners() {
    ArrayList<PVector> corners = new ArrayList<PVector>();
    // approx corners of the letter, not exact
    textFont(font, size);
    float blockWidth = textWidth(letter);
    PVector right = new PVector(-rotation.y, rotation.x);
    right.normalize();
    float rightMultiplier = 0f;
    if (letterAlign == LABEL_ALIGN_RIGHT) {
      rightMultiplier = -blockWidth/2;
      right.mult(rightMultiplier);
    }
    else if (letterAlign == LABEL_ALIGN_CENTER) {
      rightMultiplier = 0;
    }
    else if (letterAlign == LABEL_ALIGN_LEFT) {
      rightMultiplier = blockWidth/2;
      right.mult(rightMultiplier);
    }

    //right.mult(0);
    float offsetMultiplier = size/2;
    if (letterVerticalAlign == LABEL_VERTICAL_ALIGN_BASELINE) {
      offsetMultiplier -= .18 * size;
    }
    else if (letterVerticalAlign == LABEL_VERTICAL_ALIGN_TOP) {
      offsetMultiplier -= size;
    }

    PVector letterCenter = rotation.get();
    letterCenter.normalize();
    letterCenter.mult(offsetMultiplier);
    letterCenter.add(pos);
    letterCenter.add(right);

    // adjust for center again
    if (letterAlign == LABEL_ALIGN_CENTER) {
      rightMultiplier = blockWidth/2;
      right.mult(rightMultiplier);
    }

    PVector up = rotation.get();
    up.mult(size / 2);

    PVector corner = letterCenter.get();
    corner.sub(up);
    corner.sub(right);
    corners.add(corner);
    corner = letterCenter.get();
    corner.sub(up);
    corner.add(right);
    corners.add(corner);
    corner = letterCenter.get();
    corner.add(up);
    corner.add(right);
    corners.add(corner);
    corner = letterCenter.get();
    corner.add(up);
    corner.sub(right);
    corners.add(corner);
    return corners;
  } // end getLetterCorners

    //
  float getAdjustedRotation(PVector rotationIn) {
    float newRotationF = 0f;
    if (rotationIn.x != 0) newRotationF = atan(rotationIn.y / rotationIn.x);
    else newRotationF = -HALF_PI;
    if (rotationIn.x <= 0) {
      if (rotationIn.x < 0) newRotationF += PI;
      else {
        if (rotationIn.y > 0) {
          newRotationF += PI;
        }
      }
    }
    newRotationF += HALF_PI;
    return newRotationF;
  } // end getAdjustedRoation


  //
  JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setString("letter", letter);
    json.setFloat("distanceMarker", distanceMarker);
    json.setFloat("size", size);
    json.setJSONObject("direction", getPVectorJSON(direction));
    json.setJSONObject("pos", getPVectorJSON(pos));
    json.setJSONObject("rotation", getPVectorJSON(rotation));
    json.setInt("letterAlign", letterAlign);
    json.setInt("letterVerticalAlign", letterVerticalAlign);
    json.setFloat("rotationF", rotationF);
    json.setFloat("directionF", directionF);
    return json;
  } // end getJSON


  //
  JSONObject getPVectorJSON(PVector p) {
    JSONObject pt = new JSONObject();
    pt.setFloat("x", p.x);
    pt.setFloat("y", p.y);
    return pt;
  } // end getPVectorJSON
} // end class Letter

//
//
//







//
class Label {
  String baseText = "";
  ArrayList<Letter> letters = new ArrayList<Letter>();
  int labelAlign = LABEL_ALIGN_LEFT;
  int labelAlignVertical = LABEL_VERTICAL_ALIGN_BASELINE;
  Spline spline = null;
  //Spline aboveSpline = null;
  //Spline belowSpline = null;
  float splinePercent = .5f; // where the text should be .. either left, center, or right
  float startDistance = 0f; // keep track of where this label starts and stops
  float endDistance = 0f;


  //
  Label(String baseText, int labelAlign, int labelAlignVertical) {
    this.baseText = baseText;
    this.labelAlign = labelAlign;
    this.labelAlignVertical = labelAlignVertical;
  } // end constructor

  //
  //void assignSplineAndLocation(Spline spline, Spline aboveSpline, Spline belowSpline, float splinePercent) {
  void assignSplineAndLocation(Spline spline, float splinePercent) {
    this.spline = spline;
    //this.aboveSpline = aboveSpline;
    //this.belowSpline = belowSpline;
    this.splinePercent = splinePercent;
  } // end assignSplineAndLocation

  //
  // pass in -1 for letterHeight if the characters will take on the spline height
  void makeLetters(float letterHeight) {
    letters = new ArrayList<Letter>();
    splinePercent = constrain(splinePercent, 0, 1);
    ArrayList<PVector> newPoint = new ArrayList<PVector>();
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
        Letter newLetter = new Letter(baseText.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, labelAlign, labelAlignVertical);
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
        Letter newLetter = new Letter(rightHalf.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, LABEL_ALIGN_LEFT, labelAlignVertical);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
        endDistance = distanceMarker;
      }
      distanceMarker = splinePercent * totalLength;
      if (leftHalf.length() - 1 >= 0) {
        Letter spacerLetter = new Letter(leftHalf.charAt(leftHalf.length() - 1) + "", getLetterHeight(letterHeight, newPoint), newPoint.get(0), newPoint.get(1), labelAlign, labelAlignVertical);
        distanceMarker -= spacerLetter.getLetterWidth() / 4;
        for (int i = leftHalf.length() - 1; i >= 0; i--) {
          newPoint = spline.getPointByDistance(distanceMarker);
          float letterHt = getLetterHeight(letterHeight, newPoint);
          textSize(letterHt);
          PVector forwardRotation = spline.getPointByDistance(distanceMarker - thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
          Letter newLetter = new Letter(leftHalf.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, LABEL_ALIGN_RIGHT, labelAlignVertical);
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
        Letter newLetter = new Letter(baseText.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, labelAlign, labelAlignVertical);
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
  void display() {
    for (Letter l : letters) l.display();
  } // end display
  
  //
  void displayBlock(PGraphics pg) {
    for (Letter l : letters) l.displayBlock(pg);
  } // end displayBlock
} // end class Label





//
class Letter {
  String letter = "";
  PVector pos = new PVector();
  float size = 12f;
  PVector rotation = new PVector();
  float rotationF = 0f;
  int letterAlign = LABEL_ALIGN_LEFT;
  int letterVerticalAlign = LABEL_VERTICAL_ALIGN_BASELINE;

  Letter previousLetter = null;
  Letter nextLetter = null;

  boolean angleSmoothingOn = true; // when true will use the previous and next letters [if available] to smooth out the angle a bit

  //
  Letter() {
  } // end blank constructor

    //
  Letter(String letter, float size, PVector pos, PVector rotation, int letterAlign, int letterVerticalAlign) {
    this.letter = letter;
    this.size = size;
    this.pos = pos;
    this.rotation = rotation;
    this.letterAlign = letterAlign;
    this.letterVerticalAlign = letterVerticalAlign;
    rotationF = getAdjustedRotation(rotation);
  } // end constructor

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

    /*
    // this should make it so that the rotation is smoothed out a bit
     if (angleSmoothingOn) {
     PVector newRotation = rotation.get();
     float thisRotationPercent = .95;
     float otherRotationPercent = .05;
     if (previousLetter != null && nextLetter == null) {
     newRotation.mult(thisRotationPercent);
     PVector otherRotation = previousLetter.rotation.get();
     otherRotation.mult(otherRotationPercent);
     newRotation.add(otherRotation);
     rotationToUse = getAdjustedRotation(newRotation);
     }
     else if (nextLetter != null & previousLetter == null) {
     newRotation.mult(thisRotationPercent);
     PVector otherRotation = nextLetter.rotation.get();
     otherRotation.mult(otherRotationPercent);
     newRotation.add(otherRotation);
     rotationToUse = getAdjustedRotation(newRotation);
     }
     else if (nextLetter == null && previousLetter == null) {
     rotationToUse = getAdjustedRotation(newRotation);
     }
     else {
     newRotation.mult(thisRotationPercent - otherRotationPercent);
     PVector otherRotation = nextLetter.rotation.get();
     otherRotation.mult(otherRotationPercent);
     newRotation.add(otherRotation);
     otherRotation = previousLetter.rotation.get();
     otherRotation.mult(otherRotationPercent);
     newRotation.add(otherRotation);
     rotationToUse = getAdjustedRotation(newRotation);
     }
     }
     */

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(rotationToUse);
    text(letter, 0, 0);
    popMatrix();
  } // end display

  //
  void displayBlock(PGraphics pg) {
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

    pg.fill(blockImageColor);
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
    textFont(font, size);
    float blockWidth = textWidth(letter);
    PVector right = new PVector(-rotation.y, rotation.x);
    right.normalize();
    float rightMultiplier = 0f;
    if (letterAlign == LABEL_ALIGN_RIGHT) {
      rightMultiplier = -blockWidth/2;
    }
    else if (letterAlign == LABEL_ALIGN_CENTER) {
      rightMultiplier = 0;
    }
    else if (letterAlign == LABEL_ALIGN_LEFT) {
      rightMultiplier = blockWidth/2;
    }
    right.mult(rightMultiplier);
    //right.mult(0);
    float offsetMultiplier = size/2;
    if (letterVerticalAlign == LABEL_VERTICAL_ALIGN_BASELINE) {
      offsetMultiplier -= .28 * size;
    }
    else if (letterVerticalAlign == LABEL_VERTICAL_ALIGN_TOP) {
      offsetMultiplier -= size;
    }
    
    PVector letterCenter = rotation.get();
    letterCenter.normalize();
    letterCenter.mult(offsetMultiplier);
    letterCenter.add(pos);
    letterCenter.add(right);
    return letterCenter;
  } // end getLetterCenter

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
} // end class Letter

//
//
//


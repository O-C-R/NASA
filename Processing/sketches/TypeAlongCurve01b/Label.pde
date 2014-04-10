final int LABEL_ALIGN_LEFT = 0;
final int LABEL_ALIGN_CENTER = 1;
final int LABEL_ALIGN_RIGHT = 2;


//
class Label {
  String baseText = "";
  ArrayList<Letter> letters = new ArrayList<Letter>();
  int labelAlign = LABEL_ALIGN_LEFT;
  Spline spline = null;
  Spline aboveSpline = null;
  Spline belowSpline = null;
  float splinePercent = .5f; // where the text should be .. either left, center, or right
  float startDistance = 0f; // keep track of where this label starts and stops
  float endDistance = 0f;




  //
  Label(String baseText, int labelAlign) {
    this.baseText = baseText;
    this.labelAlign = labelAlign;
  } // end constructor

  //
  void assignSplineAndLocation(Spline spline, Spline aboveSpline, Spline belowSpline, float splinePercent) {
    this.spline = spline;
    this.aboveSpline = aboveSpline;
    this.belowSpline = belowSpline;
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
        Letter newLetter = new Letter(baseText.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, labelAlign);
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
        Letter newLetter = new Letter(rightHalf.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, LABEL_ALIGN_LEFT);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
        endDistance = distanceMarker;
      }
      distanceMarker = splinePercent * totalLength;
      Letter spacerLetter = new Letter(leftHalf.charAt(leftHalf.length() - 1) + "", getLetterHeight(letterHeight, newPoint), newPoint.get(0), newPoint.get(1), labelAlign);
      distanceMarker -= spacerLetter.getLetterWidth() / 4;
      for (int i = leftHalf.length() - 1; i >= 0; i--) {
        newPoint = spline.getPointByDistance(distanceMarker);
        float letterHt = getLetterHeight(letterHeight, newPoint);
        textSize(letterHt);
        PVector forwardRotation = spline.getPointByDistance(distanceMarker - thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
        Letter newLetter = new Letter(leftHalf.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, LABEL_ALIGN_RIGHT);
        letters.add(0, newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker -= newLetter.getLetterWidth();
        startDistance = distanceMarker;
      }
      break;
    case LABEL_ALIGN_RIGHT:
      endDistance = distanceMarker;
      for (int i = baseText.length() - 1; i >= 0; i--) {
        newPoint = spline.getPointByDistance(distanceMarker);
        float letterHt = getLetterHeight(letterHeight, newPoint);
        textSize(letterHt);
        PVector forwardRotation = spline.getPointByDistance(distanceMarker - thinkAheadRotationDistance * textWidth(baseText.charAt(i) + "")).get(1);
        Letter newLetter = new Letter(baseText.charAt(i) + "", letterHt, newPoint.get(0), forwardRotation, labelAlign);
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
    if (letterHeightIn >= 0) return letterHeightIn;
    else {
      // go find the intersection heights
      float topIntersectionHeight = -1;
      float bottomIntersectionHeight = -1; // skip this for now.. and just assume that it is looking up
      ArrayList<PVector>  intersection = null;
      PVector lineStart = null;
      PVector lineEnd = null;
      if (splineComponents.get(0) != null && splineComponents.get(1) != null) {
        lineStart = splineComponents.get(0);
        lineEnd = lineStart.get();
        lineEnd.add(splineComponents.get(1));
        if (aboveSpline != null && lineStart != null && lineEnd != null) {
          intersection = (aboveSpline.getPointByIntersection(lineStart, lineEnd)); 
          if (intersection != null) topIntersectionHeight = intersection.get(0).dist(lineStart);
        }

        // if the aboveSpline is null, then use the bottom spline but slightly smaller
        else if (aboveSpline == null && lineStart != null && lineEnd != null) {
          float slightlySmallerFactor = .6;  
          intersection = (belowSpline.getPointByIntersection(lineStart, lineEnd)); 
          if (intersection != null) topIntersectionHeight = intersection.get(0).dist(lineStart) * slightlySmallerFactor;
        }

        /*
        if (belowSpline != null) {
         intersection = (belowSpline.getPointByIntersection(lineStart, lineEnd)).get(0);
         if (intersection != null) bottomIntersectionHeight = intersection.dist(lineStart);
         }
         */
      }

      // adjust ..
      /*
      if (topIntersectionHeight > 0 && bottomIntersectionHeight == -1) bottomIntersectionHeight = topIntersectionHeight;
       else if (topIntersectionHeight == -1 && bottomIntersectionHeight > 0) topIntersectionHeight = bottomIntersectionHeight;
       else if (topIntersectionHeight == -1 && bottomIntersectionHeight == -1) topIntersectionHeight = bottomIntersectionHeight = defaultFontSize / 2f;
       */
      if (topIntersectionHeight == -1) topIntersectionHeight = defaultFontSize;

      // add the two up and make that the resultant size
      //return (topIntersectionHeight + bottomIntersectionHeight) / 2; // DIVIDE BY TWO!!
      return topIntersectionHeight;
    }
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
  void display(PGraphics pg) {
    for (Letter l : letters) l.display(pg);

    /*
    PVector pt = spline.getPointByDistance(startDistance).get(0);
     pg.ellipse(pt.x, pt.y, 3, 3);
     pt = spline.getPointByDistance(endDistance).get(0);
     pg.ellipse(pt.x, pt.y, 3, 3);
     */
  } // end display
} // end class Label





//
class Letter {
  String letter = "";
  PVector pos = new PVector();
  float size = 12f;
  PVector rotation = new PVector();
  float rotationF = 0f;
  int letterAlign = LABEL_ALIGN_LEFT;

  Letter previousLetter = null;
  Letter nextLetter = null;

  boolean angleSmoothingOn = true; // when true will use the previous and next letters [if available] to smooth out the angle a bit

  //
  Letter(String letter, float size, PVector pos, PVector rotation, int letterAlign) {
    this.letter = letter;
    this.size = size;
    this.pos = pos;
    this.rotation = rotation;
    this.letterAlign = letterAlign;
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
  void display(PGraphics pg) {
    pg.textFont(font, size);
    if (letterAlign == LABEL_ALIGN_RIGHT)  pg.textAlign(RIGHT);
    else if (letterAlign == LABEL_ALIGN_CENTER)  pg.textAlign(CENTER);
    else pg.textAlign(LEFT);

    float rotationToUse = rotationF;

    // this should make it so that the rotation is smoothed out a bit
    if (angleSmoothingOn) {
      PVector newRotation = rotation.get();
      float thisRotationPercent = .9;
      float otherRotationPercent = .1;
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

    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate(rotationToUse);
    pg.text(letter, 0, 0);
    pg.popMatrix();
  } // end display

  //
  float getAdjustedRotation(PVector rotationIn) {
    float newRotationF = 0f;
    if (rotationIn.x != 0) newRotationF = atan(rotationIn.y / rotationIn.x);
    else newRotationF = -HALF_PI;
    if (rotationIn.x < 0) newRotationF += PI;
    newRotationF += HALF_PI;
    return newRotationF;
  } // end getAdjustedRoation
} // end class Letter

//
//
//


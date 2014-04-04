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


  //
  Label(String baseText) {
    this.baseText = baseText;
  } // end constructor

  //
  void assignSplineAndLocation(Spline spline, float splinePercent) {
    this.spline = spline;
    this.splinePercent = splinePercent;
  } // end assignSplineAndLocation

  //
  void makeLetters() {
    letters = new ArrayList<Letter>();
    splinePercent = constrain(splinePercent, 0, 1);
    ArrayList<PVector> newPoint = new ArrayList<PVector>();
    float letterWidth = 0f;
    float totalLength = spline.totalDistance;
    float distanceMarker = splinePercent * totalLength;
    // assume for now that the text will fit on the line...
    switch(labelAlign) {
    case LABEL_ALIGN_LEFT:
      for (int i = 0; i < baseText.length(); i++) {
        newPoint = spline.getPointByDistance(distanceMarker);
        defaultFontSize = noise(.5 * i) * 30;
        Letter newLetter = new Letter(baseText.charAt(i) + "", defaultFontSize, newPoint.get(0), newPoint.get(1), labelAlign);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
      }
      break;
    case LABEL_ALIGN_CENTER:
      int divisorIndex = floor((float)baseText.length() / 2); // not perfect,but good enough for now
      String rightHalf = baseText.substring(divisorIndex);
      String leftHalf = baseText.substring(0, divisorIndex);
      // essentially a copy of the left and right code
      for (int i = 0; i < rightHalf.length(); i++) {
        newPoint = spline.getPointByDistance(distanceMarker);
        Letter newLetter = new Letter(rightHalf.charAt(i) + "", defaultFontSize, newPoint.get(0), newPoint.get(1), LABEL_ALIGN_LEFT);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker += newLetter.getLetterWidth();
      }
      distanceMarker = splinePercent * totalLength;
      Letter spacerLetter = new Letter(leftHalf.charAt(leftHalf.length() - 1) + "", defaultFontSize, newPoint.get(0), newPoint.get(1), labelAlign);
      distanceMarker -= spacerLetter.getLetterWidth() / 4;
      for (int i = leftHalf.length() - 1; i >= 0; i--) {
        newPoint = spline.getPointByDistance(distanceMarker);
        Letter newLetter = new Letter(leftHalf.charAt(i) + "", defaultFontSize, newPoint.get(0), newPoint.get(1), LABEL_ALIGN_RIGHT);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker -= newLetter.getLetterWidth();
      }

      break;
    case LABEL_ALIGN_RIGHT:
      for (int i = baseText.length() - 1; i >= 0; i--) {
        newPoint = spline.getPointByDistance(distanceMarker);
        Letter newLetter = new Letter(baseText.charAt(i) + "", defaultFontSize, newPoint.get(0), newPoint.get(1), labelAlign);
        letters.add(newLetter);
        //if (letters.size() == 1) distanceMarker += newLetter.getLetterWidth();
        //else distanceMarker += newLetter.getAdjustedLetterWidth(letters.get(letters.size() - 2));
        distanceMarker -= newLetter.getLetterWidth();
      }
      break;
    } // end switch
  } // end makeLetters

  //
  void display(PGraphics pg) {
    for (Letter l : letters) l.display(pg);
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

  //
  Letter(String letter, float size, PVector pos, PVector rotation, int letterAlign) {
    this.letter = letter;
    this.size = size;
    this.pos = pos;
    this.rotation = rotation;
    this.letterAlign = letterAlign;
    rotationF = 0f;
    if (rotation.x != 0) rotationF = atan(rotation.y / rotation.x);
    if (rotation.x < 0) rotationF += PI;
    rotationF += HALF_PI;
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

    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate(rotationF);
    pg.text(letter, 0, 0);
    pg.popMatrix();
  } // end display
} // end class Letter

//
//
//


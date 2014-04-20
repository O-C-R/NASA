import rita.*;

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import java.util.Map;
import processing.pdf.*;


// visual controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean variationOn = false;
boolean shiftIsDown = false;
boolean debugOn = false;
boolean displayHeightsOn = false;
// ****** //
boolean disableSplineMaking = true; // disable the generation of splines [as to not overwrite whatever if it's already made] also disables export
boolean autoLoadSplines = false; // will auto load the splines [assuming they are generated already] in the setup
// ****** //


// *** main spline numbers *** //
float splineMinAngleInDegrees = .07f; // .02 for high
float splineMinDistance = 10f; // minimum distance between makeing a facet
int splineDivisionAmount = 170; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing


// *** child spline numbers *** // 
float minimumSplineSpacing = 10f; // 4f is a good ht; // *** change this to set the minimum spline ht
float maximumPercentSplineSpacing = .18; // .2 is ok..
float childMaxPercentMultiplier = 1.95; // 2 would be the same as the parent // *** change this to alter falloff of children size
float testSplineSpacing = minimumSplineSpacing;



boolean addMiddleDivide = true; // whether or not to split up the middle SpLabel
float middleDivideDistance = 40f; // if dividing the middle SpLabel, how much to divide it by
boolean skipMiddleLine = true; // if on it will make it so that text cannot go on this middle line

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  //140f, 400f, 140f, 350f // for draft
  100f, 100f, 100f, 100f
};

float minLabelSpacing = 10f; // the minimum spacing between labels along a spline
float wiggleRoom = 48f; // how much the word can move around instead of being precisely on the x point

// when divding up the splabels into the middlesplines
float maxSplineHeight = 19f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
//float splineCurvePointDistance = 10f; // the approx distance between curve points

int[] yearRange = {
  1958, 
  2009 // fix this later
};
int[] constrainRange = {
  yearRange[0], 
  yearRange[1]
}; // inclusive
float[] constrainRangeX = {
  0f, 
  0f
}; 


// placeholder vars
Letter blankLetter = new Letter();
Term blankTerm = new Term(); // blank term used to gather x position.  used main for series length which is copied over as buckets are read in

// bucket vars
String mainDiretoryPath = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAll";
//String mainDiretoryPath = "C:\\Users\\OCR\\Documents\\GitHub\\NASA\\Data\\BucketGramsAll";
String[] bucketsToUse = {
  //"debug", 
  //"administrative", 
  //"astronaut", 
  //"mars", 
  "moon", //   
  //"people", 
  //"politics", 
  "research_and_development", // * 
  "rockets", // * 
  "russia", 
  "satellites", 
  "space_shuttle", 

  //"spacecraft", 
  //"us",
};
HashMap<String, Integer> hexColors = new HashMap<String, Integer>(); // called from setup(), done in AbucketReader


// only these Pos files will be used, others will be skipped
String[] posesToUse = {
  "cd nns", 
  "jj nns", 
  "jj vbg nn", 
  "jj vbg nns", 
  "jj vbg", 
  "vbg nns", 
  "dt jj jj nn", 
  //"nn",

  // skip these:
  //"dt jj nns", 

  //"cd jj nns", 
  //"dt jj nn",
  //"dt nn",  
  //"vbg nn",
};
String[] entitiesToUse = {
  //"Country", 
  //"Facility", 
  "FieldTerminology", 
  "GeographicFeature", 
  "Person",
};

// ******ENTITY MULTIPLIER****** //
float entityMultiplier = .0001; // .0001 seems pretty even.  this multiplier brings down the entity totals so that they can be factored into the spline defining equatio
float entityToNormalRatio = .75; // this determines roughly how many entity terms to put in compared to the other pos entries.  this : 1


float[][] bucketDataPoints = new float[bucketsToUse.length][0];
boolean reorderBucketsByMaxHeight = true;

//
int bucketDataPointInputMethod = 0; // defined in setup

ArrayList<Bucket> bucketsAL = new ArrayList<Bucket>();
HashMap<String, Bucket> bucketsHM = new HashMap<String, Bucket>();


ArrayList<SpLabel> splabels = new ArrayList<SpLabel>(); // the spline/label objects

float defaultFontSize = 6f; // when it cannot find how big to make a letter.. because the top isnt there, then this is the default
PFont font; // the font that is used

float minCharHeight = 2; // minimum height for the middle of the label.  anything less than this will be discounted


// keep track of the used terms so that they only appear once throughout the entire diagram
HashMap<String, Term> usedTerms = new HashMap<String, Term>(); // the ones that were succesfully placed
// keep track of terms used at different x locations
HashMap<Integer, HashMap<String, Integer>> usedTermsAtX = new HashMap<Integer, HashMap<String, Integer>>(); 




// other stuff
String timeStamp = "";
boolean exportNow = false;

//
void setup() {
  //size(5300, 1800); // for draft version sent to PopSci
  //size(5300, 1000);

  size(4800, 1200); // good
  ///size(1200, 500); // small for debug
  //size(2200, 800); // small for debug
  OCRUtils.begin(this);
  background(bgColor);
  randomSeed(1667);

  //font = createFont("Helvetica", defaultFontSize);
  font = createFont("Knockout-HTF31-JuniorMiddlewt", defaultFontSize);
  //font = createFont("UniversLTStd", defaultFontSize);
  //font = createFont("Gotham-Medium", defaultFontSize);
  //font = createFont("Gotham-Book", defaultFontSize);
  //font = createFont("TheOnlyException", defaultFontSize); // awesome
  //font = createFont("The Only Exception", defaultFontSize); // awesome PC


  setConstrainRange(); // for setting the boundaries of the the year stuff so you don't manually move it too far

  // setup the colors
  setupHexColors();

  // read in the appropriate bucket data
  bucketDataPointInputMethod = INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT;
  readInBucketData();
  makeBucketDataPoints(yearRange[1] - yearRange[0] + 1, bucketDataPointInputMethod); // making points for the year range.  this is what actually defines the splines

  orderBucketTerms(); // this will not only order the terms in each bucket by their seriesSum, but will also do the same for each bucket's Pos and also make the ordered indices for each term


  println("making masterSpLabels");
  makeMasterSpLabels();

  // then press 'm' or 'n' to make or read in the splines

    // temp
  if (autoLoadSplines) readInSplinesForSpLabels();

  // debug
  //constrainRange[0] = 1970;
  //constrainRange[1] = 1990;
  //setConstrainRange();
} // end setup

//
void draw() {
  println("start of draw.  frame: " + frameCount);
  if (exportNow) {
    beginRecord(PDF, "pdf/" + timeStamp + ".pdf"); 
    println("starting export to PDF");
  }

  background(bgColor);




  // draw dates
  drawDates();

  for (SpLabel sp : splabels) {
    fill(sp.c);
    sp.display();

    if (splinesOn) sp.displaySplines();
    if (facetsOn) sp.displayFacetPoints();
    if (displayHeightsOn) sp.displayHeights();
  }



  if (debugOn) {
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    // do constrain stuff
    float x1 = getXFromYear(constrainRange[0], blankTerm);
    float x2 = getXFromYear(constrainRange[1], blankTerm);
    text("from: " + constrainRange[0] + " :: " + x1, 20, 40);
    text("from: " + constrainRange[1] + " :: " + x2, 20, 60);
    line(x1, 0, x1, 50);
    text(constrainRange[0], x1, 55);
    line(x2, 0, x2, 50);
    text(constrainRange[1], x2, 55);


    // print the frame
    text("frame: " + frameCount, 20, 20);
  }
  noLoop();

  if (exportNow) {
    endRecord(); 
    exportNow = false;
    println("ending export to PDF");
  }

  println("end of draw.  frame: " + frameCount);
} // end draw


//
void keyPressed() {
  if (keyCode == SHIFT) shiftIsDown = true;
} // end keyPressed


//
void keyReleased() {  
  if (key == 'a') {
    snap();
    populateFullForDebug(); // will fill up the thing with random phrases
  }


  if (key == 'p') {
    println("saving frame");
    timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
    println("end of saveFrame");
    //exportNow = true;
    loop();
  }
  if (keyCode == UP || keyCode == DOWN) {
  }
  if (key == ' ') {
    doPopulate(1);
  }

  if (key >= '0' && key <= '9') {
    int value = Character.getNumericValue(key);
    doPopulate(value * 10);
  }
  if (key == 'o') doPopulate(5000);
  if (key == 'i') doPopulate(2500);
  if (key == 'u') doPopulate(1500);
  if (key == 'y') doPopulate(750);
  if (key == 't') doPopulate(350);
  if (key == 'q') doPopulate(3);




  if (key == 'f') facetsOn = !facetsOn;
  if (key == 's') splinesOn = !splinesOn;
  if (key == 'v') variationOn = !variationOn;
  if (key == 'd') debugOn = !debugOn;
  if (key == 'h') displayHeightsOn = !displayHeightsOn;

  if (keyCode == RIGHT || keyCode == LEFT || key == ',' || key == '.') {
    if (keyCode == RIGHT) {
      if (shiftIsDown) constrainRange[1] += 5;
      else constrainRange[1]++;
    }
    else if (keyCode == LEFT) {
      if (shiftIsDown) constrainRange[1] -= 5;
      else constrainRange[1]--;
    }

    if (constrainRange[1] <= constrainRange[0]) constrainRange[1] = constrainRange[0] + 1;
    else if (constrainRange[1] > yearRange[1]) constrainRange[1] = yearRange[1];

    if (key == '.') {
      if (shiftIsDown) constrainRange[0] += 5;
      else constrainRange[0]++;
    }
    else if (key == ',') {
      if (shiftIsDown) constrainRange[0] -= 5;
      else constrainRange[0]--;
    }
    if (constrainRange[0] >= constrainRange[1]) constrainRange[0] = constrainRange[1] - 1;
    else if (constrainRange[0] < yearRange[0]) constrainRange[0] = yearRange[0];

    println("changed year range to: " + constrainRange[0] + " to " + constrainRange[1]);
    setConstrainRange();
    //repopulateFromFailedHM();
  }

  if (key == SHIFT) {
    shiftIsDown = false;
  }

  // MAKE OR READ IN THE SPLINES
  if (key == 'n') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT make new splines");
      return;
    }

    splitMasterSpLabelsVertically(maxSplineHeight, minimumSplineSpacing, maximumPercentSplineSpacing); // this will generate the middleSplines for each splabel by straight up vertical

    /*
     // do the great divide
     if (addMiddleDivide) splitMiddleSpLabel(middleDivideDistance);
     */
  }
  if (key == 'b') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT make new heights");
      return;
    }
    println("making HEIGHTS");
    for (SpLabel sp : splabels) {
      makeSpLabelHeights(sp); 
      println("done with making heights for: " + sp.bucketName);
      //break; // debug break;
    }
  }
  if (key == 'c') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT clip splabel splines");
      return;
    }
    println("clipping SpLabel splines to years: " + constrainRange[0] + " to " + constrainRange[1]);
    debugClipSpLabelsByConstrainRange();
  }

  if (key == 'x') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT export");
      return;
    } 
    exportSplines();
  }
  if (key == 'z') {
    readInSplinesForSpLabels();
    /* ????????     
     // do the great divide
     if (addMiddleDivide) splitMiddleSpLabel(middleDivideDistance);
     */
  }


  if (key == 'r') {
    loop();
  }
} // end keyReleased


//
void mouseReleased() {
} // end mouseReleased


//
String makeRandomPhrase() {
  String newPhrase = "";
  RiLexicon ril = new RiLexicon();
  String[] basis = {
    "Shark flying at midnight", 
    "Enjoying life", 
    "Cheddar soup", 
    "11 dogs", 
    "John Glenn", 
    "Going",
  };
  String[] posArray = RiTa.getPosTags(RiTa.stripPunctuation(basis[(int)random(basis.length)].toLowerCase()));
  for (int i = 0; i < posArray.length; i++) {
    newPhrase += ril.randomWord(posArray[i]);
    if (i < posArray.length - 1) newPhrase += " ";
  }
  return newPhrase;
} // end makeRandomPhrase

//
void setConstrainRange() {
  float x1 = getXFromYear(constrainRange[0], blankTerm);
  float x2 = getXFromYear(constrainRange[1], blankTerm);
  constrainRangeX[0] = x1;
  constrainRangeX[1] = x2;
} // end setConstrainRange

//
void debugClipSpLabelsByConstrainRange() {
  println("in debugClipSpLabelsByConstrainRange");
  for (int i = 0; i < splabels.size(); i++) {
    splabels.get(i).topSpline = clipByX(splabels.get(i).topSpline, constrainRangeX[0], constrainRangeX[1]);
    splabels.get(i).bottomSpline = clipByX(splabels.get(i).bottomSpline, constrainRangeX[0], constrainRangeX[1]);
  }
} // end debugClipSpLabelsByConstrainRange
Spline clipByX(Spline s, float xLow, float xHigh) {
  Spline clipped = new Spline();
  for (PVector p : s.curvePoints) {
    if (p.x >= xLow - 10 && p.x <= xHigh + 10) clipped.addCurvePoint(p);
  }
  clipped.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
  return clipped;
} // end clipByX

//
void doPopulate(int toMake) {
  println("in doPopulate.  trying to make: " + toMake);
  long startTime = millis();
  String status = "";
  int positivePlacements = 0;
  int counter = 0;
  int lastPercent = -1;
  for (int j = 0; j < toMake; j++) {
    for (int i = 0; i < bucketsAL.size(); i++) {
      Bucket b = bucketsAL.get(i);
      //Bucket b = bucketsAL.get(1);
      //println("NAME: " + b.name);
      status = tryToPopulateBucketWithNextTerm(b);
      if (status.equals(POPULATE_STATUS_SUCCESS)) positivePlacements++;
    }
    counter++;
    int thisPercent = (int)(100 * ((float)counter / toMake));
    if (thisPercent != lastPercent) {
      print("_" + thisPercent + "_");
      lastPercent = thisPercent;
    }
  }
  println("_");

  println("  placed " + positivePlacements + " terms of " + (toMake * bucketsAL.size()) + " possible with time of: " + (millis() - startTime));
  println(" remaining options: ");
  for (Bucket b : bucketsAL) {
    println ( "   b.name: " + b.name + " options remaining: " + b.bucketTermsRemainingAL.size());
  }

  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  //exportNow = true;

  loop();
} // end doPopulate

//
//
//
//


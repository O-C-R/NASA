/**
 INSTRUCTIONS FOR USE
 make sure the settings are correct:
 Set the size of the sketch
 Order the buckets as they should be
 get the spline info all righta nd such
 
 
 when running for the first time
 run, verify that the main splines are where they should be
 press 'n' to generate the middle splines
 press 'r' to refresh the screen and verify that the splines are cool
 press 'b' to generate the heights
 press 'x' to export the splines
 RESTART THE PROGRAM
 press 'z' to load the splines
 press 'v' to shift the top half up
 press 'e' to make the flare lines
 if everything's cool, then 
 press 'x' to re-export the splines
 switch the 'disableSplineMaking' to true so that you don't accidentally make new splines or export over your old version
 and also switch 'autoLoadSplines' to true so that it will automatically load things upon startup  
 
 now, whenever you want to run it
 press 'z' to import all of the splines and go from there, 
 or set autoLoadSplines to true to auto load them all
 
 press a number or t, u, i, o to populate the splabels [see below for which key does what number]
 press 'a' to run the filler verbage
 then press 'w' to populate the flares
 
 press UP or DOWN to select individual buckets or ALL buckets to populate
 
 
 */


import rita.*;

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import java.util.Map;
import processing.pdf.*;
import java.util.Arrays;


// ****** //
// MAIN CONTROLS //
boolean disableSplineMaking = false; // disable the generation of splines [as to not overwrite whatever if it's already made] also disables export
boolean autoLoadSplines = false; // will auto load the splines [assuming they are generated already] in the setup
boolean disableManualImport = false; // so that you don't erase everything
boolean disableFlareMaking = false; // so that you can't make flares!
boolean debugQuickLoader = false; // when this is set to true, will only read in 1/4 of the actual data
// ****** //


// visual controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean flareSplinesOn = true;
boolean variationOn = false;
boolean shiftIsDown = false;
boolean debugOn = false;
boolean displayHeightsOn = false;
boolean displayLabels = true;


// manual layout of bucket control
boolean manualLayerControl = true; // will make it so that the stack goes in the order that the buckets are read in as opposed to calculating and balancing things out
String manualMiddleBucketName = "research_and_development"; // if you want to manually define the emiddle bucket


// *** main spline numbers *** //
float splineMinAngleInDegrees = .05f; // .02 for high
float splineMinDistance = 10f; // minimum distance between makeing a facet
int splineDivisionAmount = 170; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing


// *** child spline numbers *** // 
float minimumSplineSpacing = 5f; // 4f is a good ht; // *** change this to set the minimum spline ht
float maximumPercentSplineSpacing = .2; // .2 is ok..
float childMaxPercentMultiplier = 1.95; // 2 would be the same as the parent // *** change this to alter falloff of children size
float testSplineSpacing = minimumSplineSpacing;



boolean addMiddleDivide = true; // whether or not to split up the middle SpLabel   // FIX THIS
float middleDivideDistance = 40f; // if dividing the middle SpLabel, how much to divide it by   // FIX THIS
boolean skipMiddleLine = true; // if on it will make it so that text cannot go on this middle line

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  //140f, 400f, 140f, 350f // for draft
  120f, 150f, 120f, 150f
};

// *** label numbers
float minLabelSpacing = 10f; // the minimum spacing between labels along a spline
float wiggleRoom = 48f; // how much the word can move around instead of being precisely on the x point
float maximumFillAlpha = 255f;
float minimumFillAlpha = 30f;
HashMap<String, ArrayList<String>> termSimpleCount = new HashMap<String, ArrayList<String>>(); // when loading the terms keep track of how many times they appear
int maximumTermOverallCount = 0;
int maximumTermSingleBucketCount = 0;

// when divding up the splabels into the middlesplines
float maxSplineHeight = 19f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed

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
//String mainDiretoryPath = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAll";
String mainDiretoryPath = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAllCLEAN";
//String mainDiretoryPath = "C:\\Users\\OCR\\Documents\\GitHub\\NASA\\Data\\BucketGramsAllCLEAN";
String[] bucketsToUse = {
  "satellites", // * 
  //"moon", // *
  //"research_and_development", // * 
  "rockets", // *
  //"space_shuttle", // * 
  "russia", 


  //"debug", 
  //"administrative", 
  //"astronaut", 
  //"mars",
  //"people", 
  //"politics", 
  //"spacecraft", 
  //"us",
};
HashMap<String, Integer> hexColors = new HashMap<String, Integer>(); // called from setup(), done in AbucketReader
int currentBucketIndex = bucketsToUse.length; // selectively fill the buckets.  default set to all


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

String[] fillersToUse = {
  "vbg",
};

// ******ENTITY MULTIPLIER****** //
float entityMultiplier = .0001; // .0001 seems pretty even.  this multiplier brings down the entity totals so that they can be factored into the spline defining equatio
float entityToNormalRatio = .45; // this determines roughly how many entity terms to put in compared to the other pos entries.  this : 1


float[][] bucketDataPoints = new float[bucketsToUse.length][0];
//boolean reorderBucketsByMaxHeight = false;

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
HashMap<String, Term> usedTermsSimple = new HashMap<String, Term>(); // same as used terms but prefixed with the bucket name
// keep track of terms used at different x locations
HashMap<Integer, HashMap<String, Integer>> usedTermsAtX = new HashMap<Integer, HashMap<String, Integer>>(); // save the exact x locations of the terms
HashMap<Integer, HashMap<String, Integer>> usedFillerTermsAtX = new HashMap<Integer, HashMap<String, Integer>>(); // for the filler, save the approx year and String


// Flares
ArrayList<Flare> flares = new ArrayList<Flare>();
int flareLayers = 3; // the number of layers to use.. will make for some overlap.  layer 0 will be the brightest, layer n will be the dimmest.  layer 0 will be drawn last and on top
float fullGrayColor = 70; // lightest gray for the primary verbs
float lowestGrayColor = 30; // darkest gray for the other verbs
float minimumFlareHeight = defaultFontSize; // minimum potential height of the text at the start
float maximumFlareHeight = defaultFontSize * 1.5; // maximum potential height of the text at the ends


// other stuff
String timeStamp = "";
boolean exportNow = false;

// blockImage
PGraphics blockImage; // the one that holds the lable letter blocks for comparison
boolean skipLabelsDueToBlockImage = true; // when true will consult the blockImage while making each label.  if it comes to a mark that already exists then will stop and return null in Label
color blockImageColor = color(0, 255, 127);

//
void setup() {
  //size(5300, 1800); // for draft version sent to PopSci
  //size(5300, 1000);

  //size(5300, 1400); // good
  ///size(1200, 500); // small for debug
  size(2200, 800); // small for debug
  OCRUtils.begin(this);
  background(bgColor);
  randomSeed(1667);

  //font = createFont("Helvetica", defaultFontSize);
  font = createFont("Knockout-HTF31-JuniorMiddlewt", defaultFontSize); // use this one
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

  makeAlphaValuesForTerms(); // this will assign alpha values to each term  

  println("making masterSpLabels");
  makeMasterSpLabels();

  // create the image that will hold the block images for each letter, this way a label won't appear on top of another label.. hopefully
  blockImage = createGraphics(width, height);
  blockImage.beginDraw();
  blockImage.background(255);

  // then press 'm' or 'n' to make or read in the splines

  // temp
  if (autoLoadSplines) readInSplinesForSpLabels();


  // debug clip


  constrainRange[0] = 1962;
  constrainRange[1] = 1974;
  setConstrainRange();
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

  // draw splabels
  for (SpLabel sp : splabels) {
    fill(sp.c);
    if (displayLabels) sp.display();
    //sp.topSpline.displayCurvePoints(); // just to test the dates.  seems good
    if (splinesOn) sp.displaySplines();
    if (facetsOn) sp.displayFacetPoints();
    if (displayHeightsOn) sp.displayHeights();
  }

  // draw Flares
  for (Flare f : flares) {
    if (f != null) {
      if (displayLabels) f.display();
      noFill();
      if (flareSplinesOn) f.displaySplines();
      if (facetsOn && flareSplinesOn) f.displayFacetPoints();
      if (displayHeightsOn && flareSplinesOn) f.displayHeights();
    }
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
    println("saving frame");
    saveFrame("output/" + timeStamp + ".png");
    println("done saving frame");
    endRecord(); 
    exportNow = false;
    println("ending export to PDF");
    outputSpLabels();
  }

  println("end of draw.  frame: " + frameCount);
} // end draw


//
void keyPressed() {
  if (keyCode == SHIFT) shiftIsDown = true;
} // end keyPressed


//
void keyReleased() {  

  // save out stuff
  if (key == 'p') {
    println("saving frame");
    timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
    println("end of saveFrame");
    //exportNow = true;
    loop();
  }
  if (key == '\\') {
    println("saving PDF & frame & labels...");
    timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
    println("end of saveFrame");
    exportNow = true;
    loop();
  }


  if (key == ';') {
    println("saving out the block image"); 
    blockImage.save("blockImage/" + OCRUtils.getTimeStampWithDate() + ".png");
    println("done saving out the block image");
  }


  // population controls
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



  if (key == 'a') {    
    runFillInStuff();
    loop();
  }


  if (key == 'f') facetsOn = !facetsOn;
  if (key == 's') splinesOn = !splinesOn;
  //if (key == 'v') variationOn = !variationOn;
  if (key == 'd') debugOn = !debugOn;
  if (key == 'h') displayHeightsOn = !displayHeightsOn;
  if (key == 'l') displayLabels = !displayLabels;

  if (key == ',') flareSplinesOn = !flareSplinesOn;

  if (key == '.') {
    println("clearing all flares");
    usedTerms.clear(); // might overlap a bit.. but its ok for now
    flares.clear();
  }

  if (key == 'g') clearGC();



  if (keyCode == UP || keyCode == DOWN) {
    // use up and down to select which splabel will get populated
    if (keyCode == UP) {
      currentBucketIndex++;
    }
    else {
      currentBucketIndex--;
    }
    if (currentBucketIndex < 0) currentBucketIndex = bucketsAL.size();
    else if (currentBucketIndex > bucketsAL.size()) currentBucketIndex = 0;

    if (currentBucketIndex < bucketsAL.size()) println("Changing the target bucket to : " + bucketsAL.get(currentBucketIndex).name);
    else println("changing to ALL BUCKETS");
  }
  /*
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
   
   
   if (constrainRange[0] >= constrainRange[1]) constrainRange[0] = constrainRange[1] - 1;
   else if (constrainRange[0] < yearRange[0]) constrainRange[0] = yearRange[0];
   
   println("changed year range to: " + constrainRange[0] + " to " + constrainRange[1]);
   setConstrainRange();
   //repopulateFromFailedHM();
   }
   
   if (key == SHIFT) {
   shiftIsDown = false;
   }
   */
  // MAKE OR READ IN THE SPLINES
  if (key == 'n') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT make new splines");
      return;
    }
    splitMasterSpLabelsVertically(maxSplineHeight, minimumSplineSpacing, maximumPercentSplineSpacing); // this will generate the middleSplines for each splabel by straight up vertical
  }
  if (key == 'b') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT make new heights");
      return;
    }
    println("making HEIGHTS");
    for (SpLabel sp : splabels) {
      //if (!sp.bucketName.equals("russia")) continue; // debug
      makeSpLabelHeights(sp); 
      println("done with making heights for: " + sp.bucketName);
      //break; // debug break;
    }
  }
  if (key == 'v') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT shift splines up");
      return;
    }
    println("shifting splines up");
    splitMiddleSpLabel(middleDivideDistance);
    println("done shifting splines up");
  }

  if (key == 'c') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT clip splabel splines");
      return;
    }
    println("clipping SpLabel splines to years: " + constrainRange[0] + " to " + constrainRange[1]);
    debugClipSpLabelsByConstrainRange();
  }

  if (key == 'e') {
    if (disableFlareMaking) {
      println("disableFlareMaking is set to true, will NOT make new flare lines");
      return;
    }
    makeEdgeFlares();
  }
  if (key == 'q') {
  }

  if (key == 'w') {
    populateFlares();
  } 

  if (key == 'x') {
    if (disableSplineMaking) {
      println("disableSplineMaking set to true, will NOT export");
      return;
    } 
    exportSplines();
  }
  if (key == 'z') {
    if (disableManualImport) {
      println("disableManualImport set to true.  so will NOT import");
      return;
    }
    readInSplinesForSpLabels();
    loop();
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
      if (currentBucketIndex < bucketsAL.size()) {
        if (i != currentBucketIndex) continue;
      }
      Bucket b = bucketsAL.get(i);
      status = tryToPopulateBucketWithNextTerm(b);
      if (status.equals(POPULATE_STATUS_SUCCESS)) positivePlacements++;
    }
    counter++;
    int thisPercent = (int)(100 * ((float)counter / toMake));
    if (thisPercent != lastPercent) {
      print("_" + thisPercent + "_");
      lastPercent = thisPercent;
      //if (thisPercent % 5 == 0) clearGC();
    }
  }
  println("_");

  println("  placed " + positivePlacements + " terms of " + (currentBucketIndex < bucketsAL.size() ? toMake : toMake * bucketsAL.size()) + " possible with time of: " + ceil((float)(millis() - startTime) / 1000) + " seconds");
  println(" remaining options: ");
  for (Bucket b : bucketsAL) {
    println ( "   b.name: " + b.name + " options remaining: " + b.bucketTermsRemainingAL.size());
  }

  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);


  // for overnight exporting!
  // ****** //
  /*
  runFillInStuff();
   exportNow = true;
   */
  // ****** //

  loop();
} // end doPopulate

// 
void runFillInStuff() {
  for (int i = 0; i < bucketsAL.size(); i++) {
    if (currentBucketIndex < bucketsAL.size()) {
      if (i != currentBucketIndex) continue;
    }
    Bucket b = bucketsAL.get(i);
    fillInTheGapsForBucket(b);
    clearGC();
  }
} // end runFillInStuff

//
void clearGC() {
  println("\n used memory: " + Runtime.getRuntime().freeMemory());
  println(" free memory: " + Runtime.getRuntime().totalMemory());
  System.gc();
  println(" used memory: " + Runtime.getRuntime().freeMemory());
  println(" free memory: " + Runtime.getRuntime().totalMemory());
} // end clearGC



//
//
//
//


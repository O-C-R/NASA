import rita.*;

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import java.util.Map;


// main controlling vars
float splineMinAngleInDegrees = .05f; // .02 for high
float splineMinDistance = 20f; // minimum distance between makeing a facet
int splineDivisionAmount = 150; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing

boolean addMiddleDivide = true; // whether or not to split up the middle SpLabel
float middleDivideDistance = 40f; // if dividing the middle SpLabel, how much to divide it by
boolean skipMiddleLine = false; // if on it will make it so that text cannot go on this middle line

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  140f, 400f, 140f, 350f
    //40f, 500f, 40f, 100f
};

float minLabelSpacing = 10f; // the minimum spacing between labels along a spline
float wiggleRoom = 48f; // how much the word can move around instead of being precisely on the x point

// when divding up the splabels into the middlesplines
float maxSplineHeight = 20f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
float splineCurvePointDistance = 10f; // the approx distance between curve points

int[] yearRange = {
  1961, 
  2008 // fix this later
};
int[] constrainRange = {
  yearRange[0], 
  yearRange[1]
};
float[] constrainRangeX = {
  0f, 
  0f
};


// placeholder vars
Letter blankLetter = new Letter();
Term blankTerm = new Term(); // blank term used to gather x position.  used main for series length which is copied over as buckets are read in

// bucket vars
String mainDiretoryPath = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAll";
String[] bucketsToUse = {
  //"debug", 
  //"administrative", 
  //"astronaut", 
  //"mars", 
  "moon", // *
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



// visual controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean variationOn = false;
boolean shiftIsDown = false;
boolean debugOn = false;

//
void setup() {
  size(5300, 1200);
  //size(2600, 800);
  OCRUtils.begin(this);
  background(bgColor);
  randomSeed(1667);

  //font = createFont("Helvetica", defaultFontSize);
  font = createFont("Knockout-HTF31-JuniorMiddlewt", defaultFontSize);
  //font = createFont("UniversLTStd", defaultFontSize);
  //font = createFont("Gotham-Medium", defaultFontSize);
  //font = createFont("Gotham-Book", defaultFontSize);
  //font = createFont("TheOnlyException", defaultFontSize); // awesome

  setConstrainRange(); // for setting the boundaries of the the year stuff so you don't manually move it too far

  // setup the colors
  setupHexColors();

  // read in the appropriate bucket data
  bucketDataPointInputMethod = INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT;
  readInBucketData();
  makeBucketDataPoints(yearRange[1] - yearRange[0] + 1, bucketDataPointInputMethod); // making points for the year range.  this is what actually defines the splines

  orderBucketTerms(); // this will not only order the terms in each bucket by their seriesSum, but will also do the same for each bucket's Pos and also make the ordered indices for each term

  makeMasterSpLabels(g);
  makeVariationSplines(); // this will make it so that the middle lines are a bit weighted.  otherwise they will be evenly distributed
  //  //splitMasterSpLabelsByPercent(maxSplineHeight, splineCurvePointDistance); // this will generate the middleSplines for each splabel by percent
  splitMasterSpLabelsVertically(maxSplineHeight, splineCurvePointDistance); // this will generate the middleSplines for each splabel by straight up vertical 
  assignSpLabelNeighbors(); // this does the top and bottom neighbors for the spline labels

    // do the great divide
  if (addMiddleDivide) splitMiddleSpLabel(middleDivideDistance, g);
} // end setup

//
void draw() {
  background(bgColor);

  // draw dates
  drawDates(g);

  for (SpLabel sp : splabels) {
    fill(sp.c);
    sp.display(g);

    if (splinesOn) sp.displaySplines(g);
    if (facetsOn) sp.displayFacetPoints(g);

    if (variationOn) sp.displayVariationSpline(g);
  }



  if (debugOn) {
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    // do constrain stuff
    float x1 = getXFromYear(constrainRange[0], blankTerm, g);
    float x2 = getXFromYear(constrainRange[1], blankTerm, g);
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
} // end draw


//
void keyPressed() {
  if (keyCode == SHIFT) shiftIsDown = true;
} // end keyPressed


//
void keyReleased() {  
  if (key == 'p') {
    String timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
  }
  if (keyCode == UP || keyCode == DOWN) {
  }
  if (key == ' ') {

    //boolean didPlace = populateBiggestSpaceAlongX(mouseX, splabels.get((random(1) > .5 ? 1 :0)), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
    /*
     for (int i = 0; i < 80; i++) {
     //boolean didPlace = populateBiggestSpaceAlongX(mouseX, splabels.get(0), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
     boolean didPlace = populateBiggestSpaceAlongX(random(padding[3], width - padding[1]), splabels.get((int)random(splabels.size())), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
     print(i + (didPlace ? "-" : "x"));
     }
     */
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

  loop();
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
    "Cheddar soup"
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
  float x1 = getXFromYear(constrainRange[0], blankTerm, g);
  float x2 = getXFromYear(constrainRange[1], blankTerm, g);
  constrainRangeX[0] = x1;
  constrainRangeX[1] = x2;
} // end setConstrainRange

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
      //Bucket b = bucketsAL.get(2);
      status = tryToPopulateBucketWithNextTerm(b, g);

      if (status.equals(POPULATE_STATUS_SUCCESS)) positivePlacements++;
    }
    counter++;
    int thisPercent = (int)(100 * ((float)counter / toMake));
    if (thisPercent != lastPercent) {
      print("_" + thisPercent + "_");
    }
  }
  println("_");

  println("  placed " + positivePlacements + " terms of " + (toMake * bucketsAL.size()) + " possible with time of: " + (millis() - startTime));
  println(" remaining options: ");
  for (Bucket b : bucketsAL) {
    println ( "   b.name: " + b.name + " options remaining: " + b.bucketTermsRemainingAL.size());
  }
} // end doPopulate

//
//
//
//


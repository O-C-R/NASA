import rita.*;

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;


// main controlling vars
float splineMinAngleInDegrees = .15f; // .02 for high
float splineMinDistance = 10f; // minimum distance between makeing a facet
int splineDivisionAmount = 120; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  70f, 50f, 70f, 50f
    //40f, 100f, 40f, 100f
};

float minLabelSpacing = 10f; // the minimum spacing between labels along a spline

// when divding up the splabels into the middlesplines
float maxSplineHeight = 30f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
float splineCurvePointDistance = 30f; // the approx distance between curve points



// assume this is in order already or whatever
String[] fakeBucketWords = {
  "alphabet", 

  "belt buckle", 

  "charlie", 
  /*  
   "doodlebug", 
   
   "eeg machine", 
   
   "facebook", 
   "gamora",
   "hippo man",
   "indian river",
   "jack and the peaman"
   
   */
};
int[][] fakeBucketData = new int[fakeBucketWords.length][0]; // [the bucket][the data in the bucket as an int[]]

ArrayList<SpLabel> splabels = new ArrayList<SpLabel>(); // the spline/label objects

float defaultFontSize = 16f; // when it cannot find how big to make a letter.. because the top isnt there, then this is the default
PFont font; // the font that is used


// random controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean variationOn = false;

//
void setup() {
  //size(1000, 300);
  size(1600, 700);
  OCRUtils.begin(this);
  background(255);
  randomSeed(1667);

  font = createFont("Helvetica", defaultFontSize);


  int fakeBucketDataPoints = ceil((float)(width - padding[1] - padding[3]) / 20); 
  makeFakeBucketData(fakeBucketDataPoints);

  makeMasterSpLabels(g); // this will make the splabels based on the fakeBucketWords and fakeBucketData

  makeVariationSplines(); // this will make it so that the middle lines of a splabel are uneven

  splitMasterSpLabels(maxSplineHeight, splineCurvePointDistance); // this will generate the middleSplines for each splabel

  assignSpLabelNeighbors(); // this does the top and bottom neighbors for the spline labels

    //
  //populateFullForDebug(); // will populate every line with random RiTa phrases.  linear fill from left to right with a bit of spacing between
} // end setup

//
void draw() {

  background(255);
  background(0);

  for (SpLabel sp : splabels) {
    fill(sp.c);
    sp.display(g);

    if (splinesOn) sp.displaySplines(g);
    if (facetsOn) sp.displayFacetPoints(g);

    if (variationOn) sp.displayVariationSpline(g);
  }
} // end draw


//
void keyReleased() {  
  if (key == 'p') {
    String timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output/" + timeStamp + ".png");
  }
  if (keyCode == UP || keyCode == DOWN) {
  }
  if (key == ' ') {
    // boolean populateBiggestSpaceAlongX(float x, SpLabel splabel, String text, float spacing, float wiggleRoom) {
    boolean didPlace = populateBiggestSpaceAlongX(mouseX, splabels.get(0), "hello world", 10f, 18f);
    //println("was successful in placing new label: " + didPlace);
  }
  
  if (key == 'f') facetsOn = !facetsOn;
  if (key == 's') splinesOn = !splinesOn;
  if (key == 'v') variationOn = !variationOn;
} // end keyReleased


//
void mouseReleased() {
} // end mouseReleased


//
String makeRandomPhrase() {
  String newPhrase = "";
  RiLexicon ril = new RiLexicon();
  String basis = "Shark flying at midnight";
  String[] posArray = RiTa.getPosTags(RiTa.stripPunctuation(basis.toLowerCase()));
  for (int i = 0; i < posArray.length; i++) {
    newPhrase += ril.randomWord(posArray[i]);
    if (i < posArray.length - 1) newPhrase += " ";
  }
  return newPhrase;
} // end makeRandomPhrase

//
//
//
//


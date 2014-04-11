import rita.*;

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;

import java.util.Map;


// main controlling vars
float splineMinAngleInDegrees = .15f; // .02 for high
float splineMinDistance = 10f; // minimum distance between makeing a facet
int splineDivisionAmount = 120; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  240f, 250f, 240f, 250f
  //40f, 500f, 40f, 100f
};

float minLabelSpacing = 10f; // the minimum spacing between labels along a spline
float wiggleRoom = 18f; // how much the word can move around instead of being precisely on the x point

// when divding up the splabels into the middlesplines
float maxSplineHeight = 45f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
float splineCurvePointDistance = 10f; // the approx distance between curve points

int[] yearRange = {
  1961, 
  2009
};

// bucket vars
String mainDiretoryPath = "/Applications/MAMP/htdocs/OCR/NASA/Data/BucketGramsAll";
String[] bucketsToUse = {
  "administrative", 
  "astronaut", 
  "mars", 
  "moon", 
  /*
  "people",
   "politics",
   "research_and_development",
   "rockets",
   "russia",
   "satellites",
   "space_shuttle",
   "spacecraft",
   "us",
   */
};
float[][] bucketDataPoints = new float[bucketsToUse.length][0];
ArrayList<Bucket> bucketsAL = new ArrayList<Bucket>();
HashMap<String, Bucket> bucketsHM = new HashMap<String, Bucket>();


ArrayList<SpLabel> splabels = new ArrayList<SpLabel>(); // the spline/label objects

float defaultFontSize = 6f; // when it cannot find how big to make a letter.. because the top isnt there, then this is the default
PFont font; // the font that is used


// keep track of the used terms so that they only appear once throughout the entire diagram
HashMap<String, Term> usedTerms = new HashMap<String, Term>(); // the ones that were succesfully placed
HashMap<String, Term> failedTerms = new HashMap<String, Term>(); // the ones that were not placed


// visual controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean variationOn = true;

//
void setup() {
  size(5300, 1200);
  //size(3600, 1000);
  OCRUtils.begin(this);
  background(255);
  randomSeed(1667);

  font = createFont("Helvetica", defaultFontSize);


  // read in the appropriate bucket data
  readInBucketData();
  makeBucketDataPoints(yearRange[1] - yearRange[0] + 1); // making points for the year range

  orderBucketTerms(); // this will not only order the terms in each bucket by their seriesSum, but will also do the same for each bucket's Pos and also make the ordered indices for each term

  /*
  Bucket b = bucketsAL.get(0);
   for (int i = 0; i < 29; i++) {
   Term t = b.bucketTermsAL.get(i);
   println(t);
   for (int j = 0; j < t.series.length; j++) print(nf(t.series[j], 3, 6) + " ");
   println("___");
   for (int j = 0; j < t.seriesOrderedIndices.length; j++) print(nf(t.seriesOrderedIndices[j], 10) + " ");
   println("___");
   }
   */


  makeMasterSpLabels(g);
  makeVariationSplines();
  //  //splitMasterSpLabelsByPercent(maxSplineHeight, splineCurvePointDistance); // this will generate the middleSplines for each splabel by percent
  splitMasterSpLabelsVertically(maxSplineHeight, splineCurvePointDistance); // this will generate the middleSplines for each splabel by straight up vertical 
  assignSpLabelNeighbors(); // this does the top and bottom neighbors for the spline labels


    //
  //  //populateFullForDebug(); // will populate every line with random RiTa phrases.  linear fill from left to right with a bit of spacing between
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

    //boolean didPlace = populateBiggestSpaceAlongX(mouseX, splabels.get((random(1) > .5 ? 1 :0)), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
    /*
     for (int i = 0; i < 80; i++) {
     //boolean didPlace = populateBiggestSpaceAlongX(mouseX, splabels.get(0), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
     boolean didPlace = populateBiggestSpaceAlongX(random(padding[3], width - padding[1]), splabels.get((int)random(splabels.size())), makeRandomPhrase(), minLabelSpacing, wiggleRoom);
     print(i + (didPlace ? "-" : "x"));
     }
     */


    int toMake = 130;
    for (int i = 0; i < toMake; i++) print(".");
    println("x");
    for (int j = 0; j < toMake; j++) {
      for (int i = 0; i < bucketsAL.size(); i++) {
        //for (int i = 0; i < 2; i++) {
        Bucket b = bucketsAL.get(i);
        //Bucket b = bucketsAL.get(0);
        String status = tryToPopulateBucketWithNextTerm(b, g);
      }
      print(".");
    }
    println("_");
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
//
//
//


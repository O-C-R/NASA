import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import rita.*; 
import ocrUtils.maths.*; 
import ocrUtils.*; 
import ocrUtils.ocr3D.*; 
import java.util.Map; 
import processing.pdf.*; 
import java.util.Date; 

import ocrUtils.maths.*; 
import ocrUtils.*; 
import ocrUtils.ocr3D.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TypeAlongCurveColors extends PApplet {













// main controlling vars
// float splineMinAngleInDegrees = .05f; // .02 for high
float splineMinAngleInDegrees = .25f; // .02 for high
// float splineMinDistance = 20f; // minimum distance between makeing a facet
float splineMinDistance = 50f; // minimum distance between makeing a facet
// int splineDivisionAmount = 150; // how many divisions should initially be made
int splineDivisionAmount = 50; // how many divisions should initially be made
boolean splineFlipUp = true; // whether or not to flip the thing

boolean addMiddleDivide = true; // whether or not to split up the middle SpLabel
float middleDivideDistance = 100f; // if dividing the middle SpLabel, how much to divide it by

float[] padding = { // essentially the bounds to work in... note: the program will not shift the thing up or down, but will assume that the first one is centered
  140f, 400f, 140f, 350f
    //40f, 500f, 40f, 100f
};

float minLabelSpacing = 10f; // the minimum spacing between labels along a spline
float wiggleRoom = 48f; // how much the word can move around instead of being precisely on the x point

// when divding up the splabels into the middlesplines
// float maxSplineHeight = 25f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
float maxSplineHeight = 50f; // when dividing up the splines to generate the middleSplines this is the maximum height allowed
// float splineCurvePointDistance = 10f; // the approx distance between curve points
float splineCurvePointDistance = 30f; // the approx distance between curve points

int[] yearRange = {
  1961, 
  2009
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
String mainDiretoryPath = "C:\\Users\\OCR\\Documents\\GitHub\\NASA\\Data\\BucketGramsAll";
String[] bucketsToUse = {
  //"debug", 
  //"administrative", 
  //"astronaut", 
  // "mars", 
  "moon", 
  "people", 
  //"politics", 
  "research_and_development", 
  //"rockets", 
  "russia", 
  //"satellites", 
  // "space_shuttle", 
  //"spacecraft", 
  "us",
};
HashMap<String, Integer> hexColors = new HashMap<String, Integer>(); // called from setup(), done in AbucketReader


// only these Pos files will be used, others will be skipped
String[] posesToUse = {
  "cd nns", 
  //"cd jj nns", 
  //"dt jj nn",
  "dt jj nns", 
  //"dt nn", 
  "jj nns", 
  "jj vbg nn", 
  "jj vbg nns", 
  "jj vbg", 
  //"vbg nn", 
  "vbg nns",
};

float[][] bucketDataPoints = new float[bucketsToUse.length][0];
boolean reorderBucketsByMaxHeight = true;

//
int bucketDataPointInputMethod = 0; // defined in setup

ArrayList<Bucket> bucketsAL = new ArrayList<Bucket>();
HashMap<String, Bucket> bucketsHM = new HashMap<String, Bucket>();


ArrayList<SpLabel> splabels = new ArrayList<SpLabel>(); // the spline/label objects

float defaultFontSize = 6f; // when it cannot find how big to make a letter.. because the top isnt there, then this is the default
PFont font; // the font that is used

float minLabelHeightThreshold = 4; // minimum height for the middle of the label.  anything less than this will be discounted


// keep track of the used terms so that they only appear once throughout the entire diagram
HashMap<String, Term> usedTerms = new HashMap<String, Term>(); // the ones that were succesfully placed
// keep track of terms used at different x locations
HashMap<Integer, HashMap<String, Integer>> usedTermsAtX = new HashMap<Integer, HashMap<String, Integer>>(); 


// visual controls
boolean facetsOn = false;
boolean splinesOn = true;
boolean variationOn = true;
boolean shiftIsDown = false;

boolean exportNow = false;

//
public void setup() {
  //size(7300, 1200);
  size(2600, 800);
  OCRUtils.begin(this);
  background(255);
  randomSeed(1667);

  font = createFont("Helvetica", defaultFontSize);

  setConstrainRange();

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
  if (addMiddleDivide) splitMiddleSpLabel(middleDivideDistance);

} // end setup

//
public void draw() {

  if(exportNow) {
    beginRecord(PDF, "pdf/nasaColors" + (new Date().getTime()) + ".pdf"); 
    println("starting export to PDF");
  }

  // background(255);
  // background(0);
  background(0xff0F1B30);

  for (SpLabel sp : splabels) {
    fill(sp.c);
    sp.display(g);

    if (splinesOn) sp.displaySplines(g);
    if (facetsOn) sp.displayFacetPoints(g);

    if (variationOn) sp.displayVariationSpline(g);
  }


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
  noLoop();

  if(exportNow) {
    endRecord(); 
    exportNow = false;
    println("ending export to PDF");
  }

} // end draw


//
public void keyPressed() {
  if (keyCode == SHIFT) shiftIsDown = true;
} // end keyPressed


//
public void keyReleased() {  
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

  if (key == 'n') {
    exportNow = true;
  }



  if (key == 'f') facetsOn = !facetsOn;
  if (key == 's') splinesOn = !splinesOn;
  if (key == 'v') variationOn = !variationOn;

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
    repopulateFromFailedHM();
  }

  if (key == SHIFT) {
    shiftIsDown = false;
  }
  loop();
} // end keyReleased


//
public void mouseReleased() {
} // end mouseReleased


//
public String makeRandomPhrase() {
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
public void setConstrainRange() {
  float x1 = getXFromYear(constrainRange[0], blankTerm, g);
  float x2 = getXFromYear(constrainRange[1], blankTerm, g);
  constrainRangeX[0] = x1;
  constrainRangeX[1] = x2;
} // end setConstrainRange

//
public void doPopulate(int toMake) {
  println("in doPopulate.  trying to make: " + toMake);
  long startTime = millis();
  String status = "";
  int positivePlacements = 0;
  int counter = 0;
  int lastPercent = -1;
  for (int j = 0; j < toMake; j++) {
    for (int i = 0; i < bucketsAL.size(); i++) {
      //for (int i = 0; i < 2; i++) {
      Bucket b = bucketsAL.get(i);
      //Bucket b = bucketsAL.get(0);
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

class Bucket {
  String name = "";
  HashMap<String, Pos> posesHM = new HashMap<String, Pos>();
  ArrayList<Pos> posesAL = new ArrayList<Pos>();

  float highCount = 0f;
  float totalSeriesSum = 0; // total from all of the terms within all of the poses
  int totalTermCount = 0; // total terms from all of the poses
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;

  float maxPosSeriesNumber = 0f; // go through and find the max posSeries number


  // keep a specific list of the terms .. from all of the poses
  ArrayList<Term> bucketTermsAL = new ArrayList<Term>();
  HashMap<String, Term> bucketTermsHM = new HashMap<String, Term>();
  ArrayList<Term> bucketTermsRemainingAL = new ArrayList<Term>();


  float[] seriesSum = null;

  int c = color(random(255), random(255), random(255));

  //
  HashMap<String, Term> failedTerms = new HashMap<String, Term>(); // the ones that were not placed
  // when populating, if it cannot be placed it will be placed in this hm.  upon changing the year range this will get reset


  //
  Bucket(String name) {
    this.name = name;
  } // end constructor

  //
  public void addPos(Pos pos) {
    posesHM.put(pos.pos, pos);
    posesAL.add(pos);
  } // end addPos

    //
  public void tallyThings() {
    for (Map.Entry me : posesHM.entrySet()) {
      Pos p = (Pos)me.getValue();
      p.tallyThings();

      if (p.seriesSum != null && p.seriesSum.length > 0) {
        if (seriesSum == null) seriesSum = p.seriesSum;
        else {
          for (int i = 0; i < seriesSum.length; i++) seriesSum[i] += p.seriesSum[i];
        }
      }

      totalSeriesSum += p.totalSeriesSum;
      totalTermCount += p.totalTermCount;
      if (p.totalSeriesSum > highestSeriesCount) {
        highestSeriesCount = p.totalSeriesSum;
        highestSeriesTermString = p.highestSeriesTermString;
        highestSeriesTerm = p.highestSeriesTerm;
      }
    }

    for (float f : seriesSum) maxPosSeriesNumber = (maxPosSeriesNumber > f ? maxPosSeriesNumber : f);
  } // end tallyThings

  //
  public void orderTerms() {
    println("orderTerms for bucket " + name);
    for (Pos p : posesAL) {
      p.orderTerms();
      bucketTermsAL.addAll(p.termsAL);
    }
    bucketTermsAL = OCRUtils.sortObjectArrayListSimple(bucketTermsAL, "seriesSum");
    bucketTermsAL = OCRUtils.reverseArrayList(bucketTermsAL);
    for (Term t : bucketTermsAL) {
      if (!bucketTermsHM.containsKey(t.term)) bucketTermsHM.put(t.term, t);
      else println("bucket " + name + " already has: " + t.term);
      bucketTermsRemainingAL.add(t); // keep a copy
    }
    println(" done.  with " + bucketTermsRemainingAL.size() + " options");
  } // end orderTerms

  //
  public void takeOutTerm(Term t) {
    for (int i = bucketTermsRemainingAL.size() - 1; i >= 0; i--) {
      if (bucketTermsRemainingAL.get(i) == t) bucketTermsRemainingAL.remove(t);
      /*
      else {
       String[] termAr = split(t.term, " ");
       if (bucketTermsRemainingAL.get(i).matchesTermWords(termAr)) {
       bucketTermsRemainingAL.remove(i);
       }
       }
       */
    }
  } // end takeOutTerm

  //
  public String toString() {
    String builder = "BUCKET: " + name + " with " + posesHM.size() + " poses.";
    builder += "\n  totalSeriesSum: " + totalSeriesSum + "  totalTermCount: " + totalTermCount + "  highestSeriesCount: " + highestSeriesCount + "  highestSeriesTermString: " + highestSeriesTermString;
    for (Map.Entry me : posesHM.entrySet()) {
      builder += "\n" + ((Pos)me.getValue()).getString();
    }
    return builder;
  } // end toString
} // end class Bucket

//
//
//
//
//
//
//
//

class Pos {
  String pos = "";

  float totalSeriesSum = 0; // the sum of all the series numbers from these terms
  int totalTermCount = 0; // how many terms there are.. not terms.size(),but using term.totalCount
  float highestSeriesCount = 0; // max count for a term
  String highestSeriesTermString = "";
  Term highestSeriesTerm;

  HashMap<String, Term> termsHM = new HashMap<String, Term>();
  ArrayList<Term> termsAL = new ArrayList<Term>();

  float[] seriesSum = null;

  //
  Pos(String pos) {
    this.pos = pos;
  } // end constructor

  //
  public void addTerm(Term t) {
    termsHM.put(t.term, t);
    termsAL.add(t);
  } // end addWord

  //
  public void tallyThings() {
    for (Map.Entry me : termsHM.entrySet()) {
      Term t = (Term)me.getValue();
      t.tallyThings();

      if (t.series != null && t.series.length > 0) {
        if (seriesSum == null) seriesSum = t.series;
        else {
          for (int i = 0; i < seriesSum.length; i++) seriesSum[i] += t.series[i];
        }
      }

      totalSeriesSum += t.seriesSum;
      totalTermCount += t.totalCount;
      if (t.seriesSum > highestSeriesCount) {
        highestSeriesCount = t.seriesSum;
        highestSeriesTermString = t.term;
        highestSeriesTerm = t;
      }
    }
  } // end tallyThings

  //
  public void orderTerms() {
    for (Term t : termsAL) t.makeSeriesOrder();
    termsAL = OCRUtils.sortObjectArrayListSimple(termsAL, "seriesSum");
    termsAL = OCRUtils.reverseArrayList(termsAL);
  } // end orderTerms

  //
  public String getString() {
    String builder = "   POS: " + pos;
    builder += "\n     totalSeriesSum: " + totalSeriesSum + "  totalTermCount: " + totalTermCount + "  highestSeriesCount: " + highestSeriesCount + "  highestSeriesTermString: " + highestSeriesTermString + "  total terms: " + termsHM.size();
    return builder;
  } // end getString
} // end class Pos

//
//
//
//
//

class Term {
  String term = "";
  String[] theseTermWords = new String[0];
  //String[] posTermWords = new String[0];
  float[] series = null;
  int totalCount = 0;

  float seriesSum = 0f;



  // put the things into order
  int[] seriesOrderedIndices = new int[0];

  //
  Term() {
  } // end blank constructor

  //
  Term(String term, int totalCount, float[] series) {
    this.term = term;
    theseTermWords = split(term, " ");
    //for (String s : theseTermWords) posTermWords = (String[])append(posTermWords, RiTa.getPosTags(s)[0]); // skip for now, not used
    this.totalCount = totalCount;
    this.series = series;
  } // end constructor

  //
  public void tallyThings() {
    for (float f : series) seriesSum += f;
  } // end tallyThings

  //
  // this will fill in the seriesOrderedIndices[] with a descending order of the series numbers
  public void makeSeriesOrder() {
    ArrayList<Integer> tempIndexCount = new ArrayList<Integer>();
    ArrayList<Float> tempSeriesAmt = new ArrayList<Float>();
    for (int i = 0; i < series.length; i++) {
      if (i == 0) {
        tempIndexCount.add(i);
        tempSeriesAmt.add(series[i]);
      }
      else {
        boolean foundSpot = false;
        for (int j = 0; j < tempSeriesAmt.size(); j++) {
          if (series[i] > tempSeriesAmt.get(j)) {
            tempIndexCount.add(j, i);
            tempSeriesAmt.add(j, series[i]);
            foundSpot = true;
            break;
          }
        }
        if (!foundSpot) {
          tempIndexCount.add(i);
          tempSeriesAmt.add(series[i]);
        }
      }
    }
    // transfer to seriesOrderedIndices
    for (Integer i : tempIndexCount) seriesOrderedIndices = (int[])append(seriesOrderedIndices, i);
  } // end makeSeriesOrder

  //
  // try to tell if a word equals this one.  not used
  public boolean matchesTermWords(String[] arIn) {
    //String thisPos = "";
    for (int i = 0; i < theseTermWords.length; i++) {
      //thisPos = posTermWords[i];
      for (String t : arIn) {
        if (t.equals(theseTermWords[i])) return true;
      }
    }
    return false;
  } // end matchesTermWords
  

  //
  public String toString() {
    return "TERM: " + term + " totalCount: " + totalCount + " seriesSum: " + seriesSum;
  } // end toString
} // end class Term

//
//
//
//
//

// 
public void setupHexColors() {
  hexColors.put("debug", 0xffffffff);
  // hexColors.put("administrative", #66ffff);
  // hexColors.put("astronaut", #ff331f);
  hexColors.put("mars", 0xffE15D6D);
  hexColors.put("moon", 0xffE76B36);
  // hexColors.put("people", #f5a3cf);
  // hexColors.put("research_and_development", #aaaa00);
  // hexColors.put("rockets", #ffffff);
  hexColors.put("russia", 0xffE0AE7A);
  // hexColors.put("satellites", #2266aa);
  hexColors.put("space_shuttle", 0xffE0D9C4);
  // hexColors.put("spacecraft", #333333);
  hexColors.put("us", 0xff5EA2B0);
} // end setupHexColors


//
public void readInBucketData() {
  String[] directories = OCRUtils.getDirectoryNames(mainDiretoryPath, false);

  float overallSum = 0f;

  for (String directory : directories) {
    String newBucketName = split(directory, "/")[split(directory, "/").length - 1];

    // check that this is a valid bucket
    boolean isValid = false;
    for (String s : bucketsToUse) if (s.equals(newBucketName)) isValid = true;
    if (!isValid) continue;

    println("bucket: " + newBucketName);

    Bucket newBucket = new Bucket(newBucketName);
    // assign color if it is in the hm
    if (hexColors.containsKey(newBucketName)) newBucket.c = (Integer)hexColors.get(newBucketName); 

    String[] files = OCRUtils.getFileNames(directory, true);
    float yearSum = 0f;
    for (String thisFile : files) {
      String newPosName = split(thisFile, "/")[split(thisFile, "/").length - 1];

      isValid = false;
      for (String s : posesToUse) if (newPosName.contains(s)) isValid = true;
      if (!isValid) continue;

      Pos newPos = new Pos(newPosName);

      String[] allLines = loadStrings(thisFile);
      for (int i = 0; i < allLines.length; i++) {
        String[] broken = split(allLines[i], ",");
        String term = "";
        int termCount = 0;
        float[] breakdown = new float[0];
        for (int j = 0; j < broken.length; j++) {
          if (j == 0) term = broken[j].replace("\"", "").trim(); // take out ""
          else if (j == 1) termCount = Integer.parseInt(broken[j]);
          else {
            breakdown = (float[])append(breakdown, Float.parseFloat(broken[j]));
          }
        }

        // ****** //
        if (term.length() <= 2) continue; // skip if it is 2 or fewer characters
        // ****** //

        Term newTerm = new Term(term, termCount, breakdown);
        newPos.addTerm(newTerm);

        // check and overwrite blankTerm
        if (blankTerm.series == null) blankTerm.series = new float[0];
        if (breakdown.length > blankTerm.series.length) blankTerm.series = breakdown;
      }
      newBucket.addPos(newPos);
    }
    newBucket.tallyThings();
    bucketsAL.add(newBucket);
    bucketsHM.put(newBucketName, newBucket);
  }
} // end readInBucketData


//
//
//
//
//
//






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
  public void assignSplineAndLocation(Spline spline, Spline aboveSpline, Spline belowSpline, float splinePercent) {
    this.spline = spline;
    this.aboveSpline = aboveSpline;
    this.belowSpline = belowSpline;
    this.splinePercent = splinePercent;
  } // end assignSplineAndLocation

  //
  // pass in -1 for letterHeight if the characters will take on the spline height
  public void makeLetters(float letterHeight) {
    letters = new ArrayList<Letter>();
    splinePercent = constrain(splinePercent, 0, 1);
    ArrayList<PVector> newPoint = new ArrayList<PVector>();
    float letterWidth = 0f;
    float totalLength = spline.totalDistance;
    float distanceMarker = splinePercent * totalLength;
    float thinkAheadRotationDistance = .4f; // multiply the letterHt by this to look ahead and find that rotation
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
      if (leftHalf.length() - 1 >= 0) {
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
  public float getLetterHeight(float letterHeightIn, ArrayList<PVector> splineComponents) {
    if (letterHeightIn >= 0) return letterHeightIn;
    else {
      // go find the intersection heights
      float topIntersectionHeight = -1;
      float bottomIntersectionHeight = -1; // skip this for now.. and just assume that it is looking up
      ArrayList<PVector>  intersection = null;
      PVector lineStart = null;
      PVector lineEnd = null;

      // to prevent out of control letter heights, do a sort of sweep
      float sweepingAngle = PI/2; // half of this counter clockwise, half of this clockwise
      float totalSweepCount = 5; // how many pings to sweep on
      float smallestHeight = 0f;

      for (int k = 0; k < totalSweepCount; k++) {
        if (splineComponents.get(0) != null && splineComponents.get(1) != null) {
          lineStart = splineComponents.get(0);
          lineEnd = lineStart.get();
          //lineEnd.add(splineComponents.get(1));

          PVector rotatedEnd = rotateUnitVector(splineComponents.get(1), map(k, 0, totalSweepCount - 1, -sweepingAngle, sweepingAngle), blankLetter); 
          lineEnd.add(rotatedEnd);

          if (aboveSpline != null && lineStart != null && lineEnd != null) {
            intersection = (aboveSpline.getPointByIntersection(lineStart, lineEnd)); 
            //if (intersection != null && intersection.size() != 0) topIntersectionHeight = intersection.get(0).dist(lineStart);
            if (intersection != null) topIntersectionHeight = intersection.get(0).dist(lineStart);
          }

          // if the aboveSpline is null, then use the bottom spline but slightly smaller
          else if (aboveSpline == null && lineStart != null && lineEnd != null) {
            float slightlySmallerFactor = .6f;  
            intersection = (belowSpline.getPointByIntersection(lineStart, lineEnd)); 
            //if (intersection != null && intersection.size() != 0) topIntersectionHeight = intersection.get(0).dist(lineStart) * slightlySmallerFactor;
            if (intersection != null) topIntersectionHeight = intersection.get(0).dist(lineStart) * slightlySmallerFactor;
          }

          /*
        if (belowSpline != null) {
           intersection = (belowSpline.getPointByIntersection(lineStart, lineEnd)).get(0);
           if (intersection != null) bottomIntersectionHeight = intersection.dist(lineStart);
           }
           */

          //println("k: " + k + " topIntersectionHeight: " + topIntersectionHeight);
          if ((topIntersectionHeight > 0 && topIntersectionHeight < smallestHeight) || k == 0) {
            smallestHeight = (topIntersectionHeight > 0 ? topIntersectionHeight : 0);
          }
        }
      }

      // adjust ..
      /*
      if (topIntersectionHeight > 0 && bottomIntersectionHeight == -1) bottomIntersectionHeight = topIntersectionHeight;
       else if (topIntersectionHeight == -1 && bottomIntersectionHeight > 0) topIntersectionHeight = bottomIntersectionHeight;
       else if (topIntersectionHeight == -1 && bottomIntersectionHeight == -1) topIntersectionHeight = bottomIntersectionHeight = defaultFontSize / 2f;
       */
      //if (topIntersectionHeight == -1) topIntersectionHeight = defaultFontSize;
      topIntersectionHeight = smallestHeight;
      //println("              going with height of: " + smallestHeight); 

      // add the two up and make that the resultant size
      //return (topIntersectionHeight + bottomIntersectionHeight) / 2; // DIVIDE BY TWO!!

      // ****** //
      //topIntersectionHeight = 26; // manual override
      // ****** //


      return topIntersectionHeight;
    }
  } // end getLetterHeight

    //
  public PVector rotateUnitVector(PVector a, float angleIn, Letter l) {
    PVector rotated = a.get();
    float currentAngle = l.getAdjustedRotation(rotated);
    currentAngle += angleIn;
    rotated.set(cos(currentAngle), sin(currentAngle));
    return rotated;
  } // end rotateUnitVector


  //
  // this will return the height of the letter closest to the given point.  useful to measure how tall a Label option is at a given point
  public float getApproxLetterHeightAtPoint(PVector ptIn) {
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
  public void display(PGraphics pg) {
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
  Letter() {
  } // end blank constructor

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
  public float getLetterWidth() {
    textFont(font, size);
    return textWidth(letter);
  } // end getLetterWidth

  //
  public float getAdjustedLetterWidth(Letter neighbor) {
    float letterWidth = getLetterWidth();

    float signedAngle = atan2( rotation.x * neighbor.rotation.y - rotation.y* neighbor.rotation.x, rotation.x * neighbor.rotation.x + rotation.y * neighbor.rotation.y );
    float adjustment = constrain(map(signedAngle, -PI/8, PI/8, .75f, 1.5f), .75f, 1.5f);
    return letterWidth * adjustment;
  } // end getAdjustedLetterWidth

  //
  public void display(PGraphics pg) {
    textFont(font, size);
    if (letterAlign == LABEL_ALIGN_RIGHT)  textAlign(RIGHT);
    else if (letterAlign == LABEL_ALIGN_CENTER)  textAlign(CENTER);
    else textAlign(LEFT);

    float rotationToUse = rotationF;

    // this should make it so that the rotation is smoothed out a bit
    if (angleSmoothingOn) {
      PVector newRotation = rotation.get();
      float thisRotationPercent = .9f;
      float otherRotationPercent = .1f;
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

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(rotationToUse);
    text(letter, 0, 0);
    popMatrix();
  } // end display

  //
  public float getAdjustedRotation(PVector rotationIn) {
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

// combination of Spline and Label = SpLabel

class SpLabel {
  String bucketName = "";
  ArrayList<Label> labels = new ArrayList<Label>();
  Spline topSpline = null; // top masterSpline
  Spline bottomSpline = null; // bottom masterSpline
  Spline topNeighborSpline = null; // if there is a SpLabel above it, this will be the first spline above the topSpline
  Spline bottomNeighborSpline = null; // same for the bottom

  Spline variationSpline = null; // this is the one that sort of bounces within the top and bottom splines.  used to distribute the spacing of the middleSplines
  float minimumVariation = .01f; // will not go within this % of the edge
  float variationNumber = .02f; // control the noise variation.. arbitrary, needs testing
  float randomNumber = random(100); // used as a sort of seed
  
  // deal with a middle split
  boolean isMiddleSpLabel = false;
  Spline middleAdjustSpline = null; // if this is the middle spline, then this will be used to calculate the height instead of the top neighbor for the middle spline


  // skipZone and
  HashMap<Integer, Float> skipZones = new HashMap<Integer, Float>(); // ok because the years serve as the mapped x marker.  round to integer
 


  float[] data = new float[0];
  ArrayList<Spline> middleSplines = new ArrayList<Spline>();

  int tempNumericalId = -1;

  // tell whether or not this SpLabel is on the upper or lower half.  true if it is the middle one
  boolean isOnTop = false; 
  boolean isOnBottom = false;

  float maxHeight = 0;  

  int c = color(random(255), random(255), random(255));

  // 
  SpLabel(String bucketName) {
    this.bucketName = bucketName;
  } // end constructor

  //
  public void saveMaxHeight(float h) {
    maxHeight = (maxHeight > h ? maxHeight : h);
  } // end saveMaxHeight

  //
  public void blendSPLabelSplinesByPercent(int count, float splineCPDistance) {
    if (variationSpline == null) middleSplines = blendSplinesByDistance(topSpline, bottomSpline, count, splineCPDistance);
    else middleSplines = blendSplinesByDistanceWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
  } // end blendSPLabelSplinesByPercent

  //
  public void blendSPLabelSplinesVertically(int count, float splineCPDistance) {
    if (variationSpline == null) {
      middleSplines = blendSplinesVertically(topSpline, bottomSpline, count, splineCPDistance);
      println("made middleSplines size of: " + middleSplines.size());
    }
    else {
      middleSplines = blendSplinesVerticallyWithWeight(topSpline, bottomSpline, count, splineCPDistance, variationSpline);
      println("made middleSplines size of: " + middleSplines.size());
    }
  } // end blendSPLabelSplinesVertically 

  //
  // this is the one that wiggles between the top and bottom
  public void makeVariationSpline() {
    variationSpline = new Spline();
    int divisions = 14 * (int)((float)topSpline.totalDistance / (topSpline.curvePoints.size()));
    for (int i = 0; i < divisions; i++) {
      float thisPercent = map(i, 0, divisions - 1, 0, 1);
      PVector pointA = topSpline.getPointAlongSpline(thisPercent).get(0);
      PVector dirA = pointA.get();
      dirA.y += 1; // make it point vertically
      ArrayList<PVector> intersect = bottomSpline.getPointByIntersection(pointA, dirA);
      if ( intersect == null) continue; // cutout if no middle
      PVector pointB = intersect.get(0);

      //float countPercent = map(noise(i * variationNumber + randomNumber), 0, 1, minimumVariation, 1 - minimumVariation); // this is what actually controls the variation
      // for now make it the middle
      float countPercent = .5f;

        PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      variationSpline.addCurvePoint(newPointA);
    }
    variationSpline.makeFacetPoints(topSpline.minAngleInDegrees, topSpline.minDistance, topSpline.divisionAmount, topSpline.flipUp);
  } // end makeVariationSpline


  // TO DO FUNCTIONS
  //
  public Label makeCharLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    return makeLabel(label, textAlign, targetDistance, wiggleRoom, s, false, true);
  } // end makeCharLabel

  //
  // unfinished
  public Label makeStraightLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s) {
    return makeLabel(label, textAlign, targetDistance, wiggleRoom, s, true, false);
  } // end makeStrighLabel 

  //
  private Label makeLabel(String label, int textAlign, float targetDistance, float wiggleRoom, Spline s, boolean straightText, boolean varySize) {
    Label newLabel = new Label(label, textAlign);

    // first determine which splines are above and below the given one
    Spline buddySplineTop = null;
    Spline buddySplineBottom = null;
    if (s == topSpline) {
      buddySplineTop = topNeighborSpline;
      if (middleSplines.size() > 0) buddySplineBottom = middleSplines.get(0);
      else buddySplineBottom = bottomSpline;
    }
    else if (s == bottomSpline) {
      buddySplineBottom = bottomNeighborSpline;
      if (middleSplines.size() > 0) buddySplineTop = middleSplines.get(middleSplines.size() - 1);
      else buddySplineTop = topSpline;
    }
    else {
      for (int i = 0; i < middleSplines.size(); i++) {
        if (middleSplines.get(i) == s) {
          if (i == 0) {
            buddySplineTop = topSpline;
            if (i < middleSplines.size() - 1) buddySplineBottom = middleSplines.get(i + 1);
            else buddySplineBottom = bottomSpline;
          }
          else if (i == middleSplines.size() - 1) {
            buddySplineBottom = bottomSpline;
            if (i > 0) buddySplineTop = middleSplines.get(i - 1);
            else buddySplineTop = topSpline;
          }
          else {
            buddySplineTop = middleSplines.get(i - 1);
            buddySplineBottom = middleSplines.get(i + 1);
          }
          break;
        }
      }
    }

    boolean validLabel = false;
    // then go through and find the maximum or minimum heights to use if !varySize
    if (!varySize) {
    }
    // or do the character assignment if !straightText and varySize
    else {
      newLabel.assignSplineAndLocation(s, buddySplineTop, buddySplineBottom, (targetDistance / s.totalDistance));
      newLabel.makeLetters(-1); // -1 for variable sizing
      validLabel = true;
    }

    //if (validLabel) labels.add(newLabel);
    if (validLabel) return newLabel;
    else return null;
  } // end makeLabel

    //
  public void addLabel(Label labelIn) {
    labels.add(labelIn);
  } // end addLabel


  //
  // this will check whether or not a starting distance and ending distance are free for population
  public boolean spacingIsOpen(Spline targetSpline, float startDistance, float endDistance) {
    if (startDistance < 0) return false;
    if (endDistance > targetSpline.totalDistance) return false;
    for (Label l : labels) {
      if (l.spline == targetSpline) {
        if ((l.startDistance >= startDistance && l.startDistance <= endDistance) || (l.endDistance >= startDistance && l.endDistance <= endDistance)) return false;
        if ((l.startDistance <= startDistance && l.endDistance >= endDistance)) return false;
      }
    } 
    return true;
  } // end spacingIsOpen

  //
  public void markSkipZone(float x, float textWidth) {
    int skipX = (int)x;
    if (skipZones.containsKey(skipX)) {
      Float oldWidth = (Float)skipZones.get(skipX);
      if (textWidth < oldWidth) {
        skipZones.put(skipX, textWidth);
        //println("updated skip zone.  skipZones.size(): " + skipZones.size());
      }
    }
    else {
      skipZones.put(skipX, textWidth);
      //println("marked newskip zone.  skipZones.size(): " + skipZones.size());
    }
  } // end markSkipZone

    //
  public boolean shouldSkip(float x, float textWidth) {
    int skipX = (int)x;
    if (skipZones.containsKey(skipX)) {
      Float oldWidth = (Float)skipZones.get(skipX);
      //println(skipZones);
      if (textWidth >= oldWidth) return true;
    }
    return false;
  } // end shouldSkip


  //
  // try to get the label closest to a distance based on left or right
  public Label getClosestLabel(Spline targetSpline, float targetDistance, boolean rightSide) {
    Label closestLabel = null;
    ArrayList<Label> options = new ArrayList<Label>();
    for (Label l : labels) {
      if (l.spline == targetSpline) {
        if (rightSide) {
          if (l.startDistance > targetDistance) options.add(l);
        }
        else {
          if (l.endDistance < targetDistance) options.add(l);
        }
      }
    }

    if (options.size() == 0) return null;

    float lastClosestDistance = 0f;
    for (int i = 0; i < options.size(); i++) {
      if (i == 0) {
        closestLabel = options.get(i);
        lastClosestDistance = abs((rightSide ? options.get(i).startDistance : options.get(i).endDistance) - targetDistance);
      }
      else {
        float thisDistance = abs((rightSide ? options.get(i).startDistance : options.get(i).endDistance) - targetDistance);
        if (thisDistance < lastClosestDistance) {
          closestLabel = options.get(i);
          lastClosestDistance = thisDistance;
        }
      }
    }
    return closestLabel;
  } // end getClosestLabel

    //
  public void display(PGraphics pg) {
    for (Label l : labels) {
      l.display(pg);
    }
  } // end display

  //
  public void displaySplines(PGraphics pg) {
    pg.noFill();
    pg.stroke(c, 100);
    pg.strokeWeight(2);
    if (isOnTop) topSpline.display(pg);
    if (isOnBottom) bottomSpline.display(pg);
    pg.strokeWeight(1);
    for (Spline s : middleSplines) s.display(pg);

    pg.fill(c);
    pg.textAlign(LEFT);
    pg.textSize(14);
    if (isOnTop) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + topSpline.totalDistance, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).x, topSpline.curvePoints.get(topSpline.curvePoints.size() - 1).y);
    if (isOnBottom) pg.text(bucketName + "-" + data[data.length - 1] + " maxH: " + (int)maxHeight + " id: " + tempNumericalId + " dist: " + bottomSpline.totalDistance, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).x, bottomSpline.curvePoints.get(bottomSpline.curvePoints.size() - 1).y);
  } // end displaySplines

  //
  public void displayVariationSpline(PGraphics pg) {
    pg.noFill();
    pg.stroke(255, 0, 0, 50);
    pg.strokeWeight(1);
    if (variationSpline != null) variationSpline.display(pg);
  } // end displayVariationSpline

  //
  public void displayFacetPoints(PGraphics pg) {
    pg.stroke(0, 50);
    pg.strokeWeight(1);
    if (isOnTop) topSpline.displayFacetPoints(pg);
    if (isOnBottom) bottomSpline.displayFacetPoints(pg);
    for (Spline s : middleSplines) s.displayFacetPoints(pg);
  } // end displayFacetPoints

  //
  public void makeNewLabel() {
  } // end makeNewLabel



    //
  // go through all splines and see what's available?
  // do this by taking adding half the dist to top and half the dist to bottom
  // if no above or below then double the one that does exist
  public float findAvailableHeightForX(float x) {
    float available = defaultFontSize;

    return available;
  } // end findAvailableHeightForX
} // end class SpLabel

//
//
//
//
//
//

class Spline {
  ArrayList<PVector> curvePoints = new ArrayList<PVector>(); // for base curve
  PVector[] facetPoints = new PVector[0]; 
  PVector[] facetUps = new PVector[0]; // which way is 'up' for each facetPoint.  normalized
  PVector[] facetRights = new PVector[0]; // which way is 'right' for each facetPoint.  normalized
  float[] distances = new float[0];
  float[] runningDistances = new float[0];
  float totalDistance = 0f;

  // retain the facet values
  float minAngleInDegrees = 0f;
  float minDistance = 0f; // for when extending the curve, this will be roughly the base distance? 
  // unless there is a facet point closer than this
  int divisionAmount = 1;
  boolean flipUp = false;

  boolean facetsMade = false;

  //
  // in this version the curvepoints will actually not try to double up,
  //  but instead will try to work backwards to establish the 'correct' first and last points
  public void addCurvePoint(PVector p) {
    if (curvePoints.size() == 2) {
      // add first point after two have already been established
      PVector startingPoint = makeExtensionPoint(p, curvePoints.get(1), curvePoints.get(0));
      curvePoints.add(0, startingPoint);
    }
    if (curvePoints.size() > 3) {
      // remove false ending point
      curvePoints.remove(curvePoints.size() - 1);
    }

    curvePoints.add(p);

    if (curvePoints.size() > 2) {
      // add false ending point
      PVector endingPoint = makeExtensionPoint(curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2), p);
      curvePoints.add(endingPoint);
    }
  } // end addCurvePoint


    //
  public PVector makeExtensionPoint(PVector a, PVector b, PVector c) {
    PVector ext = new PVector();
    PVector angleABVec = PVector.sub(b, a);
    PVector angleBCVec = PVector.sub(c, b);
    float signedAngle = atan2( angleABVec.x * angleBCVec.y - angleABVec.y* angleBCVec.x, angleABVec.x * angleBCVec.x + angleABVec.y * angleBCVec.y );

    float angleAB = HALF_PI;
    float angleBC = HALF_PI;
    if (a.x - b.x != 0) angleAB = atan((a.y - b.y) / (a.x - b.x));
    else {
      if (b.y < a.y) angleAB += PI;
    }
    if (b.x - c.x != 0) angleBC = atan((b.y - c.y) / (b.x - c.x));
    else {
      if (c.y < b.y) angleBC += PI;
    }

    angleAB += TWO_PI;
    if (a.x > b.x) angleAB += PI;
    angleAB %= TWO_PI;
    angleBC += TWO_PI;
    if (b.x > c.x) angleBC += PI;
    angleBC %= TWO_PI;

    float newAngle = angleBC + signedAngle;
    float abDist = a.dist(b);
    float bcDist = b.dist(c);
    float newDist = bcDist * .75f + abDist * .25f;
    ext = new PVector(cos(newAngle) * newDist, sin(newAngle) * newDist);
    ext.add(c);

    return ext;
  } // end makeExtensionPoint


    //
  public void makeFacetPoints(float minAngleInDegrees, float minDistance, int divisionAmount, boolean flipUp) {

    this.minAngleInDegrees = minAngleInDegrees;
    this.minDistance = minDistance; 
    this.divisionAmount = divisionAmount;
    this.flipUp = flipUp;
    // simple way ? 
    float minAngleInRadians = ((float)Math.PI * minAngleInDegrees / 180);
    ArrayList<PVector> pts = new ArrayList<PVector>();
    PVector ptA, ptB, ptC, ptD;

    if (curvePoints.size() <= 3) return; // skip out if not enough points  

    // add all of the points so that the facet can be made, 
    // but make sure that the curvePoints.get(0) pt and curvePoints.get(curvePoints.size() - 2) points are marked
    // and then eliminated from the facets
    int startPtsIndex, endPtsIndex;
    startPtsIndex = endPtsIndex = 0;

    pts.add(curvePoints.get(0));
    for (int i = 0; i < curvePoints.size() - 1; i++) {
      if (i == 0) ptA = curvePoints.get(0);
      else ptA = curvePoints.get(i - 1);
      ptB = curvePoints.get(i);
      ptC = curvePoints.get(i + 1);
      if (i == curvePoints.size() - 2) ptD = curvePoints.get(curvePoints.size() - 1);
      else ptD = curvePoints.get(i + 2);
      if (i > 0) pts.add(ptB.get());
      if (i == 1) startPtsIndex = pts.size() - 1;
      if (i == curvePoints.size() - 2) endPtsIndex = pts.size() - 1;
      pts.addAll(divideCurve(divisionAmount, ptA, ptB, ptC, ptD));
    }
    pts.add(curvePoints.get(curvePoints.size() - 1).get());

    facetPoints = new PVector[0];
    facetUps = new PVector[0];
    facetRights = new PVector[0];
    distances = new float[0];
    facetPoints = (PVector[])append(facetPoints, pts.get(0).get());
    distances = (float[])append(distances, 0);
    runningDistances = new float[0];
    totalDistance = 0f;
    PVector lastPoint = pts.get(0).get();
    PVector nextPoint, nextNextPoint;
    PVector dirA, dirB;
    float angleBetween = 0f;
    float dist = 0f;



    // keep track of the start and stop facet indices
    int startFacetIndex, endFacetIndex;
    startFacetIndex = endFacetIndex = 0;

    for (int i = 1; i < pts.size() - 2; i++) {
      nextPoint = pts.get(i);
      nextNextPoint = pts.get(i + 1);
      dirA = PVector.sub(nextPoint, lastPoint);
      dirB = PVector.sub(nextNextPoint, lastPoint);
      angleBetween = PVector.angleBetween(dirA, dirB);
      dist = lastPoint.dist(nextPoint);

      if (dist < minDistance && angleBetween < minAngleInRadians && i != startPtsIndex && i != endPtsIndex) continue;
      else {
        if (abs(i - startPtsIndex) <= 3) startFacetIndex = constrain(facetRights.length - 3, 0, facetRights.length); // some wiggle room
        else if (abs(i - endPtsIndex) <= 3) endFacetIndex = constrain(facetRights.length + 3, 0, facetRights.length);

        PVector right = PVector.sub(nextPoint, lastPoint);
        right.normalize();
        if (i == 1) {
          facetRights = (PVector[])append(facetRights, right);
        }
        facetRights = (PVector[])append(facetRights, right);
        PVector up = new PVector(-right.y, right.x);
        if (flipUp) up.mult(-1);
        if (i == 1) {
          facetUps = (PVector[])append(facetUps, up);
        }
        facetUps = (PVector[])append(facetUps, up);
        distances = (float[])append(distances, lastPoint.dist(nextPoint));
        lastPoint = nextPoint;
        facetPoints = (PVector[])append(facetPoints, nextPoint);
      }
    }
    PVector right = PVector.sub(pts.get(pts.size() - 1), lastPoint);
    right.normalize();

    facetRights = (PVector[])append(facetRights, right);
    facetRights = (PVector[])append(facetRights, right);

    PVector up = new PVector(-right.y, right.x);
    if (flipUp) up.mult(-1);

    facetUps = (PVector[])append(facetUps, up);
    facetUps = (PVector[])append(facetUps, up);

    PVector[] newFacetPoints = new PVector[0];
    PVector[] newFacetRights = new PVector[0]; 
    PVector[] newFacetUps = new PVector[0];
    boolean gotStart = false;
    // a bit messy but it works
    for (int k = constrain(startFacetIndex, 0, facetPoints.length); k <= constrain(endFacetIndex + 3, 0, facetPoints.length - 1); k++) {
      if (!gotStart && facetPoints[k].dist(curvePoints.get(1)) == 0) gotStart = true;
      if (gotStart) {
        newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[k]);
        newFacetRights = (PVector[])append(newFacetRights, facetRights[k]);
        newFacetUps = (PVector[])append(newFacetUps, facetUps[k]);
      }
      //println("facetPoints.length: " + facetPoints.length + " k: " + k + " dist: " + facetPoints[k].dist(curvePoints.get(curvePoints.size() - 2)));
      if (facetPoints[k].dist(curvePoints.get(curvePoints.size() - 2)) == 0) break; // cut out after getting the last point
    }
    facetPoints = newFacetPoints;
    facetRights = newFacetRights;
    facetUps = newFacetUps;

    facetsMade = true;

    makeDistances();
    //println("total distance after makeFacetPoints: " + totalDistance);
  } // end makeFacetPoints

    //
  public void makeDistances() {
    distances = new float[0];
    runningDistances = new float[0];
    totalDistance = 0f;
    int tempCount = 0;
    if (facetPoints.length > 0) {
      for (int i = 1; i < facetPoints.length; i++) {
        if (i == 1) {
          distances = (float[])append(distances, 0f);
          runningDistances = (float[])append(runningDistances, 0f);
        }

        float dist = facetPoints[i].dist(facetPoints[i - 1]);
        if (Float.isNaN(dist)) dist = 0;
        distances = (float[])append(distances, dist);
        runningDistances = (float[])append(runningDistances, dist + runningDistances[runningDistances.length - 1]);
        totalDistance += dist;
        tempCount++;
      }
    }
    //println("end of makeDistances: " + totalDistance + " tempCount: " + tempCount + " runningDistances.length: " + runningDistances.length);
  } // end makeDistancesFromFacets


  //
  public ArrayList<PVector> getPointAlongSpline(float percentIn) {
    ArrayList<PVector> newPoint = new ArrayList<PVector>();
    newPoint.add(new PVector()); // 0 will be the interpolated point
    newPoint.add(new PVector()); // 1 will be the interpolated up
    newPoint.add(new PVector()); // 2 will be the interpolated right
    if (!facetsMade) return newPoint;
    newPoint.clear();

    float targetDistance = percentIn * totalDistance;
    float low, high;
    for (int i = 0; i < runningDistances.length - 1; i++) {
      low = runningDistances[i];
      high = runningDistances[i + 1];
      if (targetDistance == low) {
        newPoint.add(facetPoints[i]);
        newPoint.add(facetUps[i]);
        newPoint.add(facetRights[i]);
        break;
      }
      else if (targetDistance == high) {
        newPoint.add(facetPoints[i + 1]);
        newPoint.add(facetUps[i + 1]);
        newPoint.add(facetRights[i + 1]);
        break;
      }
      else if (targetDistance > low && targetDistance < high) {
        // find the percentage towards low vs high
        // use that to figure the new point, up, and right
        float diff = high - low;
        float percentHigh = (targetDistance - low) / diff;
        float percentLow = 1 - percentHigh;
        PVector a = facetPoints[i].get();
        PVector b = facetPoints[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        PVector c = PVector.add(a, b);
        newPoint.add(c);
        a = facetUps[i].get();
        b = facetUps[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        c = PVector.add(a, b);
        newPoint.add(c);
        a = facetRights[i].get();
        b = facetRights[i + 1].get();
        a.mult(percentLow);
        b.mult(percentHigh);
        c = PVector.add(a, b);
        newPoint.add(c);
        break;
      }
      // otherwise continue
    }

    return newPoint;
  } // end getPointAlongSpline

  //
  public float getPercentByAxis(String axisIn, PVector ptIn) {
    float targetPercent = 0f;
    PVector a, b;
    boolean foundSpot = false;
    float low, high, dist, distA, diff, addition, newDist;
    float percentHigh, percentLow;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      if (axisIn.equals("x")) {
        if (ptIn.x >= a.x && ptIn.x <= b.x) {
          low = runningDistances[i];
          high = runningDistances[i + 1];
          diff = high - low;
          dist = abs(a.x - b.x);
          distA = abs(ptIn.x - a.x);
          addition = diff * distA / dist;
          newDist = low + addition;
          targetPercent = newDist / totalDistance;
          foundSpot = true;
          break;
        }
      }
      else {
        if (ptIn.y >= a.y && ptIn.y <= b.y) {
          low = runningDistances[i];
          high = runningDistances[i + 1];
          diff = high - low;
          dist = abs(a.y - b.y);
          distA = abs(ptIn.y - a.y);
          addition = diff * distA / dist;
          newDist = low + addition;
          targetPercent = newDist / totalDistance;
          foundSpot = true;
          break;
        }
      }
    }
    return targetPercent;
  } // end getPercentByAxis

  //
  public ArrayList<PVector> getPointByAxis(String axisIn, PVector ptIn) {
    float targetPercent = getPercentByAxis(axisIn, ptIn);
    return getPointAlongSpline(targetPercent);
  } // end getPointByAxis

  //
  public ArrayList<PVector> getPointByIntersection(PVector startLine, PVector endLine) {
    float targetPercent = 0f;
    if (!facetsMade) return null;
    // slow and thoughtless but should work
    PVector closestPt = null;
    float thisDist = 0f;
    float closestDist = 0f;
    PVector thisPt, a, b, intersectPoint;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      thisPt = OCR3D.find2DRaySegmentIntersection(startLine, endLine, a, b);
      if (thisPt != null) {
        thisDist = startLine.dist(thisPt); 
        if (thisDist < closestDist || closestPt == null) {
          closestDist = thisDist;
          closestPt = thisPt;
          float distA = thisPt.dist(a);
          float distTotal = a.dist(b);
          float percentA = distA / distTotal;
          float targetDist = runningDistances[i] + percentA * distTotal;
          targetPercent = targetDist / totalDistance;
          thisDist = targetDist; // for debug
        }
      }
    }

    if (closestPt == null) return null;

    if (Float.isNaN(targetPercent)) {
      println("FOUND XXX NAN targetDist: " + thisDist + " totalDistance: " + totalDistance);
      return null;
    }

    //noFill();
    //stroke(255, 0, 255);
    //ellipse(closestPt.x, closestPt.y, 10, 10);

    return getPointAlongSpline(targetPercent);
  } // end getPointByIntersection

  //
  public ArrayList<PVector> getPointByClosestPoint(PVector ptIn) {
    float targetPercent = 0f;
    if (!facetsMade) return null;

    float closestDist = 0f;
    float thisDist = 0f;
    PVector closestPt = new PVector();
    PVector thisPt, a, b, modifiedPt;
    for (int i = 0; i < facetPoints.length - 1; i++) {
      a = facetPoints[i];
      b = facetPoints[i + 1];
      thisPt = OCR3D.findPointLineConnection(ptIn, a, b);
      // check that the pt lies on the line.  if not cap it at the endpoint
      modifiedPt = checkPtSegment(thisPt, a, b);

      thisDist = ptIn.dist(modifiedPt); 
      if (thisDist < closestDist || i == 0) {
        closestDist = thisDist;
        closestPt = modifiedPt;

        float distA = modifiedPt.dist(a);
        float distTotal = a.dist(b);
        float percentA = distA / distTotal;
        float targetDist = runningDistances[i] + percentA * distTotal;
        targetPercent = targetDist / totalDistance;
      }
    }
    return getPointAlongSpline(targetPercent);
  } // end getPointByClosestPoint



    //
  public ArrayList<PVector> getPointByDistance(float distanceIn) {
    float targetPercent = 0f;
    if (!facetsMade) return null;
    targetPercent = distanceIn / totalDistance;
    targetPercent = constrain(targetPercent, 0, 1);
    return getPointAlongSpline(targetPercent);
  } // end getPointByDistance



  //
  // make it so that it caps it to the endpts of the segment
  // terrible amount of calculations
  public PVector checkPtSegment(PVector pt, PVector a, PVector b) {
    boolean awesome = pointIsOnSegment(pt, a, b);
    if (awesome) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255, 0, 0);
    }
    line(a.x, a.y, b.x, b.y);
    ellipse(pt.x, pt.y, 3, 3);

    if (awesome) return pt;
    else {
      float aDist = a.dist(pt);
      float bDist = b.dist(pt);
      if (aDist < bDist) return a;
      else return b;
    }
  } // end checkPtSegment

  //
  public boolean pointIsOnSegment(PVector pt, PVector a, PVector b) {
    if (a.x > b.x) {
      if (pt.x < b.x || pt.x > a.x) return false;
    }
    else {
      if (pt.x < a.x || pt.x > b.x) return false;
    }
    if (a.y > b.y) {
      if (pt.y < b.y || pt.y > a.y) return false;
    }
    else {
      if (pt.y < a.y || pt.y > b.y) return false;
    }
    return true;
  } // end pointIsOnSegment


  //
  // return a segment of the spline
  // note this will create new curvePoints from the facet points
  public Spline getClip(float startPercent, float endPercent) {
    startPercent = constrain(startPercent, 0, 1);
    endPercent = constrain(endPercent, 0, 1);
    if (endPercent < startPercent) {
      float temp = startPercent;
      startPercent = endPercent;
      endPercent = startPercent;
    }
    PVector[] newFacetPoints = new PVector[0];
    PVector[] newFacetUps = new PVector[0];
    PVector[] newFacetRights = new PVector[0];
    // get middle points first
    float targetLow = startPercent * totalDistance;
    float targetHigh = endPercent * totalDistance;
    println("tring to get high from: " + targetHigh + " and low: " + targetLow + " out of totalDist: " + totalDistance);
    float low, high;
    int code = -1;
    int lastCode = -1;
    final int CODE_SURROUNDED = 0;
    final int CODE_START = 1;
    final int CODE_END = 2;
    final int CODE_INSIDE = 3;
    for (int i = 0; i < runningDistances.length - 1; i++) {
      low = runningDistances[i];
      high = runningDistances[i + 1];
      if (targetLow <= low && targetHigh >= high) {
        code = CODE_SURROUNDED;
      }
      else if (targetLow > low && targetHigh >= high) {// check low halfway in bounds
        code = CODE_START;
      }
      else if (targetLow <= low && targetHigh < high) { // check high halfway in bounds
        code = CODE_END;
      }
      else if (true) { // check for both low and high within one segment
        code = CODE_INSIDE;
      }

      // actually do something here
      if (code == CODE_SURROUNDED) {
        if (lastCode == CODE_START) {
          println("STARTING");
          if (i > 0) {
            float lastLow = runningDistances[i - 1];
            float lastHigh = runningDistances[i];
            float lowPercent = (targetLow - lastLow) / (lastHigh - lastLow);
            PVector a = facetPoints[i - 1].get();
            PVector b = facetPoints[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newPos = PVector.add(a, b);
            a = facetUps[i - 1].get();
            b = facetUps[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newUp = PVector.add(a, b);
            a = facetRights[i - 1].get();
            b = facetRights[i].get();
            a.mult(1 - lowPercent);
            b.mult(lowPercent);
            PVector newRight = PVector.add(a, b);
            newFacetPoints = (PVector[])append(newFacetPoints, newPos);
            newFacetUps = (PVector[])append(newFacetUps, newUp);
            newFacetRights = (PVector[])append(newFacetRights, newRight);
          }
        }
        newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[i].get());
        newFacetUps = (PVector[])append(newFacetUps, facetUps[i].get());
        newFacetRights = (PVector[])append(newFacetRights, facetRights[i].get());
        println("SURROUNDED");
      }
      else if (code == CODE_END) {
        if (lastCode == CODE_SURROUNDED) {
          println("ENDING");
          newFacetPoints = (PVector[])append(newFacetPoints, facetPoints[i].get());
          newFacetUps = (PVector[])append(newFacetUps, facetUps[i].get());
          newFacetRights = (PVector[])append(newFacetRights, facetRights[i].get());


          float nextLow = runningDistances[i];
          float nextHigh = runningDistances[i + 1];
          float lowPercent = (targetHigh - nextLow) / (nextHigh - nextLow);
          PVector a = facetPoints[i].get();
          PVector b = facetPoints[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newPos = PVector.add(a, b);
          a = facetUps[i].get();
          b = facetUps[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newUp = PVector.add(a, b);
          a = facetRights[i].get();
          b = facetRights[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newRight = PVector.add(a, b);
          newFacetPoints = (PVector[])append(newFacetPoints, newPos);
          newFacetUps = (PVector[])append(newFacetUps, newUp);
          newFacetRights = (PVector[])append(newFacetRights, newRight);
        }
      }
      else if (code == CODE_INSIDE) {
        println("INSIDE");

        for (int k = 0; k < 2; k++) {
          float thisLow = runningDistances[i];
          float thisHigh = runningDistances[i + 1];
          float lowPercent = ((k == 0 ? targetLow : targetHigh) - thisLow) / (thisHigh - thisLow);
          PVector a = facetPoints[i].get();
          PVector b = facetPoints[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newPos = PVector.add(a, b);
          a = facetUps[i].get();
          b = facetUps[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newUp = PVector.add(a, b);
          a = facetRights[i].get();
          b = facetRights[i + 1].get();
          a.mult(1 - lowPercent);
          b.mult(lowPercent);
          PVector newRight = PVector.add(a, b);
          newFacetPoints = (PVector[])append(newFacetPoints, newPos);
          newFacetUps = (PVector[])append(newFacetUps, newUp);
          newFacetRights = (PVector[])append(newFacetRights, newRight);
        }
        break;
      }
      lastCode = code;
    }

    Spline newSpline = new Spline();
    newSpline.facetPoints = newFacetPoints;
    newSpline.facetUps = newFacetUps;
    newSpline.facetRights = newFacetRights;
    for (PVector p : newSpline.facetPoints) newSpline.addCurvePoint(p.get());

    newSpline.makeDistances();
    newSpline.minAngleInDegrees = minAngleInDegrees;
    newSpline.minDistance = minDistance;
    newSpline.divisionAmount = divisionAmount;
    newSpline.flipUp = flipUp;
    if (newSpline.totalDistance > 0) newSpline.facetsMade = true;

    println(newSpline.totalDistance + " newFacetPoints.length: " + newFacetPoints.length);
    return newSpline;
  } // end getClip

  // 
  public void clipMe(float startPercent, float endPercent) {
    Spline newSpline = getClip(startPercent, endPercent);
    // copy things over
    curvePoints = newSpline.curvePoints;
    facetPoints = newSpline.facetPoints; 
    facetUps = newSpline.facetUps;
    facetRights = newSpline.facetRights;
    distances = newSpline.distances;
    runningDistances = newSpline.runningDistances;
    totalDistance = newSpline.totalDistance;
  } // end clipMe

    //
  // extend the spline if necessary..  for now do a simple curve based on the
  // doesnt quite work yet..... 
  public void extend(float len) {
    if (curvePoints.size() < 3) return; // cut out if not enough points
    println("trying to extend curve by : " + len);
    float eachSideLength = len / 2;
    //makeExtensionPoint
    float oldTotalDistance = totalDistance;
    float targetHalfDistance = oldTotalDistance + eachSideLength;
    float targetFullDistance = oldTotalDistance + len;
    int manualBreak = 0;

    // clean it up a bit first...
    makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);

    // do the end
    while (true) {
      PVector newEnd = makeExtensionPoint(curvePoints.get(curvePoints.size() - 4), curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2));
      ArrayList<PVector> curvePointsCopy = (ArrayList<PVector>)curvePoints.clone();
      curvePoints.clear();
      for (int i = 1; i < curvePointsCopy.size() - 1; i++) addCurvePoint(curvePointsCopy.get(i).get());
      addCurvePoint(newEnd);
      makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);
      //println("distance: " + totalDistance + " target: " + targetHalfDistance * 2);
      if (totalDistance >= targetHalfDistance) break;
      manualBreak++;
      if (manualBreak > 200) break;
    }
    // clip it 
    float targetPercentEnd = (targetHalfDistance) / totalDistance;
    clipMe(0, targetPercentEnd);    


    // do the start 
    while (true) {
      PVector newStart = makeExtensionPoint(curvePoints.get(3), curvePoints.get(2), curvePoints.get(1));
      //PVector newEnd = makeExtensionPoint(curvePoints.get(curvePoints.size() - 4), curvePoints.get(curvePoints.size() - 3), curvePoints.get(curvePoints.size() - 2));
      ArrayList<PVector> curvePointsCopy = (ArrayList<PVector>)curvePoints.clone();
      curvePoints.clear();
      addCurvePoint(newStart);
      for (int i = 1; i < curvePointsCopy.size() - 1; i++) addCurvePoint(curvePointsCopy.get(i).get());
      //addCurvePoint(newEnd);
      makeFacetPoints(minAngleInDegrees, minDistance, divisionAmount, flipUp);
      //println("distance: " + totalDistance + " target: " + targetHalfDistance * 2);
      if (totalDistance >= targetFullDistance) break;
      manualBreak++;
      if (manualBreak > 220) break;
    }
    // clip it 
    float targetPercentStart = (targetFullDistance) / totalDistance;
    clipMe((1 - targetPercentStart), 1);

    if (totalDistance > 0) facetsMade = true;
    println("finishd with extend!  new distance: " + totalDistance + " for target of: " + (targetFullDistance) + " and half: " + targetHalfDistance + " manualBreak: " + manualBreak);
  } // end extend

  //
  // move the thing somewhere else
  public void shift(PVector shift) {
    for (PVector p : curvePoints) p.add(shift);
    for (PVector p : facetPoints) p.add(shift);
  } // end shift

    //
  public void flip() {
    for (PVector p : facetUps) p.mult(-1);
  } // end flip

  // 
  public void reverseDirection() {
    ArrayList<PVector> curvePointsNew = new ArrayList<PVector>(); // for base curve
    PVector[] facetPointsNew = new PVector[0]; 
    PVector[] facetUpsNew = new PVector[0]; // which way is 'up' for each facetPoint.  normalized
    PVector[] facetRightsNew = new PVector[0]; // which way is 'right' for each facetPoint.  normalized
    for (int i = curvePoints.size() - 1; i >= 0; i--) curvePointsNew.add(curvePoints.get(i));
    for (int i = facetPoints.length - 1; i >= 0; i--) {
      facetPointsNew = (PVector[])append(facetPointsNew, facetPoints[i]);
      facetUpsNew = (PVector[])append(facetUpsNew, facetUps[i]);
      facetRightsNew = (PVector[])append(facetRightsNew, facetRights[i]);
    }
    curvePoints = curvePointsNew;
    facetPoints = facetPointsNew;
    facetUps = facetUpsNew;
    facetRights = facetRightsNew;
    makeDistances();
  } // end reverse


  // 
  // pattern defined as 0 for eliminate, 1 for keep
  public void cull(int[] pattern) {
    ArrayList<PVector> newCurvePoints = new ArrayList<PVector>();
    for (int i = 0; i < curvePoints.size(); i++) {
      if (pattern[i % pattern.length] == 1) newCurvePoints.add(curvePoints.get(i));
    }
    if (newCurvePoints.size() >= 2) curvePoints = newCurvePoints;
  } // end cull

  //
  // doesnt really work as expected
  public void multiply(int amt) {
    ArrayList<PVector> newCurvePoints = new ArrayList<PVector>();
    if (amt < 2) return;
    PVector ptA, ptB, ptC, ptD;
    newCurvePoints.add(curvePoints.get(0));
    for (int i = 0; i < curvePoints.size() - 1; i++) {
      if (i == 0) ptA = curvePoints.get(0);
      else ptA = curvePoints.get(i - 1);
      ptB = curvePoints.get(i);
      ptC = curvePoints.get(i + 1);
      if (i == curvePoints.size() - 2) ptD = curvePoints.get(curvePoints.size() - 1);
      else ptD = curvePoints.get(i + 2);
      if (i > 0) newCurvePoints.add(ptB.get());
      newCurvePoints.addAll(divideCurve(amt, ptA, ptB, ptC, ptD));
    }
    newCurvePoints.add(curvePoints.get(curvePoints.size() - 1).get());
    curvePoints = newCurvePoints;
  } // end multiply

  // 
  public ArrayList<PVector> divideCurve(int divisions, PVector ptA, PVector ptB, PVector ptC, PVector ptD) {
    ArrayList<PVector> dividedPoints = new ArrayList<PVector>();
    if (divisions < 2) return dividedPoints;
    float ax, bx, cx, dx, ay, by, cy, dy, t, x, y;
    ax = ptA.x;
    bx = ptB.x;
    cx = ptC.x;
    dx = ptD.x;
    ay = ptA.y;
    by = ptB.y;
    cy = ptC.y;
    dy = ptD.y;
    for (float j = 2; j <= divisions; j++) {
      t = (j - 1f) / divisions;
      x = curvePoint(ax, bx, cx, dx, t);
      y = curvePoint(ay, by, cy, dy, t);
      dividedPoints.add(new PVector(x, y));
    }
    return dividedPoints;
  } // end divideCurve

  //
  public void display(PGraphics pg) {
    pg.beginShape();
    for (int i = 0; i < curvePoints.size(); i++) {
      if (i == 0) pg.curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
      pg.curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
      if (i == curvePoints.size() - 1) pg.curveVertex(curvePoints.get(i).x, curvePoints.get(i).y);
    }
    pg.endShape();
  } // end display

  //
  public void displayCurvePoints(PGraphics pg) {
    float rad = 5;
    for (int i = 0; i < curvePoints.size(); i++) {
      pg.stroke(255, 20);
      pg.noFill();
      pg.ellipse(curvePoints.get(i).x, curvePoints.get(i).y, rad, rad);
      //pg.fill(0);
      //pg.text(i, curvePoints.get(i).x, curvePoints.get(i).y);
    }
  } // end drawPoints

  //
  public void displayFacetPoints(PGraphics pg) {
    float rad = 5;

    for (int i = 0; i < facetPoints.length - 1; i++) {
      pg.line(  facetPoints[i].x, facetPoints[i].y, facetPoints[i + 1].x, facetPoints[i + 1].y);
    }

    for (int i = 0; i < facetPoints.length; i++) {
      pg.stroke(255, 20);
      PVector up = facetUps[i].get();
      up.mult(30);
      up.add(facetPoints[i]);
      pg.line(facetPoints[i].x, facetPoints[i].y, up.x, up.y);
    }
  } // end displayFacetPoints
} // end class Spline


//
//
//
//
//
//




//
public void makeBucketDataPoints(int pointsToMake, int inputType) {
  for (int i = 0; i < bucketDataPoints.length; i++) {
    bucketDataPoints[i] = new float[pointsToMake];
    /*
    float seed = random(100);
     for (int j = 0; j < pointsToMake; j++) {
     bucketDataPoints[i][j] = (100 * noise(j * .1 + seed));
     }
     */
    Bucket targetBucket = bucketsAL.get(i);
    for (int j = 0; j < pointsToMake; j++) {
      if (j < targetBucket.seriesSum.length) {
        switch (inputType) {
        case INPUT_DATA_LINEAR:
          bucketDataPoints[i][j] = targetBucket.seriesSum[j];
          break;
        case INPUT_DATA_HALF:
          bucketDataPoints[i][j] = .5f * (targetBucket.seriesSum[j]);
          break;
        case INPUT_DATA_LOG:
          bucketDataPoints[i][j] = log(targetBucket.seriesSum[j]);
          break;
        case INPUT_DATA_SQUARE:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 2f);
          break;
        case INPUT_DATA_CUBE:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 3f);
          break;
        case INPUT_DATA_SQUARE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 1f/2);
          break;
        case INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(10000 * targetBucket.seriesSum[j], 1f/2);
          break;
        case INPUT_DATA_CUBE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(targetBucket.seriesSum[j], 1f/3);
          break;
        case INPUT_DATA_MULTIPLIED_THEN_CUBE_ROOT:
          bucketDataPoints[i][j] = (float)Math.pow(10000 * targetBucket.seriesSum[j], 1f/3);
          break;
        case INPUT_DATA_DOUBLE:
          bucketDataPoints[i][j] = 2 * (targetBucket.seriesSum[j]);
          break;
        case INPUT_DATA_TRIPLE:
          bucketDataPoints[i][j] = 3 * (targetBucket.seriesSum[j]);
          break;
        case INPUT_DATA_DEBUG:
          bucketDataPoints[i][j] = 13;
          break;
        case INPUT_DATA_NOISE:
          bucketDataPoints[i][j] = 100 * noise(i + j * .1f);
          break;
        }
      }
      else {
        bucketDataPoints[i][j] = 0f;
      }
    }
  }
  println("generated " + bucketDataPoints.length + " new fake buckets of data");
  for (int i = 0; i < bucketDataPoints.length; i++) {
    for (int j = 0; j < bucketDataPoints[i].length; j++) {
      print(nf(bucketDataPoints[i][j], 0, 3) + " ");
    } 
    println("_");
  }
} // end makeBucketDataPoints




//
// this will not only order the terms by highest count to lowest, but will also order their year frequency from most to least so 
//  when placing the terms they can check the first section, then the second, etc. until either a place is found or the yearly frequency is below a given threshold
public void orderBucketTerms() {
  for (Bucket b : bucketsAL) {
    b.orderTerms();
  }
} // end orderBucketTerms 



//
//
//
//
//
//
//



//
//
//
//
//
//

// the different status codes used after trying to place a term
final String POPULATE_STATUS_EMPTY = "emtpy";
final String POPULATE_STATUS_SUCCESS = "success";
final String POPULATE_STATUS_FAIL = "fail";

// the ways in which the bucket data is read in and/or reduced
final int INPUT_DATA_LINEAR = 0; // will take the full bucket value
final int INPUT_DATA_LOG = 1; // log of the bucket value
final int INPUT_DATA_HALF = 2; // half of the bucket value
final int INPUT_DATA_DOUBLE = 3; // double of the bucket value
final int INPUT_DATA_TRIPLE = 4; // triple of the bucket value
final int INPUT_DATA_CUBE = 5; // cube the bucket value
final int INPUT_DATA_SQUARE = 6; // square the data
final int INPUT_DATA_SQUARE_ROOT = 7; // squareroot the data
final int INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT = 111; // 10000 * the value, then squareroot the data
final int INPUT_DATA_CUBE_ROOT = 8; // cuberoot the data
final int INPUT_DATA_MULTIPLIED_THEN_CUBE_ROOT = 9; // 10000 * the value, then cuberoot the data
final int INPUT_DATA_DEBUG = 10; // assign an static number
final int INPUT_DATA_NOISE = 11; // just noise, not data

// the different types of label alignments
final int LABEL_ALIGN_LEFT = 0;
final int LABEL_ALIGN_CENTER = 1;
final int LABEL_ALIGN_RIGHT = 2;

//
//
//
//



//
public String tryToPopulateBucketWithNextTerm(Bucket b, PGraphics pg) {
  Term termToTryToPlace = null;
  String status = null;
  if (b.bucketTermsRemainingAL.size() == 0) return POPULATE_STATUS_EMPTY;
  else {
    termToTryToPlace = b.bucketTermsRemainingAL.get(0);
  }
  boolean didPlace = placeNextTermForBucket(b, termToTryToPlace, pg);
  if (didPlace) {
    //println("placed term: " + termToTryToPlace.term + " for bucket: " + b.name);
    //println("  " + b.name + " has " + b.bucketTermsRemainingAL.size() + " terms left to place");
    usedTerms.put(termToTryToPlace.term, termToTryToPlace);
    status = POPULATE_STATUS_SUCCESS;
  }
  else {
    //println("could not place term: " + termToTryToPlace.term + " .. option bucket.size for " + b.name + ": " + b.bucketTermsRemainingAL.size());
    print("x");
    b.failedTerms.put(termToTryToPlace.term, termToTryToPlace);
    status = POPULATE_STATUS_FAIL;
  }

  // if it got this far then remove this term from all buckets
  if (status.equals(POPULATE_STATUS_SUCCESS)) {
    //println("TAKING OUT TERM: " + termToTryToPlace.term);
    for (Bucket everyB : bucketsAL) {
      //everyB.takeOutTerm(termToTryToPlace);
    }
    b.bucketTermsRemainingAL.remove(termToTryToPlace); // keep it in?
  }
  else if (status.equals(POPULATE_STATUS_FAIL)) {
    b.bucketTermsRemainingAL.remove(termToTryToPlace); // keep it in?
  }
  return status;
} // end tryToPopulateBucketWithNextTerm 



//
public boolean placeNextTermForBucket(Bucket b, Term t, PGraphics pg) {
  boolean didPlace = false;
  SpLabel splabel = null;
  for (SpLabel l : splabels) if (l.bucketName.equals(b.name)) splabel = l;
  if (splabel == null) return false; // cut out if for some reason this bucket is not associated with an splabel 

  //boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {
  // figure out the x

  int seriesTracker = 0; // all iterations
  int seriesTries = 0; // only the iterations where it tried to place it
  int seriesSkipTracker = 0; // the skipped iterations

  textFont(font);
  textSize(defaultFontSize);
  float basicTextSize = textWidth(t.term);

  for (int i = 0; i < t.seriesOrderedIndices.length; i++) {
    float seriesValue = t.series[t.seriesOrderedIndices[i]];
    // skip out if the value is 0;
    if (seriesValue == 0) return false;
    // otherwise try to place it at the appropriate x


    //float x = map(t.seriesOrderedIndices[i], 0, t.series.length - 1, padding[3], pg.width - padding[1]);
    float x = getXFromYear(yearRange[0] + t.seriesOrderedIndices[i], t, pg);

    // check the constrainRangeX
    if (x < constrainRangeX[0] || x > constrainRangeX[1]) continue;

    // check if that term is already at this x location
    if (termIsAlreadyAtX((int)x, t)) continue;


    //println("bucket: " + b.name + " and term: " + t.term);
    //println("t.seriesOrderedIndices[i]: " + t.seriesOrderedIndices[i] + " x: " + x);

    // look for skip option here
    boolean shouldSkip = splabel.shouldSkip(x, basicTextSize);

    //shouldSkip = false;

    if (!shouldSkip) {
      didPlace = populateBiggestSpaceAlongX(x, splabel, t.term, minLabelSpacing, wiggleRoom);
      seriesTries++;
    }
    else {
      seriesSkipTracker++;
    }

    seriesTracker = i;
    if (didPlace) {
      // mark that the term was placed at this x
      markTermAtX((int)x, t);
      break;
    }
    else {
      // try to mark it as a skip location for the splabel

      splabel.markSkipZone(x, basicTextSize);
    }
  }
  //  println("seriesTracker: " + seriesTracker);
  //  println("seriesTries: " + seriesTries);
  //  println("seriesSkipTracker: " + seriesSkipTracker);



  //println("did place  to go to splabel: " + splabel.bucketName);

  return didPlace;
} // end placeNextTermForBucket

//
public void repopulateFromFailedHM() {
  for (Bucket b : bucketsAL) {
    for (Map.Entry me : b.failedTerms.entrySet()) {
      Term failedTerm = (Term)me.getValue();
      b.bucketTermsRemainingAL.add(failedTerm);
    }
    b.failedTerms.clear();
  }
} // end repopulateFromFailedHM 


//
public void populateFullForDebug() {
  //

  for (int j = 0; j < splabels.size(); j++) {
    // top one

    Label newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).topSpline);
    if (newLabel != null) splabels.get(j).addLabel(newLabel);
    while (true) {
      float spacer = minLabelSpacing; // between labels?
      float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
      if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
        newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).topSpline);
        lastEndDistance = newLabel.endDistance;
        if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          break;
        }
        else {
          if (newLabel != null) splabels.get(j).addLabel(newLabel);
        }
      }
    }

    // middle ones
    for (int i = 0; i < splabels.get(j).middleSplines.size(); i++) {
      newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).middleSplines.get(i));
      if (newLabel != null) splabels.get(j).addLabel(newLabel);
      // add more until the last label has an endDistance that is 100% of the distance... 
      while (true) {
        float spacer = minLabelSpacing; // between labels?
        float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
        if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).middleSplines.get(i));
          lastEndDistance = newLabel.endDistance;
          if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
            break;
          }
          else {
            if (newLabel != null) splabels.get(j).addLabel(newLabel);
          }
        }
      }
    }

    // bottom one
    if (j == splabels.size() - 1) {
      newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, random(0, 50), 0f, splabels.get(j).bottomSpline);
      if (newLabel != null) splabels.get(j).addLabel(newLabel);
      while (true) {
        float spacer = minLabelSpacing; // between labels?
        float lastEndDistance = splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).endDistance;
        if (lastEndDistance < splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
          newLabel = splabels.get(j).makeCharLabel(makeRandomPhrase(), LABEL_ALIGN_LEFT, lastEndDistance + spacer, 0f, splabels.get(j).bottomSpline);

          lastEndDistance = newLabel.endDistance;
          if (lastEndDistance >= splabels.get(j).labels.get(splabels.get(j).labels.size() - 1).spline.totalDistance) {
            break;
          }
          else { 
            if (newLabel != null) splabels.get(j).addLabel(newLabel);
          }
        }
      }
    }
  }
} // end populateFullForDebug


/**
 x -- the x location to try to place the text [assume centered?
 splabel -- the label in question
 text -- the String of text to use to make a label
 spacing -- minimum spacing from the rest of the text
 wiggleroom -- how far to deviate in the case that the spot is already taken
 
 returns true if it placed a new label, false otherwise
 */
public boolean populateBiggestSpaceAlongX(float xIn, SpLabel splabel, String text, float spacing, float wiggleRoom) {
  Spline targetSpline = null;
  int textAlign = LABEL_ALIGN_CENTER;


  // ****** scores ****** // 
  Label[] options = new Label[0];
  //float[] optionLetterHeights = new float[0];
  float[] optionScores = new float[0];
  float blankSideMaxValue = 10; // when there is no closest side value this score will be thrown to it


  for (int i = 0; i < splabel.middleSplines.size() + 2; i++) {
    // skip the top one if it is not the top splabel!
    if (i == 0 && splabel.topNeighborSpline != null) continue;

    Spline splineToUse = null;
    if (i == 0) splineToUse = splabel.topSpline;
    else if (i == splabel.middleSplines.size() + 1) splineToUse = splabel.bottomSpline;
    else splineToUse = splabel.middleSplines.get(i - 1);

    // check center, then right, then left
    ArrayList<PVector> intersectionPointAr = splineToUse.getPointByAxis("x", new PVector(xIn, 0));
    if (intersectionPointAr == null || intersectionPointAr.size() == 0) continue;

    PVector intersectionPoint = intersectionPointAr.get(0); 
    float percentPoint = splineToUse.getPercentByAxis("x", new PVector(xIn, 0));
    float distanceToUse = percentPoint * splineToUse.totalDistance;

    Label centerLabel = splabel.makeCharLabel(text, LABEL_ALIGN_CENTER, distanceToUse, wiggleRoom, splineToUse);
    float centerLabelHeight = centerLabel.getApproxLetterHeightAtPoint(intersectionPoint);

    // keep track of the center spacing to use for the wiggle room when finding valid left and right side Labels
    float centerEndDistance = centerLabel.endDistance + spacing;
    float centerStartDistance = centerLabel.startDistance - spacing;

    // verify that center will fit
    boolean centerWillFit = splabel.spacingIsOpen(splineToUse, centerStartDistance, centerEndDistance);

    // get the rightmost side
    Label rightLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse - wiggleRoom, true);
    Label rightSideLabel = null;
    float rightLabelHeight = defaultFontSize;
    boolean rightSideWillFit = false;
    if (rightLabelExisting != null) {
      float rightDistanceToUse = rightLabelExisting.startDistance - spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (rightDistanceToUse < centerEndDistance + wiggleRoom) {
        rightSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_RIGHT, rightDistanceToUse, wiggleRoom, splineToUse);
        rightSideWillFit = splabel.spacingIsOpen(splineToUse, rightSideLabel.startDistance - spacing, rightSideLabel.endDistance);
        rightLabelHeight = rightSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
      }
    }

    // get the leftmost side
    Label leftLabelExisting = splabel.getClosestLabel(splineToUse, distanceToUse + wiggleRoom, false);
    Label leftSideLabel = null;
    float leftLabelHeight = defaultFontSize;
    boolean leftSideWillFit = false;
    if (leftLabelExisting != null) {
      float lefttDistanceToUse = leftLabelExisting.endDistance + spacing;
      // check that the rightDistanceToUse is within the wiggle room
      if (lefttDistanceToUse > centerStartDistance - wiggleRoom) {
        leftSideLabel = splabel.makeCharLabel(text, LABEL_ALIGN_LEFT, lefttDistanceToUse, wiggleRoom, splineToUse);
        leftSideWillFit = splabel.spacingIsOpen(splineToUse, leftSideLabel.startDistance, leftSideLabel.endDistance + spacing);
        leftLabelHeight = leftSideLabel.getApproxLetterHeightAtPoint(intersectionPoint);
      }
    }

    // SCORING
    //if (centerWillFit) splabel.addLabel(centerLabel); // debug
    // center
    if (centerWillFit && centerLabelHeight > minLabelHeightThreshold) {
      options = (Label[])append(options, centerLabel);
      float centerToRightDistance = blankSideMaxValue;
      float centerToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        centerToRightDistance = constrain(map(rightLabelExisting.startDistance - centerLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        centerToLeftDistance = constrain(map(centerLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(centerLabelHeight, centerToLeftDistance, centerToRightDistance));
    }

    // if (rightSideWillFit) splabel.addLabel(rightSideLabel); // debug
    // right
    if (rightSideWillFit && rightSideLabel != null && rightLabelHeight> minLabelHeightThreshold) {
      options = (Label[])append(options, rightSideLabel);
      float rightToRightDistance = blankSideMaxValue;
      float rightToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        rightToRightDistance = constrain(map(rightLabelExisting.startDistance - rightSideLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        rightToLeftDistance = constrain(map(rightSideLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(rightLabelHeight, rightToLeftDistance, rightToRightDistance));
    }

    //if (leftSideWillFit) splabel.addLabel(leftSideLabel); // debug
    // left
    if (leftSideWillFit && leftSideLabel != null && leftLabelHeight > minLabelHeightThreshold) {
      options = (Label[])append(options, leftSideLabel);
      float leftToRightDistance = blankSideMaxValue;
      float leftToLeftDistance = blankSideMaxValue;
      if (rightLabelExisting != null) {
        leftToRightDistance = constrain(map(rightLabelExisting.startDistance - leftSideLabel.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      if (leftLabelExisting != null) {
        leftToLeftDistance = constrain(map(leftSideLabel.startDistance - leftLabelExisting.endDistance, spacing, spacing + wiggleRoom, 0, blankSideMaxValue), 0, blankSideMaxValue);
      }
      optionScores = (float[])append(optionScores, makePopulationScore(leftLabelHeight, leftToLeftDistance, leftToRightDistance));
    }

    // use the one with either the tallest letter size or smallest abs(distance between it and its neighbor
    // determined by the weird makePopulationScore() function
  }


  for (int k = 0; k < optionScores.length; k++) {
    // println(" k: " + k + " -- score: " + optionScores[k]);
  }
  // lastly take the one with the lowest score
  if (optionScores.length <= 0) return false;
  else {
    Label currentFavorite = null;
    float currentLowScore = 0f;
    for (int i = 0; i < optionScores.length; i++) {
      if (i == 0 || optionScores[i] < currentLowScore) {
        currentFavorite = options[i];
        currentLowScore = optionScores[i];
      }
    }

    if (currentFavorite != null) {
      splabel.addLabel(currentFavorite);
    }
    return true;
  }
} // end populateBiggestSpaceAlongX


//
// this will arbitrarily decide a numerical score based on the distance from other labels to the sides and the letter size
// this score is calculated through random guesswork on my part
public float makePopulationScore(float letterHt, float leftSide, float rightSide) {
  float score = 30 * 1 / letterHt;
  score += leftSide;
  score += rightSide;
  return score;
} // end makePopulationScore



//
//
//
//
//
//
//

//
public void makeMasterSpLabels(PGraphics pg) {
  if (bucketDataPoints.length <= 1) return; // needs at least two buckets

  // reorder the buckets by max value?
  if (reorderBucketsByMaxHeight) {
    // reorder the bucket data points and the bucketsAL
    ArrayList<float[]> newBucketDataPointsAL = new ArrayList<float[]>();
    ArrayList<Bucket> newBucketsAL = new ArrayList<Bucket>();
    for (int i = 0; i < bucketsAL.size(); i++) {
      if (i == 0) {
        newBucketsAL.add(bucketsAL.get(i));
        newBucketDataPointsAL.add(bucketDataPoints[i]);
      }
      else {
        float tempSumThis = 0f;
        for (float f : bucketDataPoints[i]) tempSumThis += f;
        boolean foundSpot = false;
        for (int j = 0; j < newBucketsAL.size(); j++) {
          float tempSumOther = 0f;
          float[] otherDataPt = newBucketDataPointsAL.get(j);
          for (float f : otherDataPt) tempSumOther += f;
          if (tempSumThis > tempSumOther) {
            newBucketsAL.add(j, bucketsAL.get(i));
            newBucketDataPointsAL.add(j, bucketDataPoints[i]);
            foundSpot = true;
            break;
          }
        }
        if (!foundSpot) {
          newBucketsAL.add(bucketsAL.get(i));
          newBucketDataPointsAL.add(bucketDataPoints[i]);
        }
      }
    }
    bucketDataPoints = new float[newBucketDataPointsAL.size()][0];
    bucketsAL = newBucketsAL;
    for (int i = 0; i < newBucketDataPointsAL.size(); i++) {
      bucketDataPoints[i] = newBucketDataPointsAL.get(i);
    }
  }

  // first find the max sum of data assuming they all have same number of points
  float maxDataSum = 0;
  float middleHeight = 0;
  float heightPerUnit = 0;
  float widthPerDataPoint = 0;
  for (int j = 0; j < bucketDataPoints[0].length; j++) {
    float thisSum = 0;
    for (int i = 0; i < bucketDataPoints.length; i++) {
      thisSum += bucketDataPoints[i][j];
    }
    maxDataSum = (maxDataSum > thisSum ? maxDataSum : thisSum);
  }
  if (maxDataSum <= 1) return;
  heightPerUnit = (pg.height - padding[0] - padding[2]) / (maxDataSum - 1);
  widthPerDataPoint = (pg.width - padding[1] - padding[3]) / (bucketDataPoints[0].length - 1);
  middleHeight = padding[0] + (pg.height - padding[0] - padding[2]) / 2;
  println("maxDataSum: " + maxDataSum + " heightPerUnit: " + heightPerUnit + " widthPerDataPoint: " + widthPerDataPoint);

  // make the actual splines
  ArrayList<SpLabel> topSpLabels = new ArrayList<SpLabel>();
  ArrayList<SpLabel> bottomSpLabels = new ArrayList<SpLabel>();

  for (int i = 0; i < bucketDataPoints.length; i++) {
    Bucket targetBucket = bucketsAL.get(i);
    SpLabel sp = new SpLabel(targetBucket.name);
    sp.c = targetBucket.c; // assign the bucket color to the splabel
    float x = padding[3];
    float y = 0f;
    if (i == 0) {
      Spline top = new Spline();
      Spline bottom = new Spline();
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        y = -((float)bucketDataPoints[i][j] / 2) * heightPerUnit + middleHeight;
        top.addCurvePoint(new PVector(x, y));
        y = ((float)bucketDataPoints[i][j] / 2) * heightPerUnit + middleHeight;
        bottom.addCurvePoint(new PVector(x, y));
        sp.saveMaxHeight(2 * abs(y - middleHeight));
        x += widthPerDataPoint;
      }      

      top.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);
      bottom.makeFacetPoints(splineMinAngleInDegrees, splineMinDistance, splineDivisionAmount, splineFlipUp);

      sp.topSpline = top;
      sp.bottomSpline = bottom;
      sp.isOnTop = true;
      sp.isOnBottom = true;
      sp.data = bucketDataPoints[i];
      
      // mark this one as the middle one in case the divide is employed later
      sp.isMiddleSpLabel = true;
    }
    else {
      // determine if should go up or down based on the min/max
      float topMax = 0f;
      float bottomMax = 0f;
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        float thisSum = 0;
        thisSum += bucketDataPoints[i][j];
        for (SpLabel sp2 : topSpLabels) {
          thisSum += sp2.data[j];
        }
        topMax = (topMax > thisSum ? topMax : thisSum);
      }
      for (int j = 0; j < bucketDataPoints[i].length; j++) {
        float thisSum = 0;
        thisSum += bucketDataPoints[i][j];
        for (SpLabel sp2 : bottomSpLabels) {
          thisSum += sp2.data[j];
        }
        bottomMax = (bottomMax > thisSum ? bottomMax : thisSum);
      }

      if (topMax > bottomMax) {
        //println("doing bottom");
        Spline top = bottomSpLabels.get(bottomSpLabels.size() - 1).bottomSpline;
        Spline bottom = new Spline();
        for (int j = 0; j < bucketDataPoints[i].length; j++) {
          float previousYPosition = top.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = ((float)bucketDataPoints[i][j]) * heightPerUnit + previousYPosition;
          bottom.addCurvePoint(new PVector(x, y));
          sp.saveMaxHeight(abs(y - previousYPosition));
          x += widthPerDataPoint;
        }      
        bottom.makeFacetPoints(.15f, 10f, 120, true);
        sp.topSpline = top;
        sp.bottomSpline = bottom;
        sp.isOnTop = false;
        sp.isOnBottom = true;
      }
      else {
        //println("doing top");
        Spline top = new Spline();
        Spline bottom = topSpLabels.get(topSpLabels.size() - 1).topSpline;
        for (int j = 0; j < bucketDataPoints[i].length; j++) {
          float previousYPosition = bottom.getPointByAxis("x", new PVector(x, 0)).get(0).y;
          y = -((float)bucketDataPoints[i][j]) * heightPerUnit + previousYPosition;
          top.addCurvePoint(new PVector(x, y));
          sp.saveMaxHeight(abs(y - previousYPosition));
          x += widthPerDataPoint;
        }      
        top.makeFacetPoints(.15f, 10f, 120, true);
        sp.topSpline = top;
        sp.bottomSpline = bottom;
        sp.isOnTop = true;
        sp.isOnBottom = false;
      }
    }
    sp.data = bucketDataPoints[i];
    //splabels.add(sp);
    if (sp.isOnBottom) bottomSpLabels.add(sp);
    if (sp.isOnTop) topSpLabels.add(sp);
  }
  splabels = orderSpLabels(topSpLabels, bottomSpLabels);
} // end makeMasterSplines



//
public ArrayList<Spline> blendSplinesByDistanceWithWeight(Spline a, Spline b, int totalCount, float distance, Spline weightSpline) {

  int divisionPoints = (int)(a.totalDistance / distance + 1);

  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());

  // these numbers are not exact.. the larger the maximumPercent the [slightly] larger the difference
  float minimumPercent = .1f; // for when the distance from point to line is equal to the distance from a to b
  float maximumPercent = 5.93f; // when a line is on top of the variation line.  

  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector pointB = b.getPointAlongSpline(thisPercent).get(0);
    PVector weightedSplinePoint = null;
    ArrayList<PVector> intersectionPoint = weightSpline.getPointByIntersection(pointA, pointB);

    if (intersectionPoint != null) weightedSplinePoint = intersectionPoint.get(0);
    else {
      weightedSplinePoint = pointA.get();
      weightedSplinePoint.add(pointB.get());
      weightedSplinePoint.div(2);
    } 

    float[] distances = new float[totalCount + 2]; // +2 for the first and last distances
    float distancesSum = 0f; // sum of the distances[]
    float abDist = pointA.dist(pointB);

    float minDistance = minimumPercent * abDist; // minimum distance for a weighted spline
    float maxDistance = maximumPercent * abDist; // max distance 


    for (int j = 0; j <= totalCount + 1; j++) {
      if (j == 0) {
        float distToWeightedPoint = pointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else if (j >= 1 && j <= totalCount) {
        float countPercent = map(j, 0, totalCount + 1, 0, 1);
        PVector newPointA = pointA.get();
        newPointA.mult(1 - countPercent);
        PVector newPointB = pointB.get();
        newPointB.mult(countPercent);
        newPointA.add(newPointB); // this is where the thing would be normally
        float distToWeightedPoint = newPointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else {
        /*
        float distToWeightedPoint = pointB.dist(weightedSplinePoint);
         distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
         distToWeightedPoint = 5;
         distances[j] = distToWeightedPoint;
         distancesSum += distToWeightedPoint;
         */
      }
    }

    float runningSum = 0f; //distances[0];
    for (int j = 1; j <= totalCount; j++) {
      runningSum += distances[j];
      float countPercent = runningSum / distancesSum;
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }

  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);

  return newSplines;
} // end blendSplinesByDistanceWithWeight


//
public ArrayList<Spline> blendSplinesByDistance(Spline a, Spline b, int totalCount, float distance) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);
  return blendSplinesByDivisionPoints(a, b, totalCount, divisionPoints);
} // end blendSplinesByDistance

//
/**
 This will use two existing splines to generate a series of new splines
 minimum divisionPoints as 3
 minimum totalCount as 1
 */
public ArrayList<Spline> blendSplinesByDivisionPoints(Spline a, Spline b, int totalCount, int divisionPoints) {
  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());
  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector pointB = b.getPointAlongSpline(thisPercent).get(0);
    for (int j = 1; j <= totalCount; j++) {
      float countPercent = map(j, 0, totalCount + 1, 0, 1);
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  } 
  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
  return newSplines;
} // end blendSplines



//
public ArrayList<Spline> blendSplinesVertically(Spline a, Spline b, int totalCount, float distance) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  // assume a is the main divisor
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());
  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);
    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector dirA = pointA.get();
    dirA.y += 1; // make it point vertically
    ArrayList<PVector> intersect = b.getPointByIntersection(pointA, dirA);
    if ( intersect == null) continue; // cutout if no middle
    PVector pointB = intersect.get(0);
    for (int j = 1; j <= totalCount; j++) {
      float countPercent = map(j, 0, totalCount + 1, 0, 1);
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }
  for (Spline s : newSplines) s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
  return newSplines;
} // end blendSplinesVertically 

//
public ArrayList<Spline> blendSplinesVerticallyWithWeight(Spline a, Spline b, int totalCount, float distance, Spline weightSpline) {
  int divisionPoints = (int)(a.totalDistance / distance + 1);

  if (divisionPoints < 3 || totalCount < 1) return null;
  ArrayList<Spline> newSplines = new ArrayList<Spline>();
  for (int i = 0; i < totalCount; i++) newSplines.add(new Spline());

  // these numbers are not exact.. the larger the maximumPercent the [slightly] larger the difference
  float minimumPercent = .1f; // for when the distance from point to line is equal to the distance from a to b
  float maximumPercent = 5.93f; // when a line is on top of the variation line.  

  for (int i = 1; i <= divisionPoints; i++) {
    float thisPercent = map(i, 1, divisionPoints, 0, 1);

    PVector pointA = a.getPointAlongSpline(thisPercent).get(0);
    PVector dirA = pointA.get();
    dirA.y += 1; // make it point vertically
    ArrayList<PVector> intersect = b.getPointByIntersection(pointA, dirA);
    if ( intersect == null) continue; // cutout if no middle
    PVector pointB = intersect.get(0);

    PVector weightedSplinePoint = null;
    ArrayList<PVector> intersectionPoint = weightSpline.getPointByIntersection(pointA, pointB);

    if (intersectionPoint != null) weightedSplinePoint = intersectionPoint.get(0);
    else {
      weightedSplinePoint = pointA.get();
      weightedSplinePoint.add(pointB.get());
      weightedSplinePoint.div(2);
    } 

    float[] distances = new float[totalCount + 2]; // +2 for the first and last distances
    float distancesSum = 0f; // sum of the distances[]
    float abDist = pointA.dist(pointB);

    float minDistance = minimumPercent * abDist; // minimum distance for a weighted spline
    float maxDistance = maximumPercent * abDist; // max distance 


    for (int j = 0; j <= totalCount + 1; j++) {
      if (j == 0) {
        float distToWeightedPoint = pointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else if (j >= 1 && j <= totalCount) {
        float countPercent = map(j, 0, totalCount + 1, 0, 1);
        PVector newPointA = pointA.get();
        newPointA.mult(1 - countPercent);
        PVector newPointB = pointB.get();
        newPointB.mult(countPercent);
        newPointA.add(newPointB); // this is where the thing would be normally
        float distToWeightedPoint = newPointA.dist(weightedSplinePoint);
        //distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
        distToWeightedPoint = map(sqrt(distToWeightedPoint), 0, sqrt(abDist), maxDistance, minDistance);
        //distToWeightedPoint = 5;
        //distToWeightedPoint = 1 + (totalCount - j);
        distances[j] = distToWeightedPoint;
        distancesSum += distToWeightedPoint;
      }
      else {
        /*
        float distToWeightedPoint = pointB.dist(weightedSplinePoint);
         distToWeightedPoint = map(distToWeightedPoint, 0, abDist, maxDistance, minDistance);
         distToWeightedPoint = 5;
         distances[j] = distToWeightedPoint;
         distancesSum += distToWeightedPoint;
         */
      }
    }

    float runningSum = 0f; //distances[0];
    for (int j = 1; j <= totalCount; j++) {
      runningSum += distances[j];
      float countPercent = runningSum / distancesSum;
      PVector newPointA = pointA.get();
      newPointA.mult(1 - countPercent);
      PVector newPointB = pointB.get();
      newPointB.mult(countPercent);
      newPointA.add(newPointB);
      newSplines.get(j - 1).addCurvePoint(newPointA);
    }
  }

  for (Spline s : newSplines) {
    s.makeFacetPoints(a.minAngleInDegrees, a.minDistance, a.divisionAmount, a.flipUp);
    //println("new spline dist: " + s.totalDistance);
  }
  return newSplines;
} // end blendSplinesVerticallyWithWeight





//
//
//
//
//
//




//
// this will simply order the splabels by y
public ArrayList<SpLabel> orderSpLabels(ArrayList<SpLabel> topList, ArrayList<SpLabel> bottomList) {
  ArrayList<SpLabel> ordered = new ArrayList<SpLabel>();
  for (int i = topList.size() - 1; i >= 0; i--) ordered.add(topList.get(i));
  for (int i = 0; i < bottomList.size(); i++) {
    if (!ordered.contains(bottomList.get(i))) {
      ordered.add(bottomList.get(i));
    }
  }

  for (int i = 0; i < ordered.size(); i++) ordered.get(i).tempNumericalId = i;
  return ordered;
} // end orderSpLabels

//
public void makeVariationSplines() {
  for (SpLabel sp : splabels) {
    sp.makeVariationSpline();
  }
} // endmakeVariationSplines


//
public void splitMasterSpLabelsByPercent(float maxLineHeight, float splineCPDistance) {
  println("in splitMasterSpLabelsByPercent");
  for (SpLabel sp : splabels) {
    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    sp.blendSPLabelSplinesByPercent(dividingNumber, splineCPDistance);
  }
} // end splitMasterSpLabelsByPercent

//
public void splitMasterSpLabelsVertically(float maxLineHeight, float splineCPDistance) {
  println("in splitMasterSpLabelsVertical");
  for (SpLabel sp : splabels) {
    int dividingNumber = ceil(sp.maxHeight / maxLineHeight);
    sp.blendSPLabelSplinesVertically(dividingNumber, splineCPDistance);
  }
} // end splitMasterSpLabelsVertical

//
public void assignSpLabelNeighbors() {
  for (int i = 0; i < splabels.size(); i++) {
    if (i > 0) {
      if (splabels.get(i - 1).middleSplines.size() > 0) splabels.get(i).topNeighborSpline = splabels.get(i - 1).middleSplines.get(splabels.get(i - 1).middleSplines.size() - 1);
      else {
        if (splabels.get(i - 1).topSpline != null) splabels.get(i).bottomNeighborSpline = splabels.get(i - 1).topSpline;
      }
    }
    if (i < splabels.size() - 1) {
      if (splabels.get(i + 1).middleSplines.size() > 0) splabels.get(i).bottomNeighborSpline = splabels.get(i + 1).middleSplines.get(0);
      else {
        if (splabels.get(i + 1).bottomSpline != null) splabels.get(i).bottomNeighborSpline = splabels.get(i + 1).bottomSpline;
      }
    }
  }
} // end assignSpLabelNeighbors

//
public void splitMiddleSpLabel(float divideAmount) {
  PVector shiftVector = new PVector(0, -divideAmount);

  // define the middle splabel
  // shift all splabels above this one up by the divideAmount
  // shift all middle splines of the middle splabel up by the divide amount
  // generate a new middle spline for the middle splabel for the text to be measured against for height
  SpLabel middleSpLabel = null;
  for (SpLabel sp : splabels) {
    if (sp.isMiddleSpLabel) {
      middleSpLabel = sp;
      break;
    }
  }

  // grab the top splabels
  ArrayList<SpLabel> topLabels = new ArrayList<SpLabel>();
  if (middleSpLabel != null) {
    for (SpLabel sp : splabels) { 
      if (sp != middleSpLabel && sp.isOnTop) {
        topLabels.add(sp);
      }
    }
  }
  // shift top spLabels by amt
  for (SpLabel sp : topLabels) {
    sp.topSpline.shift(shiftVector);
    for (Spline spline : sp.middleSplines) {
      spline.shift(shiftVector);
    }
    if (sp.variationSpline != null) sp.variationSpline.shift(shiftVector);
  }
} // end splitMiddleSpLabel


//
public float getXFromYear(int yearIn, Term t, PGraphics pg) {
  float x = map(yearIn, yearRange[0], yearRange[1], padding[3], pg.width - padding[1]); 
  return x;
} // end getXFromYear


// mark the x locations of phrases
public boolean termIsAlreadyAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) return false;
  else {
    HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
    if (oldHM.containsKey(t.term)) return true;
    else return false;
  }
} // end termIsAlreadyAtX

//
public void markTermAtX(int x, Term t) {
  if (!usedTermsAtX.containsKey(x)) usedTermsAtX.put(x, new HashMap<String, Integer>());
  HashMap<String, Integer> oldHM = (HashMap<String, Integer>) usedTermsAtX.get(x);
  oldHM.put(t.term, 0);
  usedTermsAtX.put(x, oldHM);
} // end markTermAtX

//
//
//
//
//
//
//

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TypeAlongCurveColors" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

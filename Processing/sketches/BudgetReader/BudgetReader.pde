import processing.pdf.*;

//String budgetFile = "../../../Data/NASAbudget.csv";
String budgetFile = "revisedData/nasa_numbers.csv";


boolean exportToPDF = false;

int[] yearRange = {
  1958, 2012
};

float maxDollars = 0f;
float maxPercent = 0f;

ArrayList<Year> years = new ArrayList<Year>();

int[] markerYears = {
  1958, 
  1961, 
  2008, 
  2009
};

//
void setup() {
  size(1200, 600);
  //size(1809, 543);
  String[] allLines = loadStrings(budgetFile);
  for (int i = 1; i < allLines.length; i++) {
    //String[] broken = split(allLines[i], ";");
    String[] broken = split(allLines[i], ",");
    //println(broken);
    try {
      println(allLines[i]);
      int year = Integer.parseInt(broken[0].replace("\"", "").replace(",", "").trim());
      if (year < yearRange[0]) continue;
      //float dollars = Float.parseFloat(broken[3].replace("\"", "").replace(",", "").trim());
      float dollars = Float.parseFloat(broken[1].replace("\"", "").replace(",", "").trim());
      //float percentFedBudget = Float.parseFloat(broken[2].replace("\"", "").replace("%", "").replace(",", "").trim());
      //Year yr = new Year(year, dollars, percentFedBudget);
      Year yr = new Year(year, dollars, .5);
      years.add(yr);
      maxDollars = (maxDollars > dollars ? maxDollars : dollars);
      //maxPercent = (maxPercent > percentFedBudget ? maxPercent : percentFedBudget);
      maxPercent = .5;
      if (year >= yearRange[1]) {
        break;
      }
    }
    catch (Exception e) {
    }
  }
  for (Year yr : years) {
    println(yr.year + " - " + yr.dollars + " - " + yr.percentFedBudget);
  }
  println(maxDollars);
  println(maxPercent);
} // end setup


void draw() {

  if (exportToPDF) {
    beginRecord(PDF, "pdf/budgetNew.pdf");
    println("starting export");
  }
  background(255);

  fill(0);
  //text(frameCount, 20, 20);
  //text("max $: " + maxDollars, 20, 40);
  //text("max %: " + maxPercent, 20, 60);


float yPadding = 40f;

  // draw grid
  int step = 0;
  stroke(0);
  line(0, height/2, width, height/2);
  for (int yr = yearRange[0]; yr <= yearRange[1]; yr++) {
    boolean shouldInclude = false;
    if (yr % 5 == 0) shouldInclude = true;
    for (int y : markerYears) if (y == yr) shouldInclude = true;
    if (shouldInclude) {
      stroke(0, 40);
      line(getXFromYear(yr), 0, getXFromYear(yr), height);
      textAlign(CENTER, TOP);
      text(yr, getXFromYear(yr), 20 + 20 * (step % 3));
      step++;
    }
  }

  for (float dollar = 35000; dollar >= 0; dollar -= 5000) {
    float y = map(dollar, 0, maxDollars, height/2, yPadding);
    line(0, y, width, y);
    textAlign(LEFT, CENTER);
    text("$" + nfc(dollar, 0), 20, y);
  }
  for (float percent = 5; percent >= 0; percent -= .5) {
    float y = map(percent, 0, maxPercent, height/2, height - yPadding);
    line(0, y, width, y);
    textAlign(LEFT, CENTER);
    text(percent + "%", 20, y);
  }

  // draw dollars
  
  stroke(0, 255, 0);
  noFill();
  beginShape();
  for (int i = 0; i < years.size(); i++) {
    float y = map(years.get(i).dollars, 0, maxDollars, height/2, yPadding);
    float x = getXFromYear(years.get(i).year);
    if (i == 0) curveVertex(x, y);
    curveVertex(x, y);
    if (i == years.size() - 1) curveVertex(x, y);
  }
  endShape();

  // draw percent
  stroke(0, 127, 255);
  noFill();
  beginShape();
  for (int i = 0; i < years.size(); i++) {
    float y = map(years.get(i).percentFedBudget, 0, maxPercent, height/2, height - yPadding);
    float x = getXFromYear(years.get(i).year);
    if (i == 0) curveVertex(x, y);
    curveVertex(x, y);
    if (i == years.size() - 1) curveVertex(x, y);
  }
  endShape();

  if (exportToPDF) {
    endRecord(); 
    exportToPDF = false;
    println("done exporting");
  }
} // end draw

//
float getXFromYear(int yearIn) {
  float xLeftPadding = 130f;
  float xRightPadding = 30f;
  return map(yearIn, yearRange[0], yearRange[1], xLeftPadding, width - xRightPadding);
} // end getXFromYear 

//
void keyReleased() {
  if (key == ' ') {
    exportToPDF = true;
  }
} // end keyReleased

//
//
//
//
//


ArrayList<Gram> grams = new ArrayList<Gram>();

// graph vars
int lowYear = 1850;
int highYear = 2014;
int minCount = 0;
int maxCount = 0;

// curves
boolean curvesOn = true;

//
void setup() {
  OCRUtils.begin(this);
  background(360);
  colorMode(HSB, 360);
  size(900, 500);
  textFont(createFont("Helvetica", 12));
  loadGrams();
  // find maxCount
  for (Gram g : grams) for(Integer i : g.counts) maxCount = (maxCount > i ? maxCount : i);
  println("maxCount as: " + maxCount);
  
  makeGraphPoints(g);
  applyLabels(g);
} // end setup

//
void draw() {
  background(360);
  graphGrams(g, new PVector(mouseX, mouseY));
} // end draw


//
void keyReleased() {
  if (key == 'c') {
   curvesOn = !curvesOn; 
  }
  if (key == ' ') {
   saveFrame("output/####.png"); 
  }
} // end keyReleased
//
//
//
//
//
//


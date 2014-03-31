ArrayList<Word> words = new ArrayList();
PFont label;

int startYear = 1961;
int endYear = 2009;

float minCount = 0;
float maxCount = 0;

int thresh = 3;

String pattern = "";

String dataPath = "../../Data/gramsFloat/";

void setup() {
  size(4480, 1400);
  label = createFont("Helvetica", 100);
  textFont(label);
  
  loadMap("vbg_series.txt");
  //loadMap("dt jj nns_series.txt");
  //loadMap("dt jj nn_series.txt");
  //loadMap("cd nns_series.txt");
  //loadMap("vbg nn_series.txt");
  //loadMap("vbg nns_series.txt");
  //loadMap("jj vbg nns_series.txt");
  //loadMap("dt jj vbg_series.txt");
  //loadMap("jj vbg_series.txt");
  
  positionWords();
  
  thresh = 0;
  //loadMap("3year_grams.txt");
}

void draw() {
  background(0);
  //Years
  
  colorMode(HSB);
  for (int i= startYear; i <= endYear; i++) {
    float x = map(i, startYear, endYear, 100, width - 100); 
    float c = map(i, startYear, endYear, 0, 200);
    stroke(c,255,255, 50);
    line(x, 0, x, height);
    textSize(18);
    fill(c,255,255,150);
    pushMatrix();
      translate(x,0);
      rotate(PI/2);
      text(i, 25, 0);
    popMatrix();
  }
  for (Word w:words) {
    w.update();
    w.render();
  }
}

void loadMap(String url) {
  pattern = split(url, ".")[0];
  String[] rows = loadStrings(dataPath + url);
  for (String r:rows) {
    String[] cols = split(r, ",");
    Word w = new Word();
    w.w = cols[0];
    w.count = float(cols[1]);
    maxCount = max(w.count, maxCount);
    
    //calculate weighted average
    float t = 0;
    float c = 0;
    for (int i = 2; i < cols.length; i++) {
        float f = float(cols[i]);
          t += f * (i - 1);
          c += f;  
    }

    float wa = t / c;

    w.pos.set(map(wa - 1, 2, cols.length, 100, width-100), random(50, height-50));
    if (w.count > thresh) words.add(w);
  }
  
  
}

void positionWords() {
  for (Word w:words) {
   w.wsize = map(w.count, minCount, maxCount, 8,48); 
   w.a = map(w.count, minCount, maxCount, 100,255);
  }
}

void keyPressed() {
  if (key == 's') save("../../ProgressImages/NASAwords_" + pattern + "_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
}


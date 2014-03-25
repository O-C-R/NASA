ArrayList<Word> words = new ArrayList();
PFont label;

int startYear = 1961;
int endYear = 1977;

void setup() {
  size(2480, 720);
  label = createFont("Helvetica", 100);
  textFont(label);
  loadMap("jj nns_series.txt");
  loadMap("dt jj nn_series.txt");
  loadMap("cd jj nns_series.txt");
  loadMap("vbg nns_series.txt");
  //loadMap("vbg nn_series.txt");
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
  String[] rows = loadStrings(url);
  for (String r:rows) {
    String[] cols = split(r, ",");
    Word w = new Word();
    w.w = cols[0];
    w.count = int(cols[1]);
    w.wsize = (pow(w.count, 0.8) * 0.5) + 5;

    //calculate weighted average
    int t = 0;
    int c = 0;
    for (int i = 2; i < cols.length; i++) {
      for (int j = 0; j < int(cols[i]); j++) {
        if (i > 0) {
          t += i;
          c ++;
        }
      }
    }

    float wa = (float) t / c;

    w.pos.set(map(wa, 2, cols.length, 100, width-100), random(50, height-50));
    words.add(w);
  }
}

void keyPressed() {
  if (key == 's') save("../../ProgressImages/NASAwords_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
}


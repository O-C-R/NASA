ArrayList<Word> words = new ArrayList();
ArrayList<Word> currentWords = new ArrayList();
PFont label;

int startYear = 1961;
int endYear = 2009;

float minCount = 0;
float maxCount = 0;

int thresh = 0;

String pattern = "";

String dataPath = "../../Data/BucketGramsAll/";
String buckets = "administrative,astronaut,mars,moon,people,politics,research_and_development,rockets,russia,satellites,space_shuttle,spacecraft,us";
String currentBucket = "rockets";

String[] bucketList;

float gap = 100;

String[] posList = {
  "FieldTerminology"

  /*
  "vbg", 
  "dt jj nns", 
  "dt jj nn", 
  "cd nns", 
  "vbg nn", 
  "jj vbg nns", 
  "dt jj vbg", 
  "jj vbg"
  */
};

void setup() {
  size(2000, 2000);
  label = createFont("Helvetica", 100);
  textFont(label);

  colorMode(HSB);
  bucketList = buckets.split(",");
  
  
  gap = height / bucketList.length;
  for (int i = 0; i < bucketList.length; i++) {
    currentBucket = bucketList[i];
    currentWords = new ArrayList();
    
    for (String pos:posList) {
      loadMap(pos + ".txt");
    }
    
    color c= color((map(i, 0, bucketList.length, 0, 255) * 2.5) % 255, 255, 255);
    positionWords(i * gap,(i * gap) + gap, c);
  }

  thresh = 0;
  //loadMap("3year_grams.txt");
}

void draw() {
  background(0);
  //Years
  
  for (int i = 0; i < bucketList.length; i++) {
    currentBucket = bucketList[i];
    color c= color((map(i, 0, bucketList.length, 0, 255) * 2.5) % 255, 255, 255);
    fill(c);
    textAlign(LEFT);
    textSize(24);
    text(currentBucket, 50, (i * gap) + 20);
  }

  colorMode(HSB);
  /*
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
   */
  for (Word w:words) {
    w.update();
    w.render();
  }
}

void loadMap(String url) {

  pattern = split(url, ".")[0];
  String[] rows = loadStrings(dataPath + currentBucket + "/" + url);
  for (String r:rows) {
    String[] cols = split(r, ",");
    Word w = new Word();
    w.w = cols[0];
    w.count = float(cols[1]);
    maxCount = max(w.count, maxCount);
    
    w.counts = new float[cols.length - 2];

    //calculate weighted average
    float t = 0;
    float c = 0;
    for (int i = 2; i < cols.length; i++) {
      float f = float(cols[i]);
      w.counts[i - 2] = f;
      t += f * (i - 1);
      c += f;
    }

    float wa = t / c;

    float x = map(wa - 1, 2, cols.length, 100, width-100);
    float yoff = map(x, 100, width - 100, 300, 50);
    float y = random(50, height - 50);//(random(100) < 50) ? random(50,height/2 - yoff):random(height/2 + yoff, height - 50);
    w.pos.set(x, y);
    if (w.count > thresh) {
      words.add(w);
      currentWords.add(w);
    }
  }
}

void positionWords(float ytop, float ybot, color c) {
  for (Word w:currentWords) {
    w.wsize = map(w.count, minCount, maxCount, 12, 48); 
    w.a = map(w.count, minCount, maxCount, 100, 255);
    w.col = c;
    w.pos.y = random(ytop, ybot);
    w.pos.x = (w.pos.x + (2 * map(findexOf(max(w.counts), w.counts), 0, w.counts.length, 50, width - 50))) / 3; 
    w.lineY = ybot;
  }
}

void keyPressed() {
  if (key == 's') save("../../ProgressImages/NASAwords_" + pattern + "_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
}


int findexOf(float needle, float[] haystack)
{
    for (int i=0; i<haystack.length; i++)
    {
        if (haystack[i] == needle) return i;
    }

    return -1;
}

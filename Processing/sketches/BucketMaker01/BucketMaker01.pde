import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;

import rita.*;

String baseBucketFile = "../../../Data/BucketDefiner/Buckets.txt";  // file where the most common phrases are

String jsonDirectory = "../../../Data/PDFsAsJSON/"; // location of the jsons

ArrayList<HistoryStory> historyStoriesAll = new ArrayList<HistoryStory>();

HashMap<String, Integer> monthsByString = new HashMap<String, Integer>();
HashMap<Integer, String> monthsByNumber = new HashMap<Integer, String>();
String timeStamp;

ArrayList<Bucket> bucketsAll = new ArrayList<Bucket>();
HashMap<String, Bucket> bucketsHM = new HashMap<String, Bucket>();

int[] yearRange = {
  1987, 2009
  //2001, 2001
};

//
void setup() {
  loadStories(yearRange);
  
  loadBuckets();
  
  makeStoryNGrams();  
  
  assignStoriesToBuckets();
  
  outputBuckets();
  
  exit();
} // end setup







//
//
//
//
//
//
//
//
//


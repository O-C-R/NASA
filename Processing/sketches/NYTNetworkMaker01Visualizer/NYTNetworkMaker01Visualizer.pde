import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;

// the starting and ending years to include -- note use nasa story timeline.. so only up to 2009
int[] yearRange = {
  1950, 2014
};

HashMap<String, NYTStory> nytStoriesHM = new HashMap<String, NYTStory>(); // all stories in a hashmap 

HashMap<String, PhraseReference> phraseKeeperHM = new HashMap<String, PhraseReference>(); // used to keep track of which stories contain which phrases
ArrayList<PhraseReference> phraseKeeperAll = new ArrayList<PhraseReference>();

String timeStamp;

HashMap<String, Integer> monthsByString = new HashMap<String, Integer>();
HashMap<Integer, String> monthsByNumber = new HashMap<Integer, String>();

//
void setup() {
  OCRUtils.begin(this);
  
  size(300, 300);
  
  //loadNYTStories(yearRange); // which also adds the NYTStories to the year as well
  loadPhraseReferences(yearRange);
  monthsByString = getMonths(); // make the month HM
  monthsByNumber = getMonthsByNumber(monthsByString);
  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2);
  
  //for (PhraseReference pr : phraseKeeperAll) println(pr);
  
  outputPhrases();
  
  println("done");
  exit();
} // end setup

//
void draw() {
  
} // end draw

//
//
//
//
//
//
//


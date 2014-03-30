import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;

import rita.support.*;
import rita.*;

// the starting and ending years to include -- note use nasa story timeline.. so only up to 2009
int[] yearRange = {
  1950, 2014
};

ArrayList<NYTStory> nytStoriesAll = new ArrayList<NYTStory>(); // all nyt stories as they were read in, not necessarily by date
ArrayList<NYTStory> nytStoriesByDate = new ArrayList<NYTStory>(); // all valid nyt stories by date asc
ArrayList<NYTStory> nytStoriesByPage = new ArrayList<NYTStory>(); // all valid nyt stories with a page number asc
HashMap<String, NYTStory> nytStoriesHM = new HashMap<String, NYTStory>(); // all stories in a hashmap 

HashMap<String, PhraseReference> phraseKeeper = new HashMap<String, PhraseReference>(); // used to keep track of which stories contain which phrases

String timeStamp;

ArrayList<String> commonWords = new ArrayList<String>();
HashMap<String, Integer> monthsByString = new HashMap<String, Integer>();
HashMap<Integer, String> monthsByNumber = new HashMap<Integer, String>();

//
void setup() {
  OCRUtils.begin(this);
  RiTa.SILENT = true;
  size(300, 300);
  
  loadNYTStories(yearRange); // which also adds the NYTStories to the year as well
  loadCommonWords(); // loads the common words
  monthsByString = getMonths(); // make the month HM
  monthsByNumber = getMonthsByNumber(monthsByString);
  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2);
  
  findTopNYTNGrams();
  
  outputStories();
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


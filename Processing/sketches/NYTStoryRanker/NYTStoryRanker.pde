import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;



String jsonDirectory = "../../../Data/PDFsAsJSON/"; // location of the jsons
ArrayList<Year> years = new ArrayList<Year>(); // each year has its own stories
HashMap<Integer, Year> yearsHM = new HashMap<Integer, Year>(); // hash map version

// the starting and ending years to include
int[] yearRange = {
  2008, 2009
};


ArrayList<NYTStory> nytStoriesAll = new ArrayList<NYTStory>(); // all nyt stories as they were read in, not necessarily by date
ArrayList<NYTStory> nytStoriesByDate = new ArrayList<NYTStory>(); // all valid nyt stories by date asc
ArrayList<NYTStory> nytStoriesByPage = new ArrayList<NYTStory>(); // all valid nyt stories with a page number asc

String timeStamp;

//
void setup() {
  OCRUtils.begin(this);
  loadYears(yearRange); // load in the appropriate years
  loadNYTStories(yearRange); // which also adds the NYTStories to the year as well
  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2);
  
  for (Year y : years) println(y);
  
  
  /*
  String[] keyWords = {
    "MILITARY"
  };
  */
  //ArrayList<NYTStory> filtered = filterByKeywords(keyWords); // filter by keyword
  //for (NYTStory nt : filtered) println(nt);
  //scatterPlotPageVsMonthDensity();
  
  
  tryToRankHistoryStories();
  
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



import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;

String nytArticleKey = ""; // loaded in loadKeys()
String searchOutputDirectory = "output/";
HashMap<String, Integer> existingSearches = new HashMap<String, Integer>(); // .. so that searches need not be done twice

// ngram data
String ngramFile = "../../../Data/grams/vbg nns_series.txt";
String startWord = "braking rockets";
String endWord = "carrying astronauts";

void setup() {
  OCRUtils.begin(this);
  loadKeys();
  // search through ngrams
  boolean started = false;
  String[] ngrams = loadStrings(ngramFile);
  for (int i = 0; i < ngrams.length; i++) {
    String ngram = split(ngrams[i], ",")[0];
    if (!started) {
      if (ngram.equals(startWord)) started = true;
    }
    if (started) {
      println(i + " searching for: " + ngram);
      doBigSearch(ngram, 1850, 2014, false);
      println(":^)");
    }
    if (started && ngram.equals(endWord)) break;
  }
  println("\ndone");
  exit();
} // end setup


//
void draw() {
} // end draw

//
void keyReleased() {
} // end keyReleased

//
ArrayList<Result> doSearch(String searchTerm, int targetYear, int targetMonth) {
  String beginDate = targetYear + "0101";
  String endDate = targetYear + "1231";
  boolean pastTime = false;
  // if it is going by month then that will be adjusted here
  boolean endOfYear = false;
  if (targetMonth > -1) {
    beginDate = targetYear + nf(targetMonth, 2) + "01";
    if (targetMonth == 12) {
      targetMonth = 1;
      targetYear++;
      endOfYear = true;
    }
    else {
      targetMonth++;
    }
    Calendar temp = getCalFromDataTime(nf(targetYear, 4) + nf(targetMonth, 2) + 01);
    temp.add(Calendar.DAY_OF_MONTH, -1);
    endDate = nf(temp.get(Calendar.YEAR), 4) + nf(temp.get(Calendar.MONTH) + 1, 2) + nf(temp.get(Calendar.DAY_OF_MONTH), 2);
    // stop if the date is after today
    if (getCalFromDataTime(beginDate).getTimeInMillis() > Calendar.getInstance().getTimeInMillis()) pastTime = true;
  }

  // reset the targetMonth
  if (endOfYear) targetMonth = 12;
  else targetMonth--;

  //println(beginDate + " to " + endDate);
  Search newSearch = new Search(searchTerm, beginDate, endDate, targetYear, targetMonth);
  if (!pastTime) {
    newSearch.makeResults();
    //println("done with " + searchTerm + " for year: " + targetYear + " with " + newSearch.hits + " hits");
    if (targetYear % 10 == 0) print(targetYear); 
    else print(".");
  }
  return newSearch.results;
} // end doSearch

//
void doBigSearch(String searchTerm, int startYear, int endYear, boolean byMonth) {
  // make a big search that contains all of the little searches
  String beginDate = startYear + "0101";
  String endDate = endYear + "1231";
  Search bigSearch = new Search(searchTerm, beginDate, endDate, startYear, -1); 

  for (int i = startYear; i <= endYear; i++) {
    if (byMonth) {
      for (int j = 1; j <= 12; j++) {
        bigSearch.results.addAll(doSearch(searchTerm, i, j));
      }
    }
    else {
      bigSearch.results.addAll(doSearch(searchTerm, i, -1));
    }
  }
  bigSearch.output();
} // end doBigSearch


//
//
//
//


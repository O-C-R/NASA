import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;

String nytArticleKey = ""; // loaded in loadKeys()
String searchOutputDirectory = "output/";
HashMap<String, Integer> existingSearches = new HashMap<String, Integer>(); // .. so that searches need not be done twice

void setup() {
  loadKeys();

  //doBigSearch("Aeroplane", 1913, 2014);
  doBigSearch("Airplane", 1900, 2014, false);
} // end setup


//
void draw() {
} // end draw

//
void keyReleased() {
} // end keyReleased

//
void doSearch(String searchTerm, int targetYear, int targetMonth) {
  String beginDate = targetYear + "0101";
  String endDate = targetYear + "1231";
  // if it is going by month then that will be adjusted here
  if (targetMonth > -1) {
    beginDate = targetYear + nf(targetMonth, 2) + "01";
    if (targetMonth == 12) {
      targetMonth = 1;
      targetYear++;
    }
    else {
      targetMonth++;
    }
    Calendar temp = getCalFromDataTime(nf(targetYear, 4) + "-" + nf(targetMonth, 2) + "-" + 01);
    temp.add(Calendar.DAY_OF_MONTH, -1);
    endDate = nf(temp.get(Calendar.YEAR), 4) + nf(temp.get(Calendar.MONTH) + 1, 2) + nf(temp.get(Calendar.DAY_OF_MONTH), 2);
  }
  println(beginDate + " + " + endDate);
  //Search newSearch = new Search(searchTerm, beginDate, endDate);
  //newSearch.makeResults();
  //newSearch.output();
  //println("done with " + searchTerm + " for year: " + targetYear + " with " + newSearch.results.size() + " results");
} // end doSearch

//
void doBigSearch(String searchTerm, int startYear, int endYear, boolean byMonth) {
  for (int i = startYear; i <= endYear; i++) {
    if (byMonth) {
      for (int j = 1; j <= 12; j++) {
        doSearch(searchTerm, i, j);
      }
    }
    else {
      doSearch(searchTerm, i, -1);
    }
  }
} // end doBigSearch


//
//
//
//


import java.util.Map;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.TimeZone;


String nytArticleKey = ""; // loaded in loadKeys()
String searchOutputDirectory = "output/";
HashMap<String, Integer> existingSearches = new HashMap<String, Integer>(); // .. so that searches need not be done twice


//String fq = "organizations:(\"NATIONAL AERONAUTICS AND SPACE ADMINISTRATION\")";
//String fq = "organizations:(\"AERONAUTICS AND SPACE ADMINISTRATION, NATIONAL\")";
//String fq = "organizations:(\"JET PROPULSION LABORATORY\")";
//String fq = "subject:(\"SPACE\")";
//String fq = "subject:(\"AERONAUTICS\")";
String fq = ""; // blank means no fq

//String searchTerm = ""; // blank means no search term
//String searchTerm = "NASA";
//String searchTerm = "Apollo";
//String searchTerm = "\"NATIONAL AERONAUTICS AND SPACE ADMINISTRATION\"";
//String searchTerm = "\"JET PROPULSION LABORATORY\"";
//String searchTerm = "\"Astronaut\"";
String searchTerm = "\"Cosmonaut\"";

//
void setup() {
  OCRUtils.begin(this);
  loadKeys();
  doBigSearch(searchTerm, fq, 1950, 2014, true); 
  println("__DONE");
  exit();
} // end setup

//
void draw() {
} // end draw


//
void keyReleased() {
  if (key == ' ') {
    doSearch(searchTerm, fq, 1969, 6);
  }
} // end keyReleased




//
//
//
//
//
//
//
//
//
//
//


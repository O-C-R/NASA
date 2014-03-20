import ocrUtils.*;
import java.util.Map;

String jsonDirectory = "../../../Data/PDFsAsJSON/"; // location of the jsons
String outputDirectory = "../../../StudyOutput/StoryGrapherSimple/";
ArrayList<Year> years = new ArrayList<Year>(); // each year has its own stories

// the starting and ending years to include
int[] yearRange = {
  1986, 2009
};

String startTime;
HashMap<String, Integer> monthsByString = new HashMap<String, Integer>();
HashMap<Integer, String> monthsByNumber = new HashMap<Integer, String>();

//
void setup() {
  startTime = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2);
  OCRUtils.begin(this);
  monthsByString = getMonths(); // make the month HM
  monthsByNumber = getMonthsByNumber(monthsByString); 

  loadYears(yearRange);

  size(800, 400);
  g.textFont(createFont("Helvetica", 12));
  graphStoriesPerYear(g);
  storiesPerMonthTotal(g);
  storiesPerMonthWordAverage(g);
  storiesByWordCountVSReadingLevel(g);



  exit();
} // end setup


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

String baseKeyWordsFile = "../../../StudyOutput/NYTNetworkMaker01Visualizer/1950-2014_5307_8423-madeFromFQList.txt";  // file where the most common phrases are

String jsonDirectory = "../../../Data/PDFsAsJSON/"; // location of the jsons

int[] yearRange = {
  //1987, 2009
  //1994, 2001
  1961, 2009
};

ArrayList<HistoryStory> historyStoriesAll = new ArrayList<HistoryStory>();

HashMap<String, Integer> monthsByString = new HashMap<String, Integer>();
HashMap<Integer, String> monthsByNumber = new HashMap<Integer, String>();
String timeStamp;

ArrayList<Phrase> phrasesAll = new ArrayList<Phrase>();

//
void setup() {
  OCRUtils.begin(this);
  size(1000, 1000);
  randomSeed(1866);

  monthsByString = getMonths(); // make the month HM
  monthsByNumber = getMonthsByNumber(monthsByString);
  timeStamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2);

  loadStories(yearRange);
  loadPhrases();
  populatePhrases(); // puts history stories into phrases and phrases into history stories

    printMostPopularPhrases();

  //makeCircularDiagram();

  println("done");
  exit();
} // end setup

//
//
//
//
//


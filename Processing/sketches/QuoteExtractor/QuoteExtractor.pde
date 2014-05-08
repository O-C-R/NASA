// this sketch will try to extract quotes from the pdfs as json

import ocrUtils.*;
import java.util.Map;
import java.util.Collections;

ArrayList<Quote> quotes = new ArrayList<Quote>();

void setup() {
  OCRUtils.begin(this);
  String[] files = OCRUtils.getFileNames(sketchPath("") + "../../../Data/PDFsAsJSON/", false);

  // input
  for (int i = 0; i < files.length; i++) {
    JSONObject json = loadJSONObject(files[i]);
    JSONArray stories = json.getJSONArray("stories");
    int year = Integer.parseInt(splitTokens(files[i], "/.")[splitTokens(files[i], "/.").length - 2]);
    for (int j = 0; j < stories.size(); j++) {
      JSONObject story = stories.getJSONObject(j);
      int month = story.getInt("monthNumber");
      int day = story.getInt("day");
      String str = story.getString("story");
      if ((str.contains("\"") || str.contains("“") || str.contains("”")) && str.contains("said")) {
        Quote q = new Quote();
        q.str = str;
        q.year = year;
        q.month = month; 
        q.day = day;
        quotes.add(q);
      }
      //if (year == 2008 && (str.contains("\"") || str.contains("“") || str.contains("”")) && str.contains("said")) println(str);
    }
  } 

  // output
  int lastYear = -1;
  PrintWriter output = createWriter("output/quotes.txt");
  for (int i = 0; i < quotes.size(); i++) {

    if (quotes.get(i).year != lastYear) {
      lastYear = quotes.get(i).year;
      output.println("\n\n" + "_YEAR: " + lastYear + "_\n");
    }

    output.println(quotes.get(i));
  }
  output.flush();
  output.close();

  println("done");
  exit();
} // end setup


//
class Quote {
  String str = "";
  int year = 0;
  int month = 0;
  int day = 0;

  String toString() {
    String builder = "\nSTORY: " + nf(month, 2) + "/" + nf(day, 2) + "/" + nf(year, 4) + "\n";
    builder += str;
    return builder;
  } // end toString
} // end class Quote

//
//
//
//


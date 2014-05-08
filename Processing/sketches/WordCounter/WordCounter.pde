import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import rita.*;

String directory = "../../../Data/PDFsAsJSON/";

int[] yearRange = {
  1958, 
  2008
};

void setup() {
  PrintWriter output = createWriter("output/textSummary.txt");
  output.println("year,story count,word count, avg word per story");
  output.println("  xxxx as a simple graph of the word count");
  output.println("  oooo as a simple graph of the story count");

  OCRUtils.begin(this);

  int allWords = 0;
  int allStories = 0;

  String[] files = OCRUtils.getFileNames(sketchPath("") + directory, false);
  for (int i = 0; i < files.length; i++) {
    int totalStories = 0;
    int totalWordCount = 0;
    float averageWordCount = 0f;

    int fileYear = Integer.parseInt(splitTokens(files[i], "./")[splitTokens(files[i], "./").length - 2]);
    if (fileYear >= yearRange[0] && fileYear <= yearRange[1]) {
      //println(fileYear);
      JSONObject json = loadJSONObject(files[i]);
      JSONArray jar = json.getJSONArray("stories");
      totalStories = jar.size();
      for (int j = 0; j < jar.size(); j++) {
        String story = jar.getJSONObject(j).getString("story");
        //totalWordCount += split(story, " ").length;
        totalWordCount += RiTa.getWordCount(story);//split(story, " ").length;
      }
      //println("year: " + fileYear + " totalStories: " + nf(totalStories, 4) + " totalWords: " + nf(totalWordCount, 6));


      output.println(fileYear +","+ totalStories +","+ totalWordCount +","+ (((float)totalWordCount)/totalStories));
      for (int j = 0; j < map(totalWordCount, 0, 300000, 0, 100); j++) output.print("x");
      output.println("_");
      for (int j = 0; j < map(totalStories, 0, 3000, 0, 100); j++) output.print("o");
      output.println("_");

      allWords += totalWordCount;
      allStories += totalStories;
    }
  }

  output.println("_____");
  output.println("_____");
  output.println("_____");
  output.println("year range:");
  output.println(yearRange[0] + " to " + yearRange[1]);
  output.println("approx. total stories from all years:");
  output.println(allStories);
  output.println("approx. total words from all stories:");
  output.println(allWords);
  output.println("approx. avg words per story:");
  output.println((float)allWords / allStories);


  output.flush();
  output.close();
  println("done");
  exit();
} // end setup


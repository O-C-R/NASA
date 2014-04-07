String fileLocation = "../../../Data/PDFsAsText/Best as of April 4/April 4 Corrections/";
String outputLocation = "output/";

int[] years = {
  1963
};

String currentMonth = "";
int currentDay = 0;
int currentYear = 0;

boolean started = false;
String startingString = "JANUARY 1961";
String heading = "AERONAUTICAL AND ASTRONAUTICAL EVENTS";
String stopString = "APPENDIX A";
String[] keyWords = {
  "Early", "During", "Late"
};

HashMap<String, Integer> months = new HashMap<String, Integer>();

ArrayList<Story> stories;

Story currentStory;


void setup() {
  months = getMonths(); // make the month HM

  for (int year : years) {
    currentYear = year;
    stories = new ArrayList<Story>();

    String[] allLines = loadStrings(fileLocation + "April 4 " + currentYear + ".txt");
    for (int i = 0; i < allLines.length; i++) {
     // allLines[i] = cleaner(allLines[i]);
    }
    println("loaded and cleaned : "+ allLines.length + " lines fom file");

    for (int i = 0; i < allLines.length; i++) {
      allLines[i] = allLines[i].trim();

      String[] broken = splitTokens(allLines[i], " ");
      boolean madeNewDay = false;
      boolean monthYearLine = false;
      if (broken.length > 1) {
        String monthCheck = broken[0].trim();
        String dayCheck = cleanOddCharsOut(broken[1].trim());
        if (isMonth(monthCheck)) {
          try {
            int newDay = Integer.parseInt(dayCheck.replace(":", ""));
            if (newDay < 32) {
              currentDay = newDay; // set the current day and
              currentMonth = monthCheck; // the current month
              println("found new month/day pairing: " + currentMonth + " " + currentDay);
              madeNewDay = true;
            }
            // otherwise it is a month year pairing
            else {
              monthYearLine = true;
            }
          }
          catch (Exception e) {
          }
        }

        if (isStory(broken[0]) || madeNewDay) {
          // make a new story
          Story newStory = new Story(currentMonth, currentDay);
          newStory.setText(stripStoryStuff(broken, madeNewDay), madeNewDay);
          stories.add(newStory);
          currentStory = newStory;
        }
        else {
          if (!monthYearLine) {
            if (currentStory != null) currentStory.addRawString(allLines[i]);
          }
        }
      }
    }
    for (Story st : stories) st.makeCleanString();
    println("made: " + stories.size() + " new stories");
    //println(stories.get(stories.size() - 1));
    for (int i = 0; i < 3; i++) {
      println(stories.get(i));
    }
    outputStories(currentYear);
  }

  exit();
} // end setup


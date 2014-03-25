String fileLocation = "../../../Data/PDFsAsText/testFromOCR/";
String outputLocation = "output/";

int[] years = {
  1961
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

    String[] test = loadStrings(fileLocation + currentYear + ".txt");
    for (int i = 0; i < test.length; i++) {
      test[i] = cleaner(test[i]);
    }


    for (int i = 0; i < test.length; i++) {
      test[i] = test[i].trim();

      // start and stop controls
      // skip things that are before the starting string
      if (!started) {
        if (test[i].equals(startingString)) started = true;
        continue;
      }
      // and stop when the last line is reached
      if (test[i].equals(stopString)) break;

      String[] broken = splitTokens(test[i], " ");
      boolean madeNewDay = false;
      if (broken.length > 1) {
        String monthCheck = broken[0].trim();
        String dayCheck = cleanOddCharsOut(broken[1].trim());
        if (isMonth(monthCheck)) {
          try {
            int newDay = Integer.parseInt(dayCheck.replace(":", ""));
            if (newDay < 32) {
              currentDay = newDay;
              currentMonth = monthCheck;
              println("found new month/day pairing: " + currentMonth + " " + currentDay);
              madeNewDay = true;
            }
          }
          catch (Exception e) {
          }
        }


        //if (broken[0].charAt(0) == '*' || madeNewDay) {
        if (currentMonth.equals("January")) {
          println(isStory(broken[0]) + " _- story? " + broken[0]);
        }

        if (isStory(broken[0]) || madeNewDay) {
          // make a new story
          Story newStory = new Story(currentMonth, currentDay);
          newStory.setText(stripStoryStuff(broken, madeNewDay), madeNewDay);
          if (currentMonth.equals("January")) println(stripStoryStuff(broken, madeNewDay));
          stories.add(newStory);
          currentStory = newStory;
        }
        else {
          if (currentStory != null) currentStory.addRawString(test[i]);
        }
      }
    }
    for (Story st : stories) st.makeCleanString();
    println("made: " + stories.size() + " new stories");
    //println(stories.get(stories.size() - 1));
    for (int i = 0; i < 3; i++) {
      println(stories.get(i));
    }
    //outputStories(currentYear);
  }

  exit();
} // end setup


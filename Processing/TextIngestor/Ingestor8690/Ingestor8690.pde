String fileLocation = "../../../Data/Docs/chronology8690/";
String outputLocation = "output/";

int[] years = {
  1986, 
  1987,
  1988, 
  1989, 
  1990
};

String currentMonth = "";
int currentDay = 0;
int currentYear = 0;

HashMap<String, Integer> months = new HashMap<String, Integer>();

ArrayList<Story> stories;

Story currentStory;


void setup() {
  months = getMonths(); // make the month HM

  for (int year : years) {
    currentYear = year;
    stories = new ArrayList<Story>();

    String[] test = loadStrings(fileLocation + currentYear);
    for (int i = 0; i < test.length; i++) {
      test[i] = cleaner(test[i]);
    }


    for (int i = 0; i < test.length; i++) {
      test[i] = test[i].trim();
      String[] broken = splitTokens(test[i], " ");
      boolean madeNewDay = false;
      if (broken.length > 1) {
        String monthCheck = broken[0].trim();
        String dayCheck = broken[1].trim();
        if (isMonth(monthCheck)) {
          try {
            currentDay = Integer.parseInt(dayCheck.replace(":", ""));
            currentMonth = monthCheck;
            //println("found new month/day pairing: " + currentMonth + " " + currentDay);
            madeNewDay = true;
          }
          catch (Exception e) {
          }
        }
        if (broken[0].charAt(0) == '*' || madeNewDay) {
          // make a new story
          Story newStory = new Story(currentMonth, currentDay);
          newStory.setText(test[i], madeNewDay);
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
    println(stories.get(stories.size() - 1));
    outputStories(currentYear);
  }

  exit();
} // end setup


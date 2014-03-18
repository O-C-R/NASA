//String fileLocation = "/Users/nyounse/Desktop/Chron92TXT.txt";
String fileLocation = "../../../Data/Docs/chronology9195/Chron";
String outputLocation = "output/";

int[] years = {
  1991, 
  1992, 
  1993, 
  1994, 
  1995
};

String currentMonth = "";
int currentDay = 0;
int currentYear = 0;

HashMap<String, Integer> months = new HashMap<String, Integer>();

ArrayList<Story> stories;

void setup() {
  months = getMonths(); // make the month HM

  for (int year : years) {
    currentYear = year;
    stories = new ArrayList<Story>();
    String[] test = loadStrings(fileLocation + (currentYear - 1900) + ".doc");
    for (int i = 0; i < test.length; i++) {
      test[i] = test[i].trim();
      //println(i + " ---- " + test[i]);
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
          if (currentMonth.equals("December") && currentDay >= 25) {
            if (test[i].contains("Index")) break; // because for some reason the last line is crappified
          }
          stories.add(newStory);
        }
      }
    }
    println("made: " + stories.size() + " new stories");
    outputStories(currentYear);
  }
  exit();
} // end setup


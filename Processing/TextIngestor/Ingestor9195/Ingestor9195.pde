//String fileLocation = "/Users/nyounse/Desktop/Chron92TXT.txt";
String fileLocation = "/Users/nyounse/Desktop/chronology/Chron91.doc";
String outputLocation = "/output/";

String currentMonth = "";
int currentDay = 0;

String fileToLookAt = "";

HashMap<String, Integer> months = new HashMap<String, Integer>();

ArrayList<Story> stories = new ArrayList<Story>();

void setup() {
  months = getMonths(); // make the month HM


  String[] test = loadStrings(fileLocation);
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
          println("found new month/day pairing: " + currentMonth + " " + currentDay);
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
  for (int i = stories.size() - 1; i >= stories.size() - 10; i--) {
    println(stories.get(i));
  }

  exit();  
} // end setup


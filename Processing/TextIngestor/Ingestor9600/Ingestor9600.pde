import java.util.Map;

String fileLocation = "../../../Data/PDFsAsText/textRaw/";
String outputLocation = "output/";

String currentMonth = "";
int currentDay = 0;
int currentYear = 0;
Story currentStory;

// 1996 - 2000
//String fileName = "1996-2000.txt";
//String heading = "Astronautics and Aeronautics: A Chronology"; // 1996-2000
//String stopText = "APPENDIX A"; // 1996-2000

// 2001 - 2005
//String fileName ="2001-2005.txt";
//String heading = "Aeronautics and Astronautics: A Chronology"; // 2001-2005
//String stopText = "AA TT ACES ACS ADEOS ADS-B AIRS AlSAT AML AMP AOD ARC ASAP ASDE ASI ATV AU AURA AWACS"; // 2001-2005

// 2006
//String fileName = "2006.txt";
//String heading = "Aeronautics and Astronautics: A Chronology"; 
//String stopText = "APPENDIX A: TABLE OF ABBREVIATIONS";

// 2007
String fileName = "2007.txt";
String heading = "Aeronautics and Astronautics: A Chronology"; 
String stopText = "APPENDIX A: TABLE OF ABBREVIATIONS";

// 2008
//String fileName = "2008.txt";
//String heading = "Aeronautics and Astronautics: A Chronology"; 
//String stopText = "APPENDIX A: TABLE OF ABBREVIATIONS";

// 2009
//String fileName = "2009.txt";
//String heading = "Aeronautics and Astronautics: A Chronology"; 
//String stopText = "APPENDIX A: TABLE OF ABBREVIATIONS";


boolean lastLineWasHeading = false;
boolean makeNewStory = false;



HashMap<String, Integer> months = new HashMap<String, Integer>();

HashMap<Integer, ArrayList<Story>> stories = new HashMap<Integer, ArrayList<Story>>();

HashMap<Integer, String> parentheticals = new HashMap<Integer, String>();
int lastParentheticalMarker = 0;

void setup() {
  months = getMonths(); // make the month HM

  String[] test = loadStrings(fileLocation + fileName);

  boolean madeNewDay = false;
  for (int i = 0; i < test.length; i++) {
    test[i] = test[i].trim();
    String[] broken = splitTokens(test[i], " ");
    boolean isMonthMarker = false;
    if (broken.length > 1) {

      String monthCheck = broken[0].trim();
      String dayCheck = broken[1].trim();
      if (broken.length == 2) {
        // check for year - use to define month
        try {
          currentYear = Integer.parseInt(dayCheck);
          if (isMonth(monthCheck)) {
            isMonthMarker = true;
            println("______ " + getMonthNumber(monthCheck) + "-" + currentYear + " FOUND NEW MONTH YEAR: " + monthCheck + " -- " + currentYear);
            if (!stories.containsKey(currentYear)) stories.put(currentYear, new ArrayList<Story>());
          }
        }
        catch (Exception a) {
        }
        // check for day month
        if (!isMonthMarker) {
          dayCheck = monthCheck;
          monthCheck = broken[1].trim();
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
        }
      }
    }


    // make the story:
    boolean isStory = true; // false from parantheticals, page numbers, and headings
    // cut out with stop story
    if (i > 100 && test[i].contains(stopText)) break;

    // cut out if made new day or monthMarker
    if (madeNewDay || isMonthMarker) {
      isStory = false;
      madeNewDay = false;
      isMonthMarker = false;
      lastLineWasHeading = false;
      makeNewStory = true; // next iteration a new story will be made regardless of if the lastLineWasHeading
    }

    // check for parentheticals
    if (broken.length > 1 && !isMonth(broken[1])) {
      try {
        int parentheticalMarker = Integer.parseInt(broken[0]);
        //println("____" + parentheticalMarker + " :: " + lastParentheticalMarker);
        if ((parentheticalMarker - lastParentheticalMarker) > 0 && (parentheticalMarker - lastParentheticalMarker) < 10) {
          int parentheticalSkipIndex = 0;
          String newParenthetical = "";
          for (int y = 0; y < test[i].length(); y++) {
            if (test[i].charAt(y) == ' ') {
              newParenthetical = test[i].substring(y).trim();
              break;
            }
          }
          parentheticals.put(parentheticalMarker, newParenthetical);
          lastParentheticalMarker = parentheticalMarker;
          isStory = false;
        }
      }
      catch (Exception l) {
      }
    }

    // check for page numbers
    if (broken.length == 1) {
      // page number
      try {
        int page = Integer.parseInt(broken[0].trim());
        isStory = false;
      }
      catch (Exception o) {
      }
    }

    // check for heading
    if (test[i].contains(heading)) {
      isStory = false; 
      lastLineWasHeading = true;
    }

    // check if the previous story ended in a reference
    if (currentStory != null) if (currentStory.alreadyEndsInReference()) {
      makeNewStory = true;
    } 
    

    if (isStory) {
      if (lastLineWasHeading && !makeNewStory) {
        // add to existing story
        if (currentStory != null) {
          currentStory.addRawString(test[i]);
        }
        else {
          Story newStory = new Story(currentMonth, currentDay);
          newStory.addRawString(test[i]);
          if ((ArrayList<Story>)stories.get(currentYear) != null) ((ArrayList<Story>)stories.get(currentYear)).add(newStory);
          currentStory = newStory;
        }
      }
      else {
        // make a new story
        Story newStory = new Story(currentMonth, currentDay);
        newStory.addRawString(test[i]);
        if ((ArrayList<Story>)stories.get(currentYear) != null) ((ArrayList<Story>)stories.get(currentYear)).add(newStory);
        currentStory = newStory;
      }
      lastLineWasHeading = false;
      makeNewStory = false;
    }
  }

  println("___ done");
  println("made " + parentheticals.size() + " parentheticals");
  for (Map.Entry me : parentheticals.entrySet()) {
    int ref = (Integer)me.getKey();
    String paren = (String)me.getValue();
    //println(ref + " -- " + paren);
  }

  println("made " + stories.size() + " new stories:");
  for (Map.Entry me : stories.entrySet()) {
    int yr = (Integer)me.getKey();
    ArrayList<Story> theseStories = (ArrayList<Story>)me.getValue();
    for (Story st : theseStories) st.makeCleanString();
    for (Story st : theseStories) st.assignParentheticals();
    println("outputting yr: " + yr + " with " + theseStories.size() + " stories");
    outputStories(yr, theseStories);
  }
  exit();
} // end setup

//
//
//
//
//


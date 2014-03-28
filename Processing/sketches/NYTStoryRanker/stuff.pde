//
String[] gramPosPhrases = {
  "orbiting beyond Neptune", 
  "be awarded planethood", 
  "energy fluctuations", 
  "set in motion", 
  "sound waves", 
  "gathered the data", 
  "microscopic processes", 
  "examining the early universe", 
  "light and sound", 
  "circumnavigated Antarctica", 
  "discovery of the sound", 
  "fall to earth"
};

int pageCutoff = 200; // to determine an important story the nytStory printPage must be this or less
int occuranceMinimum = 1; // to be a similar story there must be at least this many similar grams



//
// try to rank the stories by matching the nyt headline text + nyt page with the history story
void tryToRankHistoryStories() {
  println("in tryToRankHistoryStories");

  ArrayList<NYTStory> topStories = new ArrayList<NYTStory>();
  //for (NYTStory st : nytStoriesByPage) if (st.printPage == 1) topStories.add(st); // only page 1 stories
  for (NYTStory st : nytStoriesByPage) if (st.printPage <= pageCutoff) topStories.add(st); 
  println("topStories.size(): " + topStories.size());



  for (int i = 0; i < topStories.size(); i++) {
    ArrayList<HistoryStoryDropoff> similarStories = findSimilarStories(topStories.get(i));
    // add to importantStories
    for (HistoryStoryDropoff hsd : similarStories) {
      boolean existsAlready = false;
      for (ImportantStory is : importantStories) {
        if (is.historyStory == hsd.historyStory) {
          is.addNYTStory(topStories.get(i), hsd.occurances);
          existsAlready = true;
          break;
        }
      }
      if (!existsAlready) {
        ImportantStory is = new ImportantStory(hsd.historyStory);
        is.addNYTStory(topStories.get(i), hsd.occurances);
        importantStories.add(is);
      }
    }

    // manual break;
    //if (i == 1000) break;
  } 

  println("end of tryToRankHistoryStories");
} // end tryToRankHistoryStories


//
ArrayList<HistoryStoryDropoff> findSimilarStories(NYTStory nytStory) {
  // println(" \nin findSimilarSories.");
  ArrayList<HistoryStoryDropoff> similar = new ArrayList<HistoryStoryDropoff>();
  int monthsPreviousToSearch = 1; // will collect and look at stories up to n months before this article was written
  Calendar end = nytStory.pubDate;
  Calendar start = Calendar.getInstance();
  start.setTimeInMillis(end.getTimeInMillis());
  start.add(Calendar.MONTH, -monthsPreviousToSearch); 
  ArrayList<HistoryStory> options = getHistoryStoriesWithinRange(start, end); // the ones which are in the monthsPreviousToSearch range
  //println("  options size: " + options.size());
  //println("     headline: " + nytStory.headline);
  //println("     abstr: " + nytStory.abstr);


  // find the grams for the nyt
  //HashMap<Integer, IntDict> nytCounters = getGrams(2, 5, RiTa.splitSentences(nytStory.abstr));
  IntDict nytGrams = new IntDict();
  String[] nytSentences = RiTa.splitSentences(nytStory.abstr);
  for (String s : gramPosPhrases) nytGrams = countGramsByPos(nytGrams, s, nytSentences); // ok if the gram positions are duplicated because they should
  // be added to the overall nytGrams list, but that list is just used for looking for word matches, not counts
  //println("_____S_S_S_S_S_S____");
  //println(nytGrams);

  for (HistoryStory st : options) {
    IntDict occurances = countOccurances(nytGrams, RiTa.splitSentences(st.story));
    // *********** //
    if (occurances.size() >= occuranceMinimum) {
      /*
      println("_____S_S_S_S_S_S____");
      println("  options size: " + options.size());
      println("     headline: " + nytStory.headline);
      println("     abstr: " + nytStory.abstr);
      println(nytGrams);
      println("_____UUUUUUUUUUUU_S_S_S_S_S____");
      println(occurances);
      println(st.story);
      */
      similar.add(new HistoryStoryDropoff(st, occurances));
    }
  }



  /*
  for (HistoryStory st : options) {
   HashMap<Integer, IntDict> stCounter = getGrams(2, 5, RiTa.splitSentences(st.story));
   
   int matchCount = 0;
   for (Map.Entry me : stCounter.entrySet()) {
   int n = (Integer)me.getKey();
   IntDict id = (IntDict)me.getValue();
   IntDict nytID = (IntDict) nytCounters.get(n);
   for (String historyKey : id.keys()) {
   if (nytID.hasKey(historyKey)) {
   println(historyKey + " _jjjjjjjjj_ " + nytID.get(historyKey));
   matchCount++;
   }
   }
   }
   if (matchCount > 3) println(st.story);
   
   
   
   //float similarity = getSimilarity(nytStory, st);
   //println("   _______similarity: " + similarity);
   //println("     headline: " + nytStory.headline);
   //println("     abstr: " + nytStory.abstr);
   //println(stripCommonWords(st.story));
   }
   */


  return similar;
} // end findSimilarStories


//
// this will go through the years and return an ArrayList of all history stories within this calendar range
ArrayList<HistoryStory> getHistoryStoriesWithinRange (Calendar start, Calendar end) {
  long startMS = start.getTimeInMillis();
  long endMS = end.getTimeInMillis();
  ArrayList<HistoryStory> range = new ArrayList<HistoryStory>();
  int startYear = start.get(Calendar.YEAR);
  int endYear = end.get(Calendar.YEAR);
  for (int year = startYear; year <= endYear; year++) {
    Year thisYear = yearsHM.get(year);
    for (int i = 0; i < 12; i++) {
      Calendar monthStart = getCalFromDataTime(thisYear.year + nf(i + 1, 2) + "01");
      Calendar monthEnd = Calendar.getInstance();
      monthEnd.setTimeInMillis(monthStart.getTimeInMillis());
      monthEnd.add(Calendar.MONTH, 1);
      monthEnd.add(Calendar.SECOND, -1);
      long monthStartMS = monthStart.getTimeInMillis();
      long monthEndMS = monthEnd.getTimeInMillis();
      if (startMS <= monthStartMS && endMS >= monthEndMS) {
        // entire range
        range.addAll(thisYear.historyStoriesByMonth.get(i));
      }
      else if ((monthStartMS >= startMS && monthStartMS <= endMS) || (monthEndMS >= startMS && monthEndMS <= endMS)) {
        // partial range 
        //println("\nXXX" + getNicePubDateString(start) + "_"+ getNicePubDateString(end));
        for (HistoryStory st : thisYear.historyStoriesByMonth.get(i)) {
          if (st.cal != null) {
            long storyMS = st.cal.getTimeInMillis();
            //print(getNicePubDateString(st.cal) + "|");
            if (storyMS >= startMS && storyMS <= endMS) {
              range.add(st);
            }
          }
        }
        //range.addAll(thisYear.historyStoriesByMonth.get(i));  good
      }
    }
  }

  return range;
} // end getHistoryStoriesWithinRange


//
HashMap<Integer, IntDict> getGrams (int lowGramCount, int highGramCount, String[] sentences) {
  HashMap<Integer, IntDict> newGrams = new HashMap<Integer, IntDict>();
  for (int i = 2; i < 5; i++) {
    IntDict counter = countGrams(i, sentences);
    newGrams.put(i, counter);
  }
  return newGrams;
} // end getGrams


//
float getSimilarity(NYTStory nyt, HistoryStory hs) {
  float similarity = 0f;
  String[] nytHeadlineStripped = stripCommonWords(nyt.headline);
  String[] hsStoryStripped = stripCommonWords(hs.story);

  return similarity;
} // end getSimilarity



//
String[] stripCommonWords(String ss) {
  ss = stripMonths(ss);
  String[] strippedRaw = split(ss, " ");
  String[] stripped = new String[0];
  for (String s : strippedRaw) {
    if (commonWords.contains(s.toLowerCase())) {
    }
    else {
      stripped = (String[])append(stripped, s.toLowerCase());
    }
  }

  return stripped;
} // end stripCommonWords

//
String stripMonths(String ss) {
  ss = ss.toLowerCase();
  for (int i = 0; i < 12; i++) {
    ss = ss.replace(monthsByNumber.get(i).toLowerCase(), "");
  }
  return ss;
} // end stripMonths


//
IntDict countGrams(int n, String[] sentences) {
  IntDict counter = new IntDict();
  for (String s:sentences) {
    String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    for (int i = 0; i <= words.length - n; i++) {
      String ngram = "";
      for (int j = 0; j < n; j++) {
        ngram += words[i + j];
        if (j != n) ngram += " ";
      }
      counter.increment(ngram);
    }
  }
  counter.sortValuesReverse();
  return(counter);
} // end countGrams


//
// this will count the grams based on the pos in.
IntDict countGramsByPos(IntDict gram, String posIn, String[] sentences) {

  String[] posArray = RiTa.getPosTags(RiTa.stripPunctuation(posIn.toLowerCase()));
  int posArrayLength = posArray.length;

  for (String s:sentences) {
    String[] words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    if (words.length < posArrayLength) continue; // cut out if there arent enough words
    String[] sentencePosArray = new String[words.length];
    for (int i = 0; i < words.length; i++) sentencePosArray[i] = RiTa.getPosTags(words[i])[0];
    //for (int i = 0; i < words.length; i++) println(words[i] + ": " + sentencePosArray[i]); // debug to look at how the system is breaking up the text and assigning poss to them
    for (int i = 0; i < words.length - posArrayLength + 1; i++) {
      boolean foundMatch = true;
      String storage = "";
      for (int j = i; j < i + posArrayLength; j++) {
        if (posArray[j - i].equals(sentencePosArray[j])) {
          storage += words[j];
          if (j - i < posArrayLength - 1) storage += " ";
        }
        else {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        gram.increment(storage);
      }
    }
  }
  return gram;
} // end countGramsByPos

//
IntDict countOccurances(IntDict dictIn, String[] sentences) {
  String[] words, dictWords;
  int dictWordsLength = 0;
  IntDict occurances = new IntDict();
  for (String s:sentences) {
    words = RiTa.tokenize(RiTa.stripPunctuation(s.toLowerCase()));
    for (String dictKey : dictIn.keys()) {
      dictWords = split(dictKey, " ");
      if (words.length < dictWords.length) continue;
      dictWordsLength = dictWords.length;

      for (int i = 0; i < words.length - dictWordsLength + 1; i++) {
        boolean foundMatch = true;
        String storage = "";
        for (int j = i; j < i + dictWordsLength; j++) {
          if (dictWords[j - i].equals(words[j])) {
            storage += words[j];
            if (j - i < dictWordsLength - 1) storage += " ";
          }
          else {
            foundMatch = false;
            break;
          }
        }
        if (foundMatch) {
          occurances.increment(storage);
        }
      }
    }
  }
  return occurances;
} // end countOccurances

//
//
//
//
//
//
//


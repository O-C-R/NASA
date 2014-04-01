//
void populatePhrases() {
  int minGramCount = 0;
  int maxGramCount = 0;
  for (int i = 0; i < phrasesAll.size(); i++) {
    int sz = split(phrasesAll.get(i).phrase, " ").length;
    if (i == 0) minGramCount = maxGramCount = sz;
    minGramCount = (minGramCount < sz ? minGramCount : sz);
    maxGramCount = (maxGramCount > sz ? maxGramCount : sz);
  }
  println("min/maxGramCount: " + minGramCount + ", " + maxGramCount);


  for (HistoryStory hs : historyStoriesAll) {
    HashMap<Integer, IntDict> gramDict = new HashMap<Integer, IntDict>();
    String[] sentences = RiTa.splitSentences(hs.story);
    // develop all grams for this story
    for (int i = minGramCount; i <= maxGramCount; i++) {
      IntDict countGrams = countGrams(i, sentences);
      if (!gramDict.containsKey(i)) gramDict.put(i, new IntDict());
      IntDict oldDict = (IntDict)gramDict.get(i);
      if (oldDict.size() > 0) oldDict = addIntDicts(oldDict, countGrams);
      else oldDict = countGrams;
      gramDict.put(i, oldDict);
    } 

    // go through all phrases and add as appropriate
    for (Phrase p : phrasesAll) {
      int thisPhraseWordCount = p.phraseWordCount;
      IntDict thisIntDict = (IntDict)gramDict.get(thisPhraseWordCount);
      if (thisIntDict.hasKey(p.phrase)) {
        //println("MATCH: " + p.phrase + "   count: " + thisIntDict.get(p.phrase));
        int count = thisIntDict.get(p.phrase);
        p.addHistoryStory(hs, count);
        hs.addPhrase(p, count);
      }
    }
  }
} // end populatePhrases

//
void printMostPopularPhrases() {
  int printStoryCutoff = 5; // 5 good
  ArrayList<Phrase> ppAL = new ArrayList<Phrase>();
  for (Phrase p : phrasesAll) {
    if (p.historyStories.size() >= printStoryCutoff) { // minimum number of history stories here
      ppAL.add(p);
      p.totalMentions = p.getMentions(); // set the total mentions
      p.totalStories = p.historyStories.size();
    }
  }
  //ppAL = OCRUtils.sortObjectArrayListSimple(ppAL, "totalMentions");
  ppAL = OCRUtils.sortObjectArrayListSimple(ppAL, "totalStories");
  ppAL = OCRUtils.reverseArrayList(ppAL);

  PrintWriter output = createWriter("output/similarities.txt");
  int tempCount = 0;
  for (Phrase p : ppAL) {
    output.println(p + "        _unique stories: " + (findUniqueStories(p, ppAL)).size());
    ArrayList<Phrase> phrasesToExclude =new ArrayList<Phrase>();
    phrasesToExclude.add(p);
    ArrayList<HistoryStory> hs = p.getOrderedHistoryStories();
    ArrayList<PhraseDropOff> similars = getTopRelativeStories(phrasesToExclude, hs, ppAL, 0);

    //for (PhraseDropOff pd : similars) pd.makeChildren(3);

    //for (PhraseDropOff pd : similars) output.println(pd);

    // test to print out the furthest story to check if it contains all phrases
    if (tempCount == 0) {
      PrintWriter output2 = createWriter("output/testStory.txt");
      PhraseDropOff pd = similars.get(0);
      while (true) {
        if (pd.children.size() > 0) {
          pd = pd.children.get(0);
        }
        else break;
      }
      ArrayList<Phrase> lineage = pd.getPhraseLineage();
      for (int k = lineage.size() - 1; k >= 0; k--) output2.println(lineage.get(k));
      output2.println("..");
      for (int i = 0; i < pd.commonStories.size(); i++) {
        output2.println(pd.commonStories.get(i));
      }
      output2.flush();
      output2.close();
      tempCount++;
    }
  }
  output.flush();
  output.close();
} // end printMostPopularPhrases

//
ArrayList<HistoryStory> findUniqueStories(Phrase p, ArrayList<Phrase> phrasesIn) {
  ArrayList<HistoryStory> unique = new ArrayList<HistoryStory>();
  for (Map.Entry me : p.historyStories.entrySet()) unique.add((HistoryStory)me.getKey());
  HashMap<HistoryStory, Integer> allStories = new HashMap<HistoryStory, Integer>();
  for (Phrase pp : phrasesIn) {
    if (pp != p) {
      for (Map.Entry me : pp.historyStories.entrySet()) allStories.put((HistoryStory)me.getKey(), 0);
    }
  }
  for (int i = unique.size() - 1; i >= 0; i--) {
    if (allStories.containsKey(unique.get(i))) unique.remove(i);
  }
  return unique;
} // end findUniqueStories

//
ArrayList<PhraseDropOff>getTopRelativeStories (ArrayList<Phrase> phrasesToExclude, ArrayList<HistoryStory> storiesIn, ArrayList<Phrase> phrasesIn, int levelIn) {
  ArrayList<PhraseDropOff> topPhrases = new ArrayList<PhraseDropOff>();
  HashMap<Phrase, PhraseDropOff> topPhrasesHM = new HashMap<Phrase, PhraseDropOff>(); 
  //int maxToGet = 15;
  // this will make it so that as the levels go further the number of results become fewer
  int maxToGetLimit = 5;
  int minToGetLimit = 1;
  int maxToGet = constrain((int)map(levelIn, 0, 2, maxToGetLimit, minToGetLimit), minToGetLimit, maxToGetLimit);
  //for (Map.Entry me : p.historyStories.entrySet()) {
  for (HistoryStory thisStory : storiesIn) {
    //HistoryStory thisStory = (HistoryStory)me.getKey();
    for (Phrase pp : phrasesIn) {
      //if (pp != p) {
      if (!phrasesToExclude.contains(pp)) {
        for (Map.Entry you : pp.historyStories.entrySet()) {
          HistoryStory otherStory = (HistoryStory)you.getKey();
          if (thisStory == otherStory) {
            if (!topPhrasesHM.containsKey(pp)) topPhrasesHM.put(pp, new PhraseDropOff(pp));
            PhraseDropOff pd = (PhraseDropOff)topPhrasesHM.get(pp);
            pd.addSimilarStory(thisStory);
            pd.topPhrase = phrasesToExclude.get(0);
            topPhrasesHM.put(pp, pd);
          }
        }
      }
    }
  }

  for (Map.Entry me : topPhrasesHM.entrySet()) topPhrases.add((PhraseDropOff)me.getValue());
  topPhrases = OCRUtils.sortObjectArrayListSimple(topPhrases, "storyCount");
  topPhrases = OCRUtils.reverseArrayList(topPhrases);
  for (int i = topPhrases.size() - 1; i > maxToGet; i--) topPhrases.remove(i);

  return topPhrases;
} // end getTopRelativeStories


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
      counter.increment(ngram.trim());
    }
  }
  counter.sortValuesReverse();
  return(counter);
} // end countGrams

//
IntDict addIntDicts(IntDict a, IntDict b) {
  IntDict c = a.copy();
  for (String k : b.keys()) {
    if (!c.hasKey(k)) c.set(k, b.get(k));
    else c.add(k, b.get(k));
  }
  return c;
} // end addIntDicts

//
//
//
//


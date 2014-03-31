//
String[] gramPosPhrases = {
  "orbiting beyond Neptune", 
  "be awarded planethood", 
  "mission to the moon", 
  //"energy fluctuations", 
  "set in motion", 
  //"sound waves", 
  "gathered the data", 
  //"microscopic processes", 
  "examining the early universe", 
  "light and sound", 
  //"circumnavigated Antarctica", 
  "discovery of the sound", 
  "fall to earth"
};

//
//IntDict findTopNYTNGrams() {
void findTopNYTNGrams() {

  int count = 0;
  for (NYTStory nyt : nytStoriesAll) {
    IntDict nytGrams = new IntDict();
    //String[] nytSentences = RiTa.splitSentences(nyt.leadParagraph);
    String[] nytSentences;
    if (nyt.abstr.length() > 0) nytSentences = RiTa.splitSentences(nyt.abstr); // NOTE: looking through the abstract works way better than the lead paragraph
    else nytSentences = RiTa.splitSentences(nyt.snippet);
    for (String s : gramPosPhrases) {
      IntDict newDict = countGramsByPos(nytGrams, s, nytSentences);
      addIntDicts(nytGrams, newDict);
      for (String phrase : newDict.keys()) {
        if (!phraseKeeper.containsKey(phrase)) phraseKeeper.put(phrase, new PhraseReference(phrase));
        PhraseReference pr = (PhraseReference)phraseKeeper.get(phrase);
        pr.addNYTStory(nyt);
        phraseKeeper.put(phrase, pr);
      }
    }
    count++;
    //if (count > 1132) break;
  }

  println("made " + phraseKeeper.size() + " phraseKeepers");
  PrintWriter output = createWriter("output/prCheck-" + timeStamp + ".txt");
  for (Map.Entry me : phraseKeeper.entrySet()) {
    PhraseReference pr = (PhraseReference)me.getValue();
    if (pr.stories.size() > 2) output.println(pr);
  }
} // end  findTopNYTNGrams

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
//
//
//


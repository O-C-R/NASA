//

float fleschTest(String body) {
  String[] stringSplit;
  int syllableCounter = 0;
  int wordCounter = 0;
  int sentenceCounter = 0;
  int tempSyllableCount = 0; // needed to increment syllableCounter
  float fleschTestResults = 0;
  //println("NYTIMES:" + stringTest);
  String simplifiedString;
  float testResultAverage = 0;


  stringSplit = splitTokens(body, ", -");// determines the chars that break up to words
  // note: .?! are not included in this break up because they do not affect the syllable count anyway
  // and also because they are needed to indicate the end of the sentence
  stringSplit = wordEliminator(stringSplit);//USE THIS 
  wordCounter = stringSplit.length; // used in flesch test
  simplifiedString = join(stringSplit, " ");
  sentenceCounter = sentenceCounter(simplifiedString);  // pass the current string minus weird words
  // run the words through the counter
  for (int i = 0; i < stringSplit.length; i++) {
    tempSyllableCount = syllableCount(stringSplit[i]); // run the code
    syllableCounter = syllableCounter + tempSyllableCount;
  } // end syllable counter for loop

  return fleschTest(wordCounter, sentenceCounter, syllableCounter);
} // end fleschTest

// **************************FLESCH READING TEST SCORE CALCULATOR***************
float fleschTest (int totalWords, int totalSentences, int totalSyllables) {
  float testResults = 206.876-1.015*totalWords/totalSentences-84.6*totalSyllables/totalWords;
  return testResults;
} // end function fleschTest
// *****************************************************************************

// ********************************ELIMINATE PERIODS****************************
// this function is to be called last.. after the sentences have been tallied
// also eliminate other punctuation, add as necessary
// eliminated: . ' ( ) " | ; ? ! :
String[] eliminatePeriods (String[] stringsIn) {
  String[] eliminatedPeriods = new String[stringsIn.length];
  for (int i = 0; i < stringsIn.length; i++) {
    eliminatedPeriods[i] = stringsIn[i].replace(".", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("'", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace(")", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("(", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("\"", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("|", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("!", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("?", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace(";", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace("_", "");
    eliminatedPeriods[i] = eliminatedPeriods[i].replace(":", "");
  }  // end i loop for all words
  return eliminatedPeriods;
} // end eliminatePeriods



// **************************SENTENCE COUNTER***********************************
// to count the sentences..
// avoid duplicate punctuation
// assume that there is at least one sentence
// ending w/o punctuation counts as a sentence
int sentenceCounter (String inputString) {
  int sentenceCounter = 0;
  inputString= inputString.toLowerCase();
  boolean emptySentence = false; // if a sentence just kinda ends w/o punctuation
  for (int i = 1; i < inputString.length()-1; i++) { // run through letters, start at 1
    if ((inputString.charAt(i+1) == 'a')||(inputString.charAt(i+1) == 'b')||
      (inputString.charAt(i+1) == 'c')||(inputString.charAt(i+1) == 'd')||
      (inputString.charAt(i+1) == 'e')||(inputString.charAt(i+1) == 'f')||
      (inputString.charAt(i+1) == 'g')||(inputString.charAt(i+1) == 'h')||
      (inputString.charAt(i+1) == 'i')||(inputString.charAt(i+1) == 'j')||
      (inputString.charAt(i+1) == 'k')||(inputString.charAt(i+1) == 'l')||
      (inputString.charAt(i+1) == 'm')||(inputString.charAt(i+1) == 'n')||
      (inputString.charAt(i+1) == 'o')||(inputString.charAt(i+1) == 'p')||
      (inputString.charAt(i+1) == 'q')||(inputString.charAt(i+1) == 'r')||
      (inputString.charAt(i+1) == 's')||(inputString.charAt(i+1) == 't')||
      (inputString.charAt(i+1) == 'u')||(inputString.charAt(i+1) == 'v')||
      (inputString.charAt(i+1) == 'w')||(inputString.charAt(i+1) == 'x')||
      (inputString.charAt(i+1) == 'y')||(inputString.charAt(i+1) == 'z')) {
      emptySentence= true;
    }
    // test for the last punctuation mark - assuming .?! are the enders
    if ((inputString.charAt(i)=='.')||(inputString.charAt(i)=='!')||
      (inputString.charAt(i)=='?')) {
      if ((inputString.charAt(i-1)!='.')&&(inputString.charAt(i-1)!='!')&&
        (inputString.charAt(i-1)!='?')&&(inputString.charAt(i-1)!='~')&&
        (inputString.charAt(i+1)==' ')) {
        sentenceCounter++;
        emptySentence=false;
      } // end backwards check
      // check for mr.
      if ((inputString.charAt(i-1)=='r')&&(inputString.charAt(i-2)=='m')) {
        sentenceCounter--;
      }
      // check for mrs.
      if ((inputString.charAt(i-1)=='s')&&(inputString.charAt(i-2)=='r')&&(inputString.charAt(i-3)=='m')) {
        sentenceCounter--;
      }      
      // check for dr.
      if ((inputString.charAt(i-1)=='r')&&(inputString.charAt(i-2)=='d')) {
        sentenceCounter--;
      } 
      // check for st.
      if ((inputString.charAt(i-1)=='t')&&(inputString.charAt(i-2)=='s')) {
        sentenceCounter--;
      }
    } // end punctuation check
  } // end character cycle
  if (emptySentence) {
    sentenceCounter++; // if it is an empty sentence.. add another count
  }// end if
  // println("SENTENCE COUNTER= " + sentenceCounter);
  return sentenceCounter;
}// end function sentenceCounter
// *****************************************************************************

// *************************ELIMINATE DUPLICATES********************************
// note: run this after word eliminator so everything is lowercase
String[] eliminateDuplicates(String[] inputStrings) {
  String[] eliminatedDuplicates = new String[0];
  for (int i = 0; i < inputStrings.length; i++) {
    boolean okToAdd = true;
    for (int j = 0; j < eliminatedDuplicates.length; j++) {
      if (inputStrings[i].equals(eliminatedDuplicates[j])) {
        okToAdd = false;
      } // end if
    } // end j for
    if (okToAdd) {
      eliminatedDuplicates = (String[])append(eliminatedDuplicates, inputStrings[i]);
    } // end ok to add
  } // end i for
  return eliminatedDuplicates;
} // end eliminateDuplicates

// ***************************ELIMINATE LIST 2**********************************
// will eliminate list 2 words from list one
String[] eliminateList2Words(String[] inputStrings, String[] list2InputStrings) {
  String[] returnList = new String[0];
  for (int i = 0; i < inputStrings.length; i++) {
    boolean okToAddWord = true;
    // check against list2InputStrings list
    for (int j = 0; j < list2InputStrings.length; j++) {
      if (inputStrings[i].equals(list2InputStrings[j])) {
        okToAddWord = false;
        //print("Eliminating: " + badWords[j] + " ");
      } // end if check for equals
    } // end j for
    if (okToAddWord) {
      returnList = (String[])append(returnList, inputStrings[i]);
    } // end if adding word
  } // end i for
  return returnList;
} // end eliminateList2Words


// ***************************WORD ELIMINATOR***********************************
// eliminates words that begin with # or @ or have &apos in it
String[] wordEliminator (String[] inputStrings) {
  String[] returnList;
  ArrayList tempReturnList = new ArrayList();
  for (int i = 0; i< inputStrings.length; i++) { // cycle through the input list
    boolean okToAddWord = true;
    inputStrings[i] = inputStrings[i].toLowerCase(); // convert all to lowercase
    if ((inputStrings[i].charAt(0)=='#')||
      (inputStrings[i].charAt(0)== '@')) {
      okToAddWord = false;
    } // end # and @ check
    // start 'http:' and '&apos' check
    if (inputStrings[i].length()>5) {
      if ((inputStrings[i].charAt(0) == 'h')&&(inputStrings[i].charAt(1) == 't')&&
        (inputStrings[i].charAt(2)=='t')&&(inputStrings[i].charAt(3)=='p')&&
        (inputStrings[i].charAt(4)==':')) {
        okToAddWord = false;
        //println("got the the 'http:'");
      }// end http check
      for (int j = 0; j<inputStrings[i].length()-5; j++) {
        if ((inputStrings[i].charAt(j) == '&')&&(inputStrings[i].charAt(j+1) == 'a')&&
          (inputStrings[i].charAt(j+2)=='p')&&(inputStrings[i].charAt(j+3)=='o')&&
          (inputStrings[i].charAt(j+4)=='s')) {
          okToAddWord = false;
          //println("got the the '&apos'");
        }// end &apos check
      } // end for j
    }// end if for length check
    // eliminate abbreviations
    if (inputStrings[i].length()>3) {
      if ((inputStrings[i].charAt(inputStrings[i].length()-1)=='.')&&(inputStrings[i].charAt(inputStrings[i].length()-3)=='.')) {
        //// println("eliminated an abbreviation: " + inputStrings[i]);
        okToAddWord = false;
      }
    }

    // check for " - + =

    if (inputStrings[i].length() == 1) {
      if ((inputStrings[i].charAt(0) == '"')||(inputStrings[i].charAt(0) == '-')|| 
        (inputStrings[i].charAt(0) == '=')||(inputStrings[i].charAt(0) == '+')) {
        okToAddWord = false;
      } // end " and - and = check
    } // end " check

    //}// end if for length check
    if (okToAddWord) {// checks if it is ok to add word
      tempReturnList.add((String) inputStrings[i]);// add the good values to the temp list
    } // end if ok to add word
  } // end .adding for



  returnList = new String[tempReturnList.size()];
  for (int i = 0; i < tempReturnList.size(); i++) {
    returnList[i]=(String)tempReturnList.get(i);
  }// end list transfer
  return returnList;
}// end function 'WORD ELIMINATOR'
//****************************************************************************


// ***************************WORD THINNER ***********************************
String[] wordThinner(String[] inputStrings) {
  String[] returnList = new String[0];
  String[] badWords= {
    "the", "of", "to", "and", "a", "in", "is", "it", "you", "that", "he", "was", "for", "on", 
    "are", "with", "as", "i", "his", "they", "be", "at", "one", "have", "this", "from", "or", "had", "by", "hot", "but", "some", 
    "what", "there", "we", "can", "out", "other", "were", "all", "your", "when", "up", "use", "word", "how", "said", "an", 
    "each", "she", "which", "do", "their", "time", "if", "will", "way", "about", "many", "then", "them", "would", "write", "like", "so", "these", 
    "her", "long", "make", "thing", "see", "him", "two", "has", "look", "more", "day", "could", "go", "come", "did", "my", "sound", "no", "most", "number", "who", 
    "over", "know", "than", "call", "first", "people", "may", "down", "side", "been", "now", "find", "any", "new", "work", "part", "take", "get", "place", 
    "made", "live", "where", "after", "back", "only", "round", "man", "year", "came", "show", "every", "good", "me", "give", "our", "under", "name", "very", 
    "through", "just", "form", "much", "great", "think", "say", "help", "low", "line", "before", "turn", "cause", "same", "mean", "differ", "move", "right", "boy", 
    "old", "too", "does", "tell", "sentence", "set", "three", "want", "air", "well", "also", "play", "small", "end", "put", "home", "read", "hand", "port", "large", "spell", 
    "add", "even", "land", "here", "must", "big", "high", "such", "follow", "act", "why", "ask", "men", "change", "went", "light", "kind", "off", "need", "house", "picture", 
    "try", "us", "again", "animal", "point", "mother", "world", "near", "build", "self", "earth", "father", ":", ".", "-", "!", "?", "@", "#", "&"
  };
  for (int i = 0; i < inputStrings.length; i++) {
    boolean okToAddWord = true;
    // check for 0 length or 1 length
    if (inputStrings[i].length() < 2) {
      okToAddWord = false;
    } // end if
    // check against badWord list
    for (int j = 0; j < badWords.length; j++) {
      if (inputStrings[i].equals(badWords[j])) {
        okToAddWord = false;
        //print("Eliminating: " + badWords[j] + " ");
      } // end if check for equals
    } // end j for
    if (okToAddWord) {
      returnList = (String[])append(returnList, inputStrings[i]);
    } // end if adding word
  } // end i for
  return returnList;
} // end function wordThinner


// ***************************SYLLABLE COUNTER**********************************
int syllableCount(String inputString) {
  int syllableCount = 0;
  inputString= inputString.toLowerCase();
  for (int i = 0; i < inputString.length()-1; i++) { // test for the vowel/double vowels
    boolean firstCharIsVowel = false;
    boolean secondCharIsVowel = false;
    if ((inputString.charAt(i) == 'a')||(inputString.charAt(i) == 'e')||(inputString.charAt(i) == 'i')||
      (inputString.charAt(i) == 'o')||(inputString.charAt(i) == 'u')) {
      firstCharIsVowel = true;
    } // end first vowel check if
    else {
      firstCharIsVowel = false;
    } // end first vowel check else  
    if ((inputString.charAt(i+1) == 'a')||(inputString.charAt(i+1) == 'e')||(inputString.charAt(i+1) == 'i')||
      (inputString.charAt(i+1) == 'o')||(inputString.charAt(i+1) == 'u')) {
      secondCharIsVowel = true;
    } // end first vowel check if
    else {
      secondCharIsVowel = false;
    } // end first vowel check else      
    if (firstCharIsVowel&&!secondCharIsVowel) {
      syllableCount++;
    } // end initial if
  } // end for

  // check for an ending in an es condition
  // if it does, then it subtracts a syllableCount [because it added one earlier]
  // note, follies resulting from 'ces' 'ges' 'ies' 'ses' are made up for later
  if ((inputString.length()>1)&&(inputString.charAt(inputString.length()-1) == 's')&&
    (inputString.charAt(inputString.length()-2) == 'e')) { // check if it is at least 2 syllables
    // println("ends in 'es', decrement");
    syllableCount--;
  } // do nothing


  // now check if the last letter is an e and 
  // whether or not the previous letter is a vowel too, except 'e'
  if (inputString.length()>1) {
    if ((inputString.charAt(inputString.length()-1) == 'a')||(inputString.charAt(inputString.length()-1) == 'i')||
      (inputString.charAt(inputString.length()-1) == 'o')||(inputString.charAt(inputString.length()-1) == 'u')) {
      // println("ends in a vowel, not 'e', increment counter");
      syllableCount++;
    } // end first vowel check if
    else {
      //println("does not end in a vowel other than 'e'");
    } // end first vowel check else
  } // end if to check for length  

  // now check to see if the first two letters are 're' and the next is a consonant  
  // if it is 're' then a vowel it will add to the counter
  // if it is 're' then a constant it will not
  if (inputString.length()>2) { // test if string is 3+ letters, otherwise skip
    char firstLetter = inputString.charAt(0);
    char secondLetter = inputString.charAt(1);
    char thirdLetter = inputString.charAt(2);
    boolean addReVowel01 = false; // for each check..
    boolean addReVowel02 = false;
    boolean addReVowel03 = false;
    // test for 're' first
    if ((firstLetter == 'r')&&(secondLetter == 'e')) {
      if ((thirdLetter == 'a')||(thirdLetter == 'e')||
        (thirdLetter == 'i')||(thirdLetter == 'o')||(thirdLetter == 'u')) {
        if ((inputString.length()>3)&&(inputString.charAt(3) =='d')) {// if it starts with 'read'
        } // end if
        else {
          syllableCount++;
          // println("the word starts with: " + firstLetter + secondLetter  + thirdLetter + ", increase vowel counter");
        } // end else
      } // end third letter vowel check
    } // end RE counter implementer
  } // end if

  // TWO LETTER ENDING CHECKS:
  if (inputString.length()>1) { // test if string is 2+ letters, otherwise skip
    char lastLetter = inputString.charAt(inputString.length()-1);
    char secondToLastLetter = inputString.charAt(inputString.length()-2);

    // S ENDING CONDITION
    if ((inputString.length()>2)&&(inputString.charAt(inputString.length()-1) == 's')) { // if it ends in 's'
      lastLetter = inputString.charAt(inputString.length()-2);
      secondToLastLetter = inputString.charAt(inputString.length()-3);
    } // end s condition
    // HE condition
    if ((secondToLastLetter == 'h')&&(lastLetter == 'e')) { // 'he' check
      // println("the last letters are: " + secondToLastLetter + lastLetter  + ", increment counter");
      syllableCount++;
    } // end 'he' check
  }// end two letter endings

  // test for three letter endings: 
  //
  if (inputString.length()>2) { // test if string is 3+ letters, otherwise skip

    char lastLetter = inputString.charAt(inputString.length()-1);
    char secondToLastLetter = inputString.charAt(inputString.length()-2);
    char thirdToLastLetter = inputString.charAt(inputString.length()-3);
    // GES condition - note, no 's' condition with this one
    if ((lastLetter == 's')&&(secondToLastLetter == 'e')&&(thirdToLastLetter == 'g')) {
      // println ("ends in 'ges', increment");
      syllableCount++;
    } // end GES
    // CES condition - note, no 's' condition with this one
    if ((lastLetter == 's')&&(secondToLastLetter == 'e')&&(thirdToLastLetter == 'c')) {
      // println ("ends in 'ces', increment");
      syllableCount++;
    } // end GES
    // IES condition - note, no 's' condition with this one either
    if ((lastLetter == 's')&&(secondToLastLetter == 'e')&&(thirdToLastLetter == 'i')) {
      // println ("ends in 'ces', increment");
      syllableCount++;
    } // end IES
    // SES condition - note, no 's' condition with this one either
    if ((lastLetter == 's')&&(secondToLastLetter == 'e')&&(thirdToLastLetter == 's')) {
      // println ("ends in 'ces', increment");
      syllableCount++;
    } // end SES
    // S ENDING CONDITION
    if ((inputString.length()>3)&&(inputString.charAt(inputString.length()-1) == 's')) { // if it ends in 's'
      lastLetter = inputString.charAt(inputString.length()-2);
      secondToLastLetter = inputString.charAt(inputString.length()-3);
      thirdToLastLetter = inputString.charAt(inputString.length()-4);
    } // end s condition
    if ((secondToLastLetter == 'l')&&(lastLetter == 'e')) { // 're' check
      // println("the last letters are: " + secondToLastLetter + lastLetter  + ", increment counter");
      if ((thirdToLastLetter != 'e')&&(thirdToLastLetter != 'a')) {
        syllableCount++;
        // println("word ends in 'le', increment");
      }// end 'ere' and 'are' check
    } // end 're' check
    if ((thirdToLastLetter == 't')&&(secondToLastLetter == 'h')&&(lastLetter == 'm')) {
      // println("ends in 'thm', increment");
      syllableCount++;
    }// end 'thm' check
  } // end ending if for length test

  // CONSONANT + Y anywhere will increment the counter 
  // except for 'ELY'
  if (inputString.length()>1) { // test if string is 2+ letters, otherwise skip
    for (int i = 0; i < inputString.length()-1; i++) {
      char firstLetter = inputString.charAt(i);
      char secondLetter = inputString.charAt(i+1);
      //check to see if the first letter is a consonant
      if ((firstLetter != 'a')&&(firstLetter!='e')&&(firstLetter!='i')&&
        (firstLetter!='o')&&(firstLetter!='u')) {
        if (secondLetter == 'y') { // if the first is a cons and the second is y
          // println("a 'y' is preceeded by a consonant, increment");
          syllableCount++;
        } // end y check
      }// end consonant check
    } // end for loop
  } // end length check and 'consonant + y' check
  // check for ELY 
  if (inputString.length()>2) { // test if string is 3+ letters, otherwise skip
    for (int i = 0; i < inputString.length()-2; i++) {
      char firstLetter = inputString.charAt(i);
      char secondLetter = inputString.charAt(i+1);
      char thirdLetter = inputString.charAt(i+2);
      //check to see if the first letter is a consonant
      if (firstLetter == 'e') {
        if ((secondLetter != 'a')&&(secondLetter!='e')&&(secondLetter!='i')&&
          (secondLetter!='o')&&(secondLetter!='u')) {
          if (thirdLetter == 'y') { // if the first is a cons and the second is y
            // println("ely condition, decrement");
            syllableCount--; // SUBTRACT from the counter
          } // end y check
        }// end consonant check
      } // end first letter e check
    } // end for loop
  } // end length check and 'consonant + y' check
  // THREE LETTER ENDING CHECK
  if (inputString.length()>2) {// test for 3+ letters
    char lastLetter = inputString.charAt(inputString.length()-1);
    char secondToLastLetter = inputString.charAt(inputString.length()-2);
    char thirdToLastLetter = inputString.charAt(inputString.length()-3);
    if ((lastLetter == 'e')&&(secondToLastLetter=='e')) {
      if ((thirdToLastLetter!='a')||(thirdToLastLetter!='e')||(thirdToLastLetter!='i')||(thirdToLastLetter!='o')||(thirdToLastLetter!='u')) {
        syllableCount++;
      }
    }
  }

  // VOWEL + ING at end will increment the counter 
  if (inputString.length()>3) { // test if string is 4+ letters, otherwise skip
    char lastLetter = inputString.charAt(inputString.length()-1);
    char secondToLastLetter = inputString.charAt(inputString.length()-2);
    char thirdToLastLetter = inputString.charAt(inputString.length()-3);
    char fourthToLastLetter = inputString.charAt(inputString.length()-4);
    //check to see if the first letter is a consonant
    if ((lastLetter == 'g')&&(secondToLastLetter=='n')&&(thirdToLastLetter=='i')) {
      if ((fourthToLastLetter == 'a')||(fourthToLastLetter == 'e')||(fourthToLastLetter == 'i')
        ||(fourthToLastLetter == 'o')||(fourthToLastLetter == 'u')) { // if the first is a cons and the second is y
        // println("a vowel plus 'ing', increment");
        syllableCount++;
      } // end vowel check
    }// end 'ing' check
  } // end length check and vowel + 'ing' check
  // check for vowel plus 'ing'

  return (syllableCount);
}// end function syllableCount

//
//
//
//
//


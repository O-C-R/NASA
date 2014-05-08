// this sketch will just look at the output for the typeAlongCurve sketch and see which words appaear in multiple buckets

import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Collections;

HashMap<String, Term> terms = new HashMap<String, Term>();
ArrayList<String> allTerms = new ArrayList<String>();
int totalCount = 0;

void setup() {
  OCRUtils.begin(this);
  String[] files = OCRUtils.getFileNames(sketchPath("") + "../../TypeAlongCurve06a/bucketTextUsed/20140505135105", false);
  for (int i = 0; i < files.length; i++) {
    if (!files[i].contains("byPos.txt")) continue;
    String bucketName = splitTokens(files[i], "/")[splitTokens(files[i], "/").length - 1];
    bucketName = split(bucketName, "-")[0];
    String[] allLines = loadStrings(files[i]);
    for (int k = 0; k < allLines.length; k++) {
      String term = split(allLines[k], ",")[1];
      term = term.replace("|", ".").replace("}", " ").replace("{", " ");
      allTerms.add(term + "+" + bucketName);
      totalCount++;

      if (isVerb(term)) continue;
      if (!terms.containsKey(term)) {
        terms.put(term, new Term(term));
      }
      Term oldTerm = (Term)terms.get(term);
      oldTerm.addBucket(bucketName);
      terms.put(term, oldTerm);
    }
  }

  ArrayList<Term> termsAL = new ArrayList<Term>();
  for (Map.Entry me : terms.entrySet()) {
    termsAL.add((Term)me.getValue());
  }

  termsAL = OCRUtils.sortObjectArrayListSimple(termsAL, "bucketCount");
  termsAL = OCRUtils.reverseArrayList(termsAL);

  PrintWriter output = createWriter("output/output.txt");
  for (Term t : termsAL) output.println(t);
  output.flush();
  output.close();

  // then do the other stuff
  println("total count of terms: " + totalCount);
  println("size of allTerms: " + allTerms.size());
  int termWordCount = 0;
  for (String s : allTerms) termWordCount += split(s.replace("|", ".").replace("}", " ").replace("{", " "), " ").length;
  println("termWordCount: " + termWordCount);

  /*
  ArrayList<String> temp = new ArrayList<String>();
   for (String s : allTerms) if (!isVerb(s)) temp.add(s);
   Collections.sort(temp);
   for (String s : temp) println(s);
   */

  println("done");
  exit();
} // end setup


//
boolean isVerb(String s) {
  /*
  if (split(s, " ").length == 1) {
    if (s.length() > 2) {
      if ((s.substring(s.length() - 3)).equals("ing")) return true;
    }
  }
  */
  if (s.trim().equals("term")) return true;
  return false;
} // end isVerb


//
class Term {
  HashMap<String, Integer> buckets = new HashMap<String, Integer>();
  int bucketCount = 0;
  String term = "";

  //
  Term (String term) {
    this.term = term;
  } // end constructor

  //
  void addBucket(String b) {
    if (!buckets.containsKey(b)) {
      buckets.put(b, 0);
      bucketCount++;
    }
  } // end addBucket

  //
  String toString() {
    String builder = formattedTerm() + "--bucketCount: " + nf(bucketCount, 2) + " - ";
    for (Map.Entry me : buckets.entrySet()) builder += (String)me.getKey() + " - "; 
    return builder;
  } // end toString

  //
  String formattedTerm() {
    int targetLength = 38;
    String spaces = "";
    for (int i = 0; i < targetLength - term.length(); i++) spaces += " ";
    return term.replace("|", ".").replace("}", " ") + spaces;
  } // end formattedTerm
} // end class Term

//
//
//
//


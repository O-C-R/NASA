//
HashMap<String, Integer> getMonths() {
  HashMap<String, Integer> newMonths = new HashMap<String, Integer>();
  newMonths.put("january", 0);
  newMonths.put("february", 1);
  newMonths.put("march", 2);
  newMonths.put("april", 3);
  newMonths.put("may", 4);
  newMonths.put("june", 5);
  newMonths.put("july", 6);
  newMonths.put("august", 7);
  newMonths.put("september", 8);
  newMonths.put("october", 9);
  newMonths.put("november", 10);
  newMonths.put("december", 11);
  return newMonths;
} // end getMonths

//
HashMap<Integer, String>getMonthsByNumber(HashMap<String, Integer> monthsByStringIn) {
  HashMap<Integer, String> newMonths = new HashMap<Integer, String>();
  for (Map.Entry me : monthsByStringIn.entrySet()) {
    newMonths.put((Integer)me.getValue(), (String)me.getKey());
  }
  return newMonths;
} // end getMonthsByNumber

//
int getMonthNumber(String monthIn) {
  monthIn = monthIn.toLowerCase();
  if (monthIn.equals("january")) return 1;
  else if (monthIn.equals("february")) return 2;
  else if (monthIn.equals("march")) return 3;
  else if (monthIn.equals("april")) return 4;
  else if (monthIn.equals("may")) return 5;
  else if (monthIn.equals("june")) return 6;
  else if (monthIn.equals("july")) return 7;
  else if (monthIn.equals("august")) return 8;
  else if (monthIn.equals("september")) return 9;
  else if (monthIn.equals("october")) return 10;
  else if (monthIn.equals("november")) return 11;
  else return 12;
} // end getMonthNumber

//
boolean isMonth(String testIn) {
  testIn = testIn.trim();
  testIn = testIn.toLowerCase();
  testIn = testIn.replace(":", "");
  if (monthsByString.containsKey(testIn)) return true;
  return false;
} // end isMonth

//
////
//
//
////
//
//
////
//
//
////
//


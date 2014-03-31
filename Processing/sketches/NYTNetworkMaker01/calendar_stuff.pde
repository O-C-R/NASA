//
Calendar getCalFromDataTime(String dataTimeIn) {
  DateFormat format = new SimpleDateFormat("yyyyMMdd");
  Date d = new Date();
  try {
    d = format.parse(dataTimeIn);
  } // end try
  catch(Exception e) {
  } // end catch
  Calendar thisCalDate = Calendar.getInstance();
  thisCalDate.setTime(d);
  return thisCalDate;
} // end getCalFromDataTime

//
Calendar getCalFromNYTPubTime(String dataTimeIn) {
  String simpleTime = splitTokens(dataTimeIn, "T")[0];
  DateFormat format = new SimpleDateFormat("yyyy-MM-dd"); // comes in as yyyy-MM-dd
  Date d = new Date();
  try {
    d = format.parse(simpleTime);
  } // end try
  catch(Exception e) {
  } // end catch
  Calendar thisCalDate = Calendar.getInstance();
  thisCalDate.setTime(d);
  return thisCalDate;
} // end getCalFromNYTPubTime

// 
String getNicePubDateString(Calendar c) {
  return nf(c.get(Calendar.YEAR), 4) + nf(c.get(Calendar.MONTH) + 1, 2) + nf(c.get(Calendar.DAY_OF_MONTH), 2);
} // end getNicePubDateString


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
//
//
//
//
//


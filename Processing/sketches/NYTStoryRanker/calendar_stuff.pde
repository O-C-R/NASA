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
//
//
//
//
//


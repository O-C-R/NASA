Calendar getCalFromDataTime(String dataTimeIn) {
  DateFormat format = new SimpleDateFormat("yyyyMMdd"); // see http://www.roseindia.net/java/java-conversion/StringToDate.shtml
  Date d = new Date();
  try {
    d = format.parse(dataTimeIn);
  } // end try
  catch(Exception e) {
    //println("error - in getCalFromDataTime.  could not parse date: " + dataTimeIn);
  } // end catch
  // we will use the Calendar class: http://docs.oracle.com/javase/1.4.2/docs/api/java/util/Calendar.html
  Calendar thisCalDate = Calendar.getInstance();

  thisCalDate.setTime(d);
  //thisCalDate.setTimeZone(TimeZone.getTimeZone("UTC"));
  // samples to get the individual elements fom the Calendar object
  /*
     println(thisCalDate);
   println("year:         " + thisCalDate.get(Calendar.YEAR));
   println("month:        " + thisCalDate.get(Calendar.MONTH)); // note that it returns months from 0 to 11
   println("day:          " + thisCalDate.get(Calendar.DAY_OF_MONTH));
   println("hour:         " + thisCalDate.get(Calendar.HOUR_OF_DAY));
   println("minute:       " + thisCalDate.get(Calendar.MINUTE));
   println("second:       " + thisCalDate.get(Calendar.SECOND));  
   println("milliseconds: " + thisCalDate.getTimeInMillis());
   */
  return thisCalDate;
} // end getCalFromDataTime


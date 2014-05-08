// the different status codes used after trying to place a term
final String POPULATE_STATUS_EMPTY = "emtpy";
final String POPULATE_STATUS_SUCCESS = "success";
final String POPULATE_STATUS_FAIL = "fail";

// the ways in which the bucket data is read in and/or reduced
final int INPUT_DATA_LINEAR = 0; // will take the full bucket value
final int INPUT_DATA_LOG = 1; // log of the bucket value
final int INPUT_DATA_HALF = 2; // half of the bucket value
final int INPUT_DATA_DOUBLE = 3; // double of the bucket value
final int INPUT_DATA_TRIPLE = 4; // triple of the bucket value
final int INPUT_DATA_CUBE = 5; // cube the bucket value
final int INPUT_DATA_SQUARE = 6; // square the data
final int INPUT_DATA_SQUARE_ROOT = 7; // squareroot the data
final int INPUT_DATA_MULTIPLIED_THEN_SQUARE_ROOT = 111; // 10000 * the value, then squareroot the data
final int INPUT_DATA_CUBE_ROOT = 8; // cuberoot the data
final int INPUT_DATA_MULTIPLIED_THEN_CUBE_ROOT = 9; // 10000 * the value, then cuberoot the data
final int INPUT_DATA_DEBUG = 10; // assign an static number
final int INPUT_DATA_NOISE = 11; // just noise, not data

// the different types of label alignments
final int LABEL_ALIGN_LEFT = LEFT;
final int LABEL_ALIGN_CENTER = CENTER;
final int LABEL_ALIGN_RIGHT = RIGHT;
final int LABEL_VERTICAL_ALIGN_BASELINE = BASELINE;
final int LABEL_VERTICAL_ALIGN_TOP = TOP;

// color stuff
final int dateColor = #40568A;
final int bgColor = #0D0C2A;
final int flareColor = #7772B4;


// how to make the splines
final int MAKE_SPLINES_TOP_ONLY = 0; // will make the heights from the bottom of the two splines.  eg. baseline text
final int MAKE_SPLINES_BOTTOM_ONLY = 1; // will make the heights from the top of the two splines.  eg. top aligned text
final int MAKE_SPLINES_MIXED = 2; // will split the splines in half, making it go up from the bottom middle, and down from the same bottom middle


//
//
//
//


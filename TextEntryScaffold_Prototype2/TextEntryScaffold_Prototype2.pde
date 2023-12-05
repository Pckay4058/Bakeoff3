import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;

//Variables for my silly implementation. You can delete this:

int index1 = 0;
int index2 = 0;
int index3 = 0;

char[][] letters1 = {{'a','b','c'},{'d','e','f'},{'g',' ',' '}};
char[][] letters2 = {{'h','i','j'},{'k','l','m'},{'n','o','p'}};
char[][] letters3 = {{'q','r','s'},{'t','u','v'},{'w','x','y'},{'z',' ',' '}};

char letter3_ = 'c';
char letter2_ = 'b';
char letter1_ = 'a';

char letter3_2 = 'j';
char letter2_2 = 'i';
char letter1_2 = 'h';

char letter3_3 = 's';
char letter2_3 = 'r';
char letter1_3 = 'q';

long cooldownTime = 155;
long lastButtonTime = 0;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  //noCursor();
  watch = loadImage("watchhand3smaller.png");
  //finger = loadImage("pngeggSmaller.png"); //not using this
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  buttonLogic();
  
   //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!",400,200); //output
    text("Total time taken: " + (finishTime - startTime),400,220); //output
    text("Total letters entered: " + lettersEnteredTotal,400,240); //output
    text("Total letters expected: " + lettersExpectedTotal,400,260); //output
    text("Total errors entered: " + errorsTotal,400,280); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm,400,300); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors,1,3),400,320); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty,400,340);
    text("WPM w/ penalty: " + (wpm-penalty),400,360); //yes, minus, because higher WPM is better
    return;
  }
  
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    //example design draw code
    fill(255, 0, 0, 85); //red buttons
    rect(340, 436, 30, 24);
    rect(370, 436, 30, 24);
    rect(400, 436, 30, 24);
    fill(0, 255, 0, 85); //green buttons
    rect(340, 412, 30, 24);
    rect(370, 412, 30, 24);
    rect(400, 412, 30, 24);
    
    fill(235, 242, 137, 85);
    rect(430, 340, 30, 60, 0, 6, 0, 0);
    
    fill(176, 174, 250, 85);
    rect(430, 400, 30, 60, 0, 0, 8, 0);
    
    textAlign(CENTER);
    fill(200);
    text("" + letters1[index1][1], 356, 382); //draw current letter
    text("" + letters1[index1][2], 356, 406);
    
    text("" + letters2[index2][1], 386, 382); //draw current2 letter
    text("" + letters2[index2][2], 386, 406);
    
    text("" + letters3[index3][1], 415, 382); //draw current2 letter
    text("" + letters3[index3][2], 415, 406);
    
    fill(255, 243, 0);
    text("" + letters1[index1][0], 356, 360);
    text("" + letters2[index2][0], 386, 360);
    text("" + letters3[index3][0], 415, 360);
    
    noFill();
    stroke(255, 255, 255);
    //circle(340, 400, 15); //R middle left hand side
    //circle(400, 400, 15); //G middle middle
    //circle(340, 340, 15); //letter Top left hand side
    //circle(390, 340, 15);
    //First column on the left
    rect(340, 340, 30, 24, 2, 0, 0, 0);
    rect(340, 364, 30, 24);
    rect(340, 388, 30, 24);
    rect(340, 412, 30, 24);
    rect(340, 436, 30, 24, 0, 0, 0, 6);
    //middle column
    rect(370, 340, 30, 24);
    rect(370, 364, 30, 24);
    rect(370, 388, 30, 24);
    rect(370, 412, 30, 24);
    rect(370, 436, 30, 24);
    //Third column
    rect(400, 340, 30, 24);
    rect(400, 364, 30, 24);
    rect(400, 388, 30, 24);
    rect(400, 412, 30, 24);
    rect(400, 436, 30, 24);
    //fourth column
    rect(430, 340, 30, 60, 0, 6, 0, 0);
    //rect(420, 370, 40, 30);
    //rect(420, 400, 40, 30);
    //rect(420, 430, 40, 30, 0, 0, 8, 0);
    rect(430, 400, 30, 60, 0, 0, 8, 0);
    fill(0);
    noStroke();
    
    fill(200);
    //rotate(radians(90));
    text("<", 445, 380);
    text("_", 445, 430);
    
    //rotate(radians(-90));
  }
 
 
  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
void buttonLogic()
{
  long time = System.currentTimeMillis();
  if((time - lastButtonTime) > cooldownTime){
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    //width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2
    if (mousePressed && didMouseClick(340, 412, 30, 24)) //list 1 reverse
    {
      index1--;
      if(index1<0){
        index1=2;
      }
    }
    if (mousePressed && didMouseClick(370, 412, 30, 24)) //list 2 reverse
    {
      index2--;
      if(index2<0){
        index2=2;
      }
    }
    if (mousePressed && didMouseClick(400, 412, 30, 24)) //list 2 reverse
    {
      index3--;
      if(index3<0){
        index3=3;
      }
    }
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    //width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2
    
    //width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2 rearrangement
    //
    if (mousePressed && didMouseClick(340, 436, 30, 24)) //list 1 forward
    {
      index1++;
      if(index1>2){
        index1=0;
      }
    }
    if (mousePressed && didMouseClick(370, 436, 30, 24)) //list 2 forward
    {
      index2++;
      if(index2>2){
        index2=0;
      }
    }
    if (mousePressed && didMouseClick(400, 436, 30, 24)) //list 2 forward
    {
      index3++;
      if(index3>3){
        index3=0;
      }
    }
    lastButtonTime = System.currentTimeMillis();
  }
}

int lettersTill(){
  int diff = 0;
  return diff;
}

void mousePressed()
{
  //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2
  if (didMouseClick(340, 364, 30, 24)) //current
  {
    currentTyped+=letters1[index1][1];
  }
  if (didMouseClick(340, 340, 30, 24)) //next
  {
    currentTyped+=letters1[index1][0];
  }
  if (didMouseClick(340, 388, 30, 24)) //prev
  {
    currentTyped+=letters1[index1][2];
  }
  
  if (didMouseClick(370, 364, 30, 24)) //current2
  {
    currentTyped+=letters2[index2][1];
  }
  if (didMouseClick(370, 340, 30, 24)) //next2
  {
    currentTyped+=letters2[index2][0];
  }
  if (didMouseClick(370, 388, 30, 24)) //prev2
  {
    currentTyped+=letters2[index2][2];
  }
  
  if (didMouseClick(400, 364, 30, 24)) //current3
  {
    currentTyped+=letters3[index3][1];
  }
  if (didMouseClick(400, 340, 30, 24)) //next3
  {
    currentTyped+=letters3[index3][0];
  }
  if (didMouseClick(400, 388, 30, 24)) //prev3
  {
    currentTyped+=letters3[index3][2];
  }
  
  if (didMouseClick(430, 340, 30, 60)) //backspace or delete
  {
    if (currentTyped.length()>0) //if `, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  }
  if (didMouseClick(430, 400, 30, 60)) //space
  {
    currentTyped+=" ";
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    System.out.println("X of R " + (width/2-sizeOfInputArea/2));
    System.out.println("Y of R " + (height/2-sizeOfInputArea/2+sizeOfInputArea/2));
    //sizeOfInputArea/2, sizeOfInputArea/2
    System.out.println("W of R " + (sizeOfInputArea/2));
    System.out.println("H of R " + (sizeOfInputArea/2));
    //width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2
    System.out.println("X of G " + (width/2-sizeOfInputArea/2+sizeOfInputArea/2));
    System.out.println("Y of G " + (height/2-sizeOfInputArea/2+sizeOfInputArea/2));
    //width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2
    System.out.println("X of letter " + (width/2-sizeOfInputArea/2));
    System.out.println("h of letter " + (height/2-sizeOfInputArea/2));
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger,52,341);
  if (mousePressed)
     fill(0);
  else
     fill(255);
  ellipse(0,0,5,5);

  popMatrix();
  }
  

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}

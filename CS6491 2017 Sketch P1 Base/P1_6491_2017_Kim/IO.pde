  
//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
                    // till it is released or another key is pressed or released
  if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if(key=='!') snapPicture(); // make a picture of the canvas and saves as .jpg image
  if(key=='`') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='~') {filming=!filming; } // filming on/off capture frames into folder FRAMES 
  if(key=='a') {animating=true; f=0; t=0;}  
  if(key=='s') P.savePts("data/pts");   
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='1') b1=!b1;
  if(key=='2') b2=!b2;
  if(key=='3') b3=!b3;
  if(key=='4') b4=!b4;
  if(key=='Q') exit();  // quit application
  change=true; // to make sure that we save a movie frame each time something changes
}

void mousePressed() {  // executed when the mouse is pressed
  P.pickClosest(Mouse()); // used to pick the closest vertex of C to the mouse
  change=true;
}

void mouseDragged() {
  if (!keyPressed || (key=='a')) P.dragPicked();   // drag selected point with mouse
  if (keyPressed) {
    if (key=='.') t+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
    if (key=='t') P.dragAll(); // move all vertices
    if (key=='r') P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
    if (key=='z') P.scaleAllAroundCentroid(Mouse(),Pmouse()); // scale all vertices with respect to their center of mass
  }
  change=true;
}  
// LecturesInGraphics: vector interpolation
// Template for sketches
// Author: Joonho Kim
import java.util.*;
PImage KimPix; // picture of author's face, should be: data/pic.jpg in sketch folder

//**************************** global variables ****************************
pts P = new pts();
pts DP = new pts();
float t=0.5, f=0;
int numPerimeterPts = 120;
Boolean animate=true, linear=true, circular=true, beautiful=true;
boolean b1=true, b2=false, b3=false, b4=false, b5=false, b6=false, b0=false;
float len=200; // length of arrows

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(1600, 800, P2D);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  KimPix = loadImage("data/Kim.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare().resetOnCircle(4);
  P.loadPts("data/pts");
  myImage = loadImage("data/Kim.jpg");
}

color[] arcColors;
int ARC_POINTS = 60;
PImage myImage;

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} 

  myImage.resize(700,0);
  image(myImage, 0, 0);

  pt A=P.G[0], B=P.G[1], C=P.G[2], D=P.G[3], E=P.G[4], F=P.G[5];// named points defined for convenience
  pts OP = new pts(); OP.declare();
  OP.addPt(A); OP.addPt(B); OP.addPt(C); OP.addPt(D); OP.addPt(E); OP.addPt(F);

  PCC onImagePCC = new PCC(OP);
  onImagePCC.process();

  // Quad Mesh Parameterization
  pt  DA=P.G[6], DB=P.G[7], DC=P.G[8], DD=P.G[9], DE=P.G[10], DF=P.G[11];// named points defined for convenience
  pts DP = new pts(); DP.declare();
  DP.addPt(DA); DP.addPt(DB); DP.addPt(DC); DP.addPt(DD); DP.addPt(DE); DP.addPt(DF);
  
  PCC warpImagePCC = new PCC(DP);
  warpImagePCC.process();


  // Draw Texture Map
  if (b5) {
    onImagePCC.paintImageTo(myImage, warpImagePCC);
  }
  
  // animation
  if (animating) {
    onImagePCC.animateTo(warpImagePCC, myImage, t);
  }


  // Draw Boundary
  if (b1) {
    onImagePCC.drawBoundary();
    warpImagePCC.drawBoundary();
  }
  
  // Draw Transversals arcs     
  if (b2) {
    onImagePCC.drawTransversalArcs();
    warpImagePCC.drawTransversalArcs();
  }

  // Draw Medial Axis
  if (b3) {
    onImagePCC.drawMedialSnake();
    warpImagePCC.drawMedialSnake();
  }

  // Draw Quad Meshes
  if (b4) {
    onImagePCC.drawQuadPts();
    warpImagePCC.drawQuadPts();
  }
  
  

  
  strokeWeight(3);
  
  noFill(); stroke(black); P.draw(white); // paint empty disks around each control point
  noFill(); stroke(black); DP.draw(white); // paint empty disks around each control point
  fill(black); label(A,V(-1,-2),"A"); label(B,V(-1,-2),"B"); label(C,V(-1,-2),"C"); label(D,V(-1,-2),"D"); label(E,V(-1,-2),"E"); label(F,V(-1,-2),"F"); noFill(); // fill them with labels
  fill(black); label(DA,V(-1,-2),"DA"); label(DB,V(-1,-2),"DB"); label(DC,V(-1,-2),"DC"); label(DD,V(-1,-2),"DD"); label(DE,V(-1,-2),"DE"); label(DF,V(-1,-2),"DF"); noFill(); // fill them with labels
  
  
  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen

  fill(black); displayHeader();
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif"); // saves a movie frame 
  change=false; // to avoid capturing movie frames when nothing happens
}  // end of draw()


//**************************** text for name, title and help  ****************************
String title ="6491 2017 P1: PCC Cage for FFD", 
       name ="Student: Joonho Kim",
       menu="?:(show/hide) help, s/l:save/load control points, a: animate, `:snap picture, ~:(start/stop) recording movie frames, Q:quit",
       guide="click and drag to edit, press '1', '2', '3', or '4' to toggle boundary, Medial Axis, Arc Transversals, or quad mesh"; // help info

float timeWarp(float f) {return sq(sin(f*PI/2));}
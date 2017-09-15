// LecturesInGraphics: vector interpolation
// Template for sketches
// Author: Joonho Kim
PImage KimPix; // picture of author's face, should be: data/pic.jpg in sketch folder

//**************************** global variables ****************************
pts P = new pts();
float t=0.5, f=0;
int numPerimeterPts = 120;
Boolean animate=true, linear=true, circular=true, beautiful=true;
boolean b1=true, b2=true, b3=true, b4=true;
float len=200; // length of arrows

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(800, 800, P2D);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  KimPix = loadImage("data/Kim.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare().resetOnCircle(4);
  P.loadPts("data/pts");
}

color[] arcColors;


//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} 

  pt A=P.G[0], B=P.G[1], C=P.G[2], D=P.G[3], E=P.G[4], F=P.G[5];// named points defined for convenience
  
  // Create Bi-Arcs with tangent points
  ARC[] arcs = getBiArcs(P);
  arcColors = new color[arcs.length];
  arcColors[0] = red;
  arcColors[1] = yellow;
  arcColors[2] = green;
  arcColors[3] = cyan;
  arcColors[4] = blue;
  arcColors[5] = magenta;

  
  if (b1) {
    for (int i = 0; i < arcs.length; ++i) {
      stroke(arcColors[i%6]);
      arcs[i].drawArc();
      pt ap = arcs[i].center;
      //if (isInsideArcs(ap, arcs)) {
        arcs[i].showCenter();        
      //}
    }
  }
  
  // Find Medial Axis
  for (int ai = 0; ai < arcs.length/2; ++ai) {
  //for (int ai = 0; ai < 1; ++ai) {
    ARC currArc = arcs[ai];
    pts currArcPoints = currArc.arcPoints;
    for (int pi = 0; pi < currArc.arcPoints.nv; ++pi) {
    //for (int pi = 3; pi < 4; ++pi) {
      pt currPt = currArcPoints.G[pi];
      vec T0 = V(currArc.center, currPt);
      getMedialAxisFromArcs(currPt, T0, arcs, ai);
    }
  }
  

  
  //if (isInsideArcs(P(mouseX, mouseY), arcs)) {
  //  show(P(mouseX, mouseY), 10); 
  //}
  
  
  //pt origin = arcs[0].center;
  //vec ray = V(1,1);
  //for (int i = 0; i < arcs.length; ++i) {
  //  stroke(arcColors[i%6]);
  //    //arcs[i].drawArc();
  //  intersectsArc(origin, ray, arcs[i]);
  //}
  



  /*
    Find centers of all bi-arcs (12 in total)
      for all points on arc, find medial axis point from all other arcs
        find which one
          - is within the boundary
          - has closest distance
  */
  
  
  
  //// Points to create caplets
  //pts LHat = getTangentPoints(S, E, L, R);
  //pts RHat = getTangentPoints(E, S, R, L);
  
  //int nn = numPerimeterPts/4;
  //// Code for part 1: 4 arc perimeter points used in b1
  //pts SArc     = getArcClockPts(RHat.G[2], S, LHat.G[0], nn);
  //pts EArc     = getArcClockPts(LHat.G[2], E, RHat.G[0], nn);
  //pts greyPts  = getCircleArcInHat(LHat.G[0], LHat.G[1], LHat.G[2], nn);
  //pts brownPts = getCircleArcInHat(RHat.G[0], RHat.G[1], RHat.G[2], nn);
  
  //// this code draws part 1
  //if(b1) {  
  //  // code for part 1 is above
  //  strokeWeight(5);
  //  beginShape();
  //    fill(comboTan);
  //    noStroke();
  //    for (int i = 0; i < SArc.nv; ++i)     v(SArc.G[i]);
  //    for (int i = 0; i < greyPts.nv; ++i)  v(greyPts.G[i]);
  //    for (int i = 0; i < EArc.nv; ++i)     v(EArc.G[i]);
  //    for (int i = 0; i < brownPts.nv; ++i) v(brownPts.G[i]);
  //  endShape();
  //  noFill();
    
  //  stroke(dgreen); SArc.drawCurve();
  //  stroke(red);    EArc.drawCurve();
  //  stroke(grey);   greyPts.drawCurve();
  //  stroke(brown);  brownPts.drawCurve();
  //  noStroke();
  //}
    
    
  //// Code for part 2: Exact Medial Axis M of W.  This assumes appropriate user input
  //pt B = getMedialAxis(R, V(E,R), S, s);
  //pt G = getMedialAxis(L, V(S,L), E, e);
  
  //float angleInBetween = angle(RHat.G[0], B, RHat.G[2]);  // asumming acut angle
  //float stepAngle = angleInBetween/(nn-1);
  //float gl = (d(G, E) < d(G, LHat.G[2])) ? -d(G, LHat.G[2]) : d(G, LHat.G[2]); // sign is important.  same sign or different sign d value  
  
  //// Medial Axis points
  //pts medialAxisPts = new pts();
  //medialAxisPts.declare();
  //for (int i = 0; i < nn; ++i) {
  //  vec BR = V(B, R);
  //  vec RE = V(R, E);
  //  float re = (dot(BR, RE) >= 0) ? d(R, E) : -d(R, E);
  //  BR.rotateBy(i*stepAngle);
  //  pt RR = P(B).add(BR);
  //  RE = U(BR).scaleBy(re);    // RE always points to E
  //  medialAxisPts.addPt(getMedialAxis(RR, RE, G, gl));
  //}
  
  //// This code draws part 2
  //if(b2) {
  //  // your code for part 2 is above    
  //  strokeWeight(5);
  //  stroke(magenta);
  //  medialAxisPts.drawCurve();
  //}
  
  
  //// Code for part 3 Extra: Uniform Arc Transversals
  //if(b3) {
  //  stroke(yellow);   strokeWeight(2);
  //  for (int i = 0; i < nn; ++i) {
  //    getCircleArcInHat(brownPts.G[i], medialAxisPts.G[i], greyPts.G[nn-1-i], 15).drawCurve();
  //  }
    
  //  for (int i = 0; i < nn/2; ++i) {
  //    getCircleArcInHat(SArc.G[i], S, SArc.G[nn-1-i], 15).drawCurve();
  //    getCircleArcInHat(EArc.G[i], E, EArc.G[nn-1-i], 15).drawCurve();
  //  }
  //}
   
  strokeWeight(3);
  
  noFill(); stroke(black); P.draw(white); // paint empty disks around each control point
  fill(black); label(A,V(-1,-2),"A"); label(B,V(-1,-2),"B"); label(C,V(-1,-2),"C"); label(D,V(-1,-2),"D"); label(E,V(-1,-2),"E"); label(F,V(-1,-2),"F"); noFill(); // fill them with labels
  
  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen

  fill(black); displayHeader();
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif"); // saves a movie frame 
  change=false; // to avoid capturing movie frames when nothing happens
}  // end of draw()


//**************************** text for name, title and help  ****************************
String title ="6491 2017 P1: Caplets", 
       name ="Student: Joonho Kim",
       menu="?:(show/hide) help, s/l:save/load control points, a: animate, `:snap picture, ~:(start/stop) recording movie frames, Q:quit",
       guide="click and drag to edit, press '1', '2', or '3' to toggle Caplets, Medial Axis, or Arc Transversals,"; // help info

float timeWarp(float f) {return sq(sin(f*PI/2));}
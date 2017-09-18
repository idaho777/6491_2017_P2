// LecturesInGraphics: vector interpolation
// Template for sketches
// Author: Joonho Kim
import java.util.*;
PImage KimPix; // picture of author's face, should be: data/pic.jpg in sketch folder

//**************************** global variables ****************************
pts P = new pts();
float t=0.5, f=0;
int numPerimeterPts = 120;
Boolean animate=true, linear=true, circular=true, beautiful=true;
boolean b1=true, b2=false, b3=false, b4=false;
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
int ARC_POINTS = 6;
ARC[] g_arcs;

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} 

  pt A=P.G[0], B=P.G[1], C=P.G[2], D=P.G[3], E=P.G[4], F=P.G[5];// named points defined for convenience
  
  
  // Create Bi-Arcs with tangent points
  g_arcs = getBiArcs(P);
  arcColors = new color[g_arcs.length];
  arcColors[0] = red;
  arcColors[1] = yellow;
  arcColors[2] = green;
  arcColors[3] = cyan;
  arcColors[4] = blue;
  arcColors[5] = magenta;

  if (b1) {
    for (int i = 0; i < g_arcs.length; ++i) {
      g_arcs[i].colour = arcColors[i%6];
      g_arcs[i].drawArc();
      pt ap = g_arcs[i].center;
      //if (isInsideArcs(ap)) {
      //  g_arcs[i].showCenter();        
      //}
    }
  }
    
  
  // Find starting arc and ending arc for medial axis
  boolean isTwoEndArcs = true;
  List<Integer> endArcs = new ArrayList<Integer>();
  for (int ai = 0; ai < g_arcs.length; ++ai) {
    if (circleFitsInArcs(C(g_arcs[ai].center, g_arcs[ai].r))) {
      endArcs.add(ai);
      stroke(g_arcs[ai].colour);
      C(g_arcs[ai].center, g_arcs[ai].r).drawCirc();
    }
  }
  
  
  if (endArcs.size() != 2) {
    isTwoEndArcs = false;
  }
  
  pt[][] medialSnake = null;
  // Only two end g_arcs allowed for a medial axis without bifurcation.
  if (isTwoEndArcs) {
    // TODO: if two end curves are close, fix it.
    // Get end arcs with the circles
    // the number of arcs from startIndex to endIndex is least number
    int startMArcIndex = endArcs.get(0);
    int endMArcIndex = endArcs.get(1);
    if (endMArcIndex - startMArcIndex > 6) {
      startMArcIndex = endArcs.get(1);
      endMArcIndex = endArcs.get(0);
    }
 
    // Find arcs to sample our medial axis from.
    int sIn = (startMArcIndex + 1) % (g_arcs.length);
    int eIn = (endMArcIndex + g_arcs.length - 1) % (g_arcs.length);
    List<ARC> _inArcs = new ArrayList<ARC>();
    
    int currAi = sIn;
    while (currAi != (eIn + 1) % (g_arcs.length)) {
      _inArcs.add(g_arcs[currAi]);
      currAi = (currAi + 1) % (g_arcs.length);
    }
    ARC[] inArcs = _inArcs.toArray(new ARC[_inArcs.size()]);
        
    // Arcs to compare against.
    int sOp = (endMArcIndex + 1) % (g_arcs.length);
    int eOp = (startMArcIndex + g_arcs.length - 1) % (g_arcs.length);
    List<ARC> _opArcs = new ArrayList<ARC>();
    
    currAi = sOp;
    while (currAi != (eOp + 1) % (g_arcs.length)) {
      _opArcs.add(g_arcs[currAi]);
      currAi = (currAi + 1) % (g_arcs.length);
    }    
    ARC[] opArcs = _opArcs.toArray(new ARC[_opArcs.size()]);
    

    // find Medial axis snake
    //medialSnake = getMedialSnake(startMArcIndex, endMArcIndex, inArcs, opArcs);  // Short Path
    medialSnake = getMedialSnake(endMArcIndex, startMArcIndex, opArcs, inArcs);  // Long path
  }

  if (b2 && isTwoEndArcs) {
    stroke(sand);
    for (pt[] t : medialSnake) show(t[1], 4);
  }


  // Transversals arcs 
  pts[] medialPts = null;
  if (isTwoEndArcs) {
    List<pts> _medialPts = new ArrayList<pts>();
    for (pt[] t : medialSnake) {
      _medialPts.add(getCircleArcInHat(t[0], t[1], t[2], 5));
    }

    medialPts = _medialPts.toArray(new pts[_medialPts.size()]);
  }
  
  if (b3 && isTwoEndArcs) {
    stroke(sand);
    for (pts p : medialPts) p.drawCurve();
  }
  

  // Quad Mesh Parameterization
  pts[][] quadPts = null;
  if (isTwoEndArcs) {
    List<pts[]> _quadPts = new ArrayList<pts[]>();

    int numQuadRows = medialPts[0].nv - 1;
    int numQuadCols = medialPts.length -1;
    for (int r = 0; r < numQuadRows; ++r) {
      pts[] quadRow = new pts[numQuadCols];
      
      for (int c = 0; c < numQuadCols; ++c) {
        pts currPts = new pts();
        currPts.declare();
        currPts.addPt(medialPts[c  ].G[r  ]);
        currPts.addPt(medialPts[c+1].G[r  ]);
        currPts.addPt(medialPts[c+1].G[r+1]);
        currPts.addPt(medialPts[c  ].G[r+1]);
        quadRow[c] = currPts;
      }
      _quadPts.add(quadRow);

    }

    quadPts = _quadPts.toArray(new pts[numQuadRows][numQuadCols]);
  }
  
  if (b4 && isTwoEndArcs) {
    stroke(sand);
    for (pts[] row : quadPts) {
      for (pts p : row) {
        p.drawCurve();
      }
    }
  }
  
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

class PCC 
  {
	ARC[] g_arcs;
  boolean isTwoEndArcs;
  List<Integer> endArcs;
  pt[][] medialSnake;
  pts[] medialPts;
  pts[][] quadPts;
	color[] arcColors;
  pts pp;

	PCC() {}
	PCC(pts P) {
    pp = P;
    g_arcs = getBiArcs(P);
	  colors();
	}

  void process() {
    endArcs = findEndArcs();
    isTwoEndArcs = endArcs.size() == 2;
    if (isTwoEndArcs) {
      medialSnake = findMedialSnake();
      medialPts = findTransversalArcs();
      quadPts = findQuadPoints();
    } else {
      medialSnake = null;
      medialPts = null;
      quadPts = null;
    }
  }
	
	void colors() {
		arcColors = new color[g_arcs.length/2];
		arcColors[0] = red;
		arcColors[1] = yellow;
		arcColors[2] = green;
		arcColors[3] = cyan;
		arcColors[4] = blue;
		arcColors[5] = magenta;
	}

  List<Integer> findEndArcs() {
    List<Integer> endArcs = new ArrayList<Integer>();
    for (int ai = 0; ai < g_arcs.length; ++ai) {
      if (circleFitsInArcs(C(g_arcs[ai].center, g_arcs[ai].r), g_arcs)) {
        endArcs.add(ai);
        g_arcs[ai].colour = arcColors[ai % arcColors.length];
        stroke(g_arcs[ai].colour);
        
        C(g_arcs[ai].center, g_arcs[ai].r).drawCirc();
      }
    }
    
    return endArcs;
  }

  pt[][] findMedialSnake() {
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
    // return getMedialSnake(endMArcIndex, startMArcIndex, opArcs, inArcs);  // Long path
    return getMedialSnake(startMArcIndex, endMArcIndex, inArcs, opArcs, g_arcs);  // Short Path
  }

  pts[] findTransversalArcs() {
    pts[] medialPts = null;
    if (isTwoEndArcs) {
      List<pts> _medialPts = new ArrayList<pts>();
      for (pt[] t : medialSnake) _medialPts.add(getCircleArcInHat(t[0], t[1], t[2], 5));

      medialPts = _medialPts.toArray(new pts[_medialPts.size()]);
    }
    return medialPts;
  }

  pts[][] findQuadPoints() {
    pts[][] quadPts = null;
    List<pts[]> _quadPts = new ArrayList<pts[]>();

    int numQuadRows = medialPts[0].nv - 1;
    int numQuadCols = medialPts.length -1;
    for (int r = 0; r < numQuadRows; ++r) {
      pts[] quadRow = new pts[numQuadCols];
      
      for (int c = 0; c < numQuadCols; ++c) {
        pts currPts = new pts();
        currPts.declare();
        currPts.addPt(medialPts[c  ].G[r  ]);
        currPts.addPt(medialPts[c  ].G[r+1]);
        quadRow[c] = currPts;
      }
      _quadPts.add(quadRow);
    }

    return _quadPts.toArray(new pts[numQuadRows][numQuadCols]);
  }

  void paintImageTo(PImage myImage, PCC warp) {
    pts[][] warpPts = warp.quadPts;
    if (warp.isTwoEndArcs) {
      paintImageTo(myImage, warpPts);
    }

  }

  void paintImageTo(PImage myImage, pts[][] warpPts) {
    if(isTwoEndArcs && quadPts[0].length == warpPts[0].length) {
      textureMode(IMAGE);
      noStroke();
      for (int r = 0; r < quadPts.length; ++r) {
        beginShape(QUAD_STRIP); texture(myImage);
        for (int c = 0; c < quadPts[r].length; ++c) {
          v(warpPts[r][c].G[0], quadPts[r][c].G[0].x, quadPts[r][c].G[0].y);
          v(warpPts[r][c].G[1], quadPts[r][c].G[1].x, quadPts[r][c].G[1].y);
        }
        endShape();
      }
    }    
  }

  void animateTo(PCC warp, PImage myImage, float time) {
    if (isTwoEndArcs && warp.isTwoEndArcs && quadPts[0].length == warp.quadPts[0].length) {
      pts[][] warpPts = warp.quadPts;
      pts[][] tempPts = new pts[quadPts.length][quadPts[0].length];
      for (int r = 0; r < quadPts.length; ++r) {
        for (int c = 0; c < quadPts[r].length; ++c) {
          pts tPts = new pts();
          tPts.declare();
          tPts.addPt(L(quadPts[r][c].G[0], warpPts[r][c].G[0], time));
          tPts.addPt(L(quadPts[r][c].G[1], warpPts[r][c].G[1], time));
          
          tempPts[r][c] = tPts;
        }
      }
      paintImageTo(myImage, tempPts);
    }
  }


  // Draw Methods
  void drawBoundary() {
    for (int i = 0; i < g_arcs.length; ++i) {
      g_arcs[i].colour = arcColors[i%6];
      g_arcs[i].drawArc();
      pt ap = g_arcs[i].center;
    }
  }

  void drawMedialSnake() {
    if (isTwoEndArcs) {
      stroke(sand);
      for (pt[] t : medialSnake) show(t[1], 4);
    }
  }

  void drawTransversalArcs() {  
    if (isTwoEndArcs) {
      stroke(sand);
      for (pts p : medialPts) p.drawCurve();
    }
  }

  void drawQuadPts() {
    if (isTwoEndArcs) {
      stroke(sand);
      for (pts[] row : quadPts) {
        beginShape(QUAD_STRIP);
        for (pts p : row) {
          v(p.G[0]);
          v(p.G[1]);
        }
        endShape();
      }
    }
  }
	
} //*********** END PCC CLASS
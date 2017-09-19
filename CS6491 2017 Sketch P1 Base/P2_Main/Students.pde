// Place student's code here
// Student's names:
// Date last edited:
/* Functionality provided (say what works):

*/

// PART 1: GET BI-ARCS
// Calculate array of point tangents per control point
vec[] getPointTangents(pts P) {
  vec[] ret = new vec[P.nv];
  for (int i = 0; i < ret.length; ++i) {
    pt prev = P.G[(i + P.nv - 1) % P.nv];
    pt next = P.G[(i + 1) % P.nv];
    ret[i] = V(prev, next).normalize();
  }
  return ret;
}


// Generates all Bi-Arcs for a set of points and tangents
ARC[] getBiArcs(pts points) {
  // 2 arcs per Bi-Arc
  ARC[] arcs = new ARC[2*points.nv];
  
  // Finds all tangents
  vec[] tangents = getPointTangents(points);
  stroke(black);
  for (int i = 0; i < tangents.length; ++i) {
    arrow(points.G[i], 100, tangents[i]);
  }
  
  // Finds all bi-arcs parameters for ArcHat method
  pt[][] params = new pt[2*points.nv][3];
  for (int i = 0; i < points.nv; ++i) {
    pt a = points.G[i],   b = points.G[(i+1) % points.nv];
    vec t0 = tangents[i], t1 = tangents[(i+1) % points.nv];
    pt[][] ps = getBiArcParams(a, t0, b, t1);
    params[2*i]   = ps[0];
    params[2*i+1] = ps[1];
  }
  
  // Create arc objects
  for (int i = 0; i < params.length; ++i) {
    pts arcPoints = getCircleArcInHat(params[i][0], params[i][1], params[i][2], ARC_POINTS);
    pt c = getCircleArcInHatCenter(params[i][0], params[i][1], params[i][2]);
    arcs[i] = Arc(c, params[i][1], arcPoints);
  }
  
  return arcs;
}


// returns biArcParams to create bi-arcs
pt[][] getBiArcParams(pt A, vec T0, pt B, vec T1) {
  T0 = U(T0);
  T1 = U(T1);
  vec V = V(A,B);
  vec T = V(T0).add(T1);
  
  float den = 2*(1 - dot(T0, T1));
  float d = 0;
  if (den == 0) {
    if (dot(V,T0) == 0) {
      println("equal and perpendicular");
      // TODO: handle this differently, semi-circle case??
    } else {
      println("WHAT IS THIS");
      d = dot(V, V)/(4*dot(V,T0)); 
    }
  } else {
    float discriminant = sq(dot(V, T)) + 2*(1-dot(T0, T1))*(dot(V,V));
    d = max(((-dot(V, T) + sqrt(discriminant))/den), 
            ((-dot(V, T) - sqrt(discriminant))/den));
  }
  
  pt pm = P(A).add(B).add(V(T0).add(V(T1).reverse()).scaleBy(d)).scale(0.5);
  pt q1 = P(A).add(d, T0);
  pt q2 = P(B).add(-d, T1);
 
  pt[][] biArcParams = {{A, q1, pm}, {pm, q2, B}};
  return biArcParams;
}


// ========================================================================================================================
// PART 2: GET MEDIAL AXIS
// Checks if point/ray intersects arc
int intersectsArc(pt p, vec ray, ARC arc) {
  vec PC = V(p, arc.center);
  ray = U(ray);
  
  float determ = sq(dot(PC,ray)) - (n2(PC) - sq(arc.r));
  if (determ < 0) {
    return 0;
  }
  float dp = dot(PC, ray) + sqrt(determ);
  float dm = dot(PC, ray) - sqrt(determ);
  pt pp = P(p, dp, ray);
  pt mm = P(p, dm, ray);
    
  int count = 0;

  // Check if points are on the arc.
  vec CL = V(arc.center, arc.arcPoints.G[0]);
  vec CR = V(arc.center, arc.arcPoints.G[arc.arcPoints.nv-1]);
  vec CPP = V(arc.center, pp);
  vec CMM = V(arc.center, mm);
  if (det(CPP, CL) * det(CPP, CR) <= 0 && (dot(V(CL).add(CR), CPP) >= 0) && dp >= 0) {
    count++;
  }
  if (det(CMM, CL) * det(CMM, CR) <= 0 && (dot(V(CL).add(CR), CMM) >= 0) && dm >= 0) {
    count++;
  }
  return count;
}


// Get medial snake
// From start to end point, return an Nx3 array of medial axis points
// [P, medial, PHat]
pt[][] getMedialSnake(int startMArcIndex, int endMArcIndex, ARC[] inArcs, ARC[] opArcs, ARC[] g_arcs) {
  List<pt[]> snake = new ArrayList<pt[]>();

  int arcsInBetween = 0;
  if (endMArcIndex > startMArcIndex) {
    arcsInBetween = endMArcIndex - startMArcIndex - 1;
  } else {
    arcsInBetween = g_arcs.length - startMArcIndex + endMArcIndex - 1;
  }

  int arcSteps = arcsInBetween;
  // Add Head
  ARC startArc = g_arcs[startMArcIndex];
  for (int i = 1; i < ARC_POINTS/2; i += 6) {
    pt[] curr = new pt[3];
    curr[2] = startArc.arcPoints.G[i];
    curr[1] = startArc.center;
    curr[0] = startArc.arcPoints.G[ARC_POINTS - 1 - i];
    snake.add(0, curr);
  }

  // Add Body
  for (ARC currArc : inArcs) {
    // strokeWeight(10); stroke(currArc.colour); currArc.drawArc(); strokeWeight(2); 
    pts currArcPoints = currArc.arcPoints;
    
    float towardRight = 1;
    vec tang = V(currArcPoints.G[0], currArcPoints.G[1]);
    vec ZC = V(currArcPoints.G[0], currArc.center);
    if (det(tang, ZC) >= 0) towardRight = -1;
    
    for (int pi = 0; pi < currArcPoints.nv; pi += arcSteps) {
      int tries = 0;
      while (tries < arcSteps) {
        pt p = currArcPoints.G[pi + tries];
        vec T0 = V(currArc.center, p).scaleBy(towardRight);
    
        pt[] triplet = getMedialAxisTripletFromArcs(p, T0, opArcs, g_arcs);
        if (triplet != null) {
          snake.add(triplet);
          break;
        } else {
          tries++;
        }
      }
    }
  }
  
  // Add Tail
  ARC endArc = g_arcs[endMArcIndex];
  for (int i = 1; i < ARC_POINTS/2; i += 6) {
    pt[] curr = new pt[3];
    curr[0] = endArc.arcPoints.G[i];
    curr[1] = endArc.center;
    curr[2] = endArc.arcPoints.G[ARC_POINTS - 1 - i];
    snake.add(curr);
  }

  pt[][] ret = snake.toArray(new pt[snake.size()][3]);
  return ret;
}



// Get best medial axis point sampled from inArcs to opArcs
int casd = 0;
pt[] getMedialAxisTripletFromArcs(pt p, vec T0, ARC[] opArcs, ARC[] g_arcs) {
  pt[] trip = new pt[3];

  for (int ai = 0; ai < opArcs.length; ++ai) {
    vec tang = V(opArcs[ai].arcPoints.G[0], opArcs[ai].arcPoints.G[1]);
    vec ZC = V(opArcs[ai].arcPoints.G[0], opArcs[ai].center);
    boolean centerIsRight = det(tang, ZC) > 0;
    
    float r = opArcs[ai].r;
    if (centerIsRight) r = -opArcs[ai].r;
    
    pt m = getMedialAxis(p, T0, opArcs[ai].center, r);
    if (isInsideArcs(m, g_arcs) && 
        intersectsArc(opArcs[ai].center, V(opArcs[ai].center, m), opArcs[ai]) > 0 && 
        circleFitsInArcs(C(m, d(p, m)), g_arcs)) {
      trip[0] = p;
      trip[1] = m;
      trip[2] = P(opArcs[ai].center, opArcs[ai].r, U(V(opArcs[ai].center, m)));
      return trip;
    }
  }
  return null;   
}




// =================================================================================================================
// UTIL
// Check if point is inside arc boundary
boolean isInsideArcs(pt p, ARC[] g_arcs) {
  int intersections = 0;
  for (int i = 0; i < g_arcs.length; ++i) {
    intersections += intersectsArc(p, V(1, 0.5), g_arcs[i]);
  } 
  
  return intersections % 2 == 1;
}

// Check if circle fits inside the arc boundary
boolean circleFitsInArcs(CIRCLE c, ARC[] g_arcs) {
  if (!isInsideArcs(c.C, g_arcs)) return false;
  for (int ai = 0; ai < g_arcs.length; ++ai) {
    ARC currArc = g_arcs[ai];
    for (int pi = 0; pi < currArc.arcPoints.nv; ++pi) {
      if (c.r-0.08 > d(c.C, currArc.arcPoints.G[pi])) {
        return false;
      }
    }
  }
  return true;
}




// Part 1
pts getTangentPoints(pt S, pt E, pt L, pt R) {
  pt M = getMedialAxis(L, V(S, L), E, d(E, R));
  pt Lprime = P(M, d(M, L), U(V(M, E)));
  pt O = P(L, V(L, Lprime).scaleBy(0.5));
  pt A = P(M, n2(V(L,M))/d(M,O), U(V(M,O)));
  
  pts hat = new pts();
  hat.declare();
  hat.addPt(L);
  hat.addPt(A);
  hat.addPt(Lprime);

  return hat;
}


pts getArcClockPts(pt A, pt B, pt C, int n) {
  pts p = new pts();
  p.declare();
  
  float LSangle = angle(V(B, A));
  float LEangle = angle(V(B, C));
  if (LEangle <= LSangle) LEangle += TAU;
  float angleInBetween = LEangle - LSangle;
  float step = angleInBetween / (n-1);
  
  vec BA = V(B, A);
  for (int i = 0; i < n; ++i) {
    p.addPt(P(B, R(V(BA), i*step)));
  }
  
  return p;
}


// Part 1 and 2
pt getMedialAxis(pt P0, vec T0, pt C1, float c1) {
  T0 = U(T0);
  vec C1P0 = V(C1,P0);
  float d = (sq(c1) - sq(d(C1,P0))) / (2*(dot(T0, C1P0) - c1));
  if (d == 0) return C1;
  pt X = P(P0).add(d, T0);
  return X;
}


pt getCircleArcInHatCenter(pt PA, pt B, pt PC) {
  float e = (d(B,PC)+d(B,PA))/2;
  pt A = P(B,e,U(B,PA));
  pt C = P(B,e,U(B,PC));
  vec BA = V(B,A), BC = V(B,C);
  float d = dot(BC,BC) / dot(BC,W(BA,BC));
  pt X = P(B,d,W(BA,BC));
  return X;
}


pts getCircleArcInHat(pt PA, pt B, pt PC, int n) {// draws circular arc from PA to PB that starts tangent to B-PA and ends tangent to PC-B
  pts p = new pts();
  p.declare();
  float e = (d(B,PC)+d(B,PA))/2;
  pt A = P(B,e,U(B,PA));
  pt C = P(B,e,U(B,PC));
  vec BA = V(B,A), BC = V(B,C);
  float d = dot(BC,BC) / dot(BC,W(BA,BC));
  pt X = P(B,d,W(BA,BC));
  float r=abs(det(V(B,X),U(BA)));
  vec XA = V(X,A), XC = V(X,C); 
  float a = angle(XA,XC), da=a/(n-1);
  for (int i = 0; i < n; ++i) {
    p.addPt(P(X,R(V(XA), i*da)));
  }
  return p;
}   
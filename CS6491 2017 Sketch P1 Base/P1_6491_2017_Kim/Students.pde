// Place student's code here
// Student's names:
// Date last edited:
/* Functionality provided (say what works):

*/

// Calculate array of point tangents
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
  vec[] tangents = getPointTangents(P);
  stroke(black);
  for (int i = 0; i < tangents.length; ++i) {
    arrow(P.G[i], 100, tangents[i]);
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
    pts arcPoints = getCircleArcInHat(params[i][0], params[i][1], params[i][2], 10);
    pt c = getCircleArcInHatCenter(params[i][0], params[i][1], params[i][2]);
    arcs[i] = Arc(c, params[i][1], arcPoints);
  }
  
  return arcs;
}


// returns biArcParams
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
      // handle this differently, semi-circle case
  
      
      
    } else {
      println("equal");
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
  
  //stroke(red);
  //show(pm, 10);
  //show(q1);
  //show(q2);
 
  pt[][] biArcParams = {{A, q1, pm},
                        {pm, q2, B}};
  return biArcParams;
}


// Check if point is inside points
boolean isInsideArcs(pt p, ARC[] arcs) {
  int intersections = 0;
  for (int i = 0; i < arcs.length; ++i) {
    intersections += intersectsArc(p, V(1, 0.5), arcs[i]);
  } 
  
  return intersections % 2 == 1;
}


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


// Get best medial axis point from all arcs
int casd = 0;
pt getMedialAxisFromArcs(pt p, vec T0, ARC[] arcs, int currArcIndex) {
  //arrow(p, 100, T0);
  pt currP = arcs[currArcIndex].center;
  pt currM = arcs[currArcIndex].center;
  
  for (int ai = 0; ai < arcs.length; ++ai) {
    //if (ai == currArcIndex || ai == (currArcIndex + arcs.length - 1)%arcs.length) {
    if (ai == currArcIndex) {
      //println("HERE I AM", casd++);  
      continue;
    } 
    pt mP = getMedialAxis(p, T0, arcs[ai].center, arcs[ai].r);
    pt mN = getMedialAxis(p, T0, arcs[ai].center, -arcs[ai].r);
        
    stroke(arcColors[ai%6]);
    if (isInsideArcs(mP, arcs) && (intersectsArc(mP, V(arcs[ai].center, mP), arcs[ai]) > 0 || intersectsArc(mP, V(mP, arcs[ai].center), arcs[ai]) > 0 )) {
      
      CIRCLE c = C(mP, d(p, mP));
      if (circleFitsInArcs(c, arcs)) {
        //if (
        show(mP, 3);
        //c.drawCirc();
      }
    }
    
    if (isInsideArcs(mN, arcs) && (intersectsArc(mN, V(arcs[ai].center, mN), arcs[ai]) > 0 || intersectsArc(mN, V(mN, arcs[ai].center), arcs[ai]) > 0 )) {
      CIRCLE c = C(mN, d(p, mN));
      if (circleFitsInArcs(c, arcs)) {
        show(mN, 3);
        //c.drawCirc();
      }
    }
  }
  return currM;

    
  //  vec CL = V(arcs[i].center, arcs[i].arcPoints.G[0]);
  //  vec CR = V(arcs[i].center, arcs[i].arcPoints.G[arcs[i].arcPoints.nv-1]);
  //  vec CM = V(arcs[i].center, m);
  //  if (det(CM, CL) * det(CM, CR) <= 0 && dot(CM, CL) >= 0 && dot(CM, CR) >= 0) {
  //    if (d(m, aa.arcPoints.G[0]) < chosen.r) {
  //      chosen =  C(m, d(m, aa.arcPoints.G[0])); 
  //    }
  //  }
  //  //edge(arcs[i].center, m);
  //  //edge(aa.arcPoints.G[0], m);
  //}
  
  
}


boolean circleFitsInArcs(CIRCLE c, ARC[] arcs) {
  for (int ai = 0; ai < arcs.length; ++ai) {
    ARC currArc = arcs[ai];
    for (int pi = 0; pi < currArc.arcPoints.nv; ++pi) {
      if (c.r > d(c.C, currArc.arcPoints.G[pi])) {
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
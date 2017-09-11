// Place student's code here
// Student's names:
// Date last edited:
/* Functionality provided (say what works):

*/

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
  pt X = P(P0).add(d, T0);
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
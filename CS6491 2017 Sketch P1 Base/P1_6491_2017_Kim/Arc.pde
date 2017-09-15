ARC Arc(pt C, pt H, pts p) { return new ARC(C, H, p);}

class ARC 
  {
    pts arcPoints = new pts();
    pt center;
    pt hatCenter;
    float r = 0;
    ARC () {}
    ARC(pt C, pt H, pts points) {
      center = C;
      hatCenter = H;
      arcPoints = points;
      r = d(C, points.G[0]);
    } 
    void drawArc() {arcPoints.drawCurve();}
    void showCenter() {show(center);}
  } //*********** END ARC CLASS
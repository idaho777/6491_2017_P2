ARC Arc(pt C, pt H, pts p) { return new ARC(C, H, p);}

class ARC 
  {
    pts arcPoints = new pts();
    pt center;
    pt hatCenter;
    float r = 0;
    color colour = white;
    ARC () {}
    ARC(pt C, pt H, pts points) {
      center = C;
      hatCenter = H;
      arcPoints = points;
      r = d(C, points.G[0]);
    } 
    void drawArc() {stroke(colour); arcPoints.drawCurve();}
    void showCenter() {stroke(colour); show(center);}
  } //*********** END ARC CLASS
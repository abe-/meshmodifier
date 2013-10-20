/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Developed by Abelardo Gil-Fournier - October 2013
      http://abelardogfournier.org/modifier
    for the workshop Stone, Pixel, Plastic, Stone
    in Arteleku, October 20-21, 2013, http://arteleku.net
    The default model comes from a 3d scan of a stone
    made by Darío Urzay / http://www.dariourzay.com 
*/

import controlP5.*;    // importar libreria controlP5
import sojamo.drop.*;
import toxi.processing.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import peasy.*;
import processing.opengl.*;

TriangleMesh mesh;
ToxiclibsSupport gfx;
ControlP5 ui;
PeasyCam cam;
SDrop drop;

String filePath;
boolean showNormals = true;
boolean normalColors = false;
boolean isWireFrame = false;
boolean isSelection = false;
boolean isAbout = false;

ArrayList<Face> faces;
float shrink = 0.25;
float extrusion = 5;
float threshold = 0.5;

void setup() {
  size(1000, 700, P3D);
  filePath = dataPath("piedra-100-export-directo.stl"); 
  initMesh(filePath);

  gfx = new ToxiclibsSupport(this);
  cam = new PeasyCam(this, 300);   
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1000);
  cam.setResetOnDoubleClick(false);

  drop = new SDrop(this);
  ui = new ControlP5(this);
  initGUI();
}

void draw() {
  background(51); 
  lights();
  
  if (isWireFrame) {
    noFill();
    stroke(255);
  } 
  else {
    fill(255);
    noStroke();
  }
  if (normalColors) gfx.meshNormalMapped(mesh, !isWireFrame, showNormals ? 10 : 0);
  else gfx.mesh(mesh, !isWireFrame, showNormals ? 10 : 0);

  if (isSelection) {
    for (Face f : faces) {
      Triangle3D t = f.toTriangle();
      noFill();
      stroke(#15EDFF);//255, 173, 21);
      gfx.triangle(t);
    }
  }
  
  noLights();
  cameraHUD();
}


void cameraHUD() { // necesario para que el controlP5 no sufra los cambios de la camara
  cam.beginHUD();
  if (mouseX < 120) {
    fill(0, 50);
    noStroke();
    rect(0, 0, 125, height);
    cam.setMouseControlled(false);
  }
  else cam.setMouseControlled(true);  
  fill(255);
  ui.draw();
  cam.endHUD();
}


/***************************
 * selectRandom( float threshold )
 *******/

void selectRandom( float threshold_ ) {
  faces.clear();
  for (Face f : mesh.faces) {
    if (random(1) < threshold_) {
      faces.add(f);
    }
  }
}

void selectNoise( float threshold_ ) {
  faces.clear();
  float factor = 0.01;
  for (Face f : mesh.faces) {
    Vec3D centroid = f.getCentroid();
    if (noise(centroid.x*factor, centroid.y*factor, centroid.z*factor) < threshold_) {
      faces.add(f);
    }
  }
  noiseSeed((long)random(10000000));
}

/***************************
 * extrudeFace( ArrayList selection, float shrink, float extrude )
 *******/

void extrudeFaces( ArrayList<Face> selection, float shrink, float extrude ) {
  ArrayList <Vec3D[]> newFaces = new ArrayList();
  ArrayList <Face> removeFaces = new ArrayList();

  for (Face face : selection) {
    Vec3D centroid = face.getCentroid();
    Vec3D extrusion = face.normal.scale( extrude );
    Vec3D a = face.a.interpolateTo(centroid, shrink).add(extrusion);
    Vec3D b = face.b.interpolateTo(centroid, shrink).add(extrusion);
    Vec3D c = face.c.interpolateTo(centroid, shrink).add(extrusion);

    Vec3D[] n1 = {
      face.a, a, face.c
    };
    Vec3D[] n2 = {
      a, c, face.c
    };
    Vec3D[] n3 = {
      face.a, b, a
    };
    Vec3D[] n4 = {
      face.a, face.b, b
    };    
    Vec3D[] n5 = {
      face.c, c, face.b
    };
    Vec3D[] n6 = {
      c, b, face.b
    };
    Vec3D[] n7 = {
      a, b, c
    };

    newFaces.add(n1);
    newFaces.add(n2);
    newFaces.add(n3);
    newFaces.add(n4);
    newFaces.add(n5);
    newFaces.add(n6);
    newFaces.add(n7);
    removeFaces.add( face );
  }

  for (Vec3D[] v : newFaces) {
    mesh.addFace( v[0], v[1], v[2] );
  }
  for (Face f : removeFaces) {
    mesh.faces.remove( f );
  }
  
  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
}



/***************************
 * randomify( float f )
 *******/

void randomify( float f ) {
  for (Vertex v : mesh.vertices.values()) {
    float r = f * (random(1)-.5);
    Vec3D n = v.normal.scale(r);
    v.addSelf(n);
  }
  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
}

/***************************
 * noisify( float f )
 *******/

void noisify( float f ) {
  float factor = .01;
  for (Vertex v : mesh.vertices.values()) {
    float ns = f * (-0.5 + noise(v.x*factor, v.y*factor, v.z*factor));
    Vec3D n = v.normal.scale(ns);
    v.addSelf(n);
  }
  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
}

/***************************
 * laplacify()
 *******/

void laplacify() {
  LaplacianSmooth lf = new LaplacianSmooth();
  WETriangleMesh wemesh = new WETriangleMesh().addMesh(mesh);
  lf.filter(wemesh, 1);
  mesh.clear();
  mesh.addMesh(wemesh);
  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
}


/***************************
 * reset()
 *******/

void reset() {
  initMesh(filePath);
}


/***************************
 * initMesh()
 *******/

void initMesh(String fileName) {
  if (mesh != null) mesh.clear();
  mesh = (TriangleMesh) new STLReader().loadBinary(fileName, STLReader.TRIANGLEMESH);
  mesh.center(new Vec3D(0, 0, 0));
  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
  faces = new ArrayList(mesh.faces);
}

/***************************
 * UTILS :: openFile()
 *******/

void openFile() {
  selectInput("Select a STL file to process:", "processFile");
}

void processFile(File selection) {
  if (selection != null) {
    filePath = selection.getAbsolutePath();
    println(filePath); 
    initMesh(filePath);
  }
}

/***************************
 * UTILS :: exportToSTL()
 *******/

void exportToSTL() {
  File f = new File(filePath);
  String fileName = f.getName();
  fileName = fileName.substring(0, fileName.lastIndexOf('.'));
  fileName = fileName + "-p4-" + frameCount + ".stl";
  println("Exporting to: " + fileName);
  mesh.saveAsSTL(sketchPath(fileName), true);
}


/***************************
 * PEASYCAM :: setDamping(0,0,0) sigue sin existir en la distrib. oficial
 *******/

void mouseReleased() {
  CameraState state = cam.getState(); // get a serializable settings object for current state
  cam.setState(state);
}

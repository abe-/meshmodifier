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



/***************************
 * GUI :: initGUI()
 *******/

void initGUI() {
  int py = 10;
  int paso = 25;
  float salto = 1.25;
  
  ui.setColorForeground(#15EDFF);
  ui.setColorBackground(color(100));
  ui.setColorLabel(0xffdddddd);
  ui.setColorValue(color(200));
  ui.setColorActive(#15EDFF);  
  
  ui.setAutoDraw(false);
  ui.addButton("Exit").setPosition(width-30, py).setSize(20, 20).setLabel("  X");
  ui.addButton("openFile").setPosition(10, py).setSize(50,20); py += paso;
  ui.addButton("Export").setPosition(10, py).setSize(50,20); py += paso;

  Button uiReset = ui.addButton("Reset", 1, 65, 10, 20, 20);
  Label uilReset = uiReset.captionLabel();
  uilReset.style().marginTop = 0;
  uilReset.style().marginLeft = 22;  
  
  py += salto*paso;
  
  ui.addTextlabel("Display", "DISPLAY", 10, py); py += paso;
  
  Toggle uiNormals = ui.addToggle("Normals", showNormals, 10, py, 20, 20); py += paso;
  uiNormals.setLabel("Normals");
  Label uilNormals = uiNormals.captionLabel();
  uilNormals.style().marginTop = -17; //move upwards (relative to button size)
  uilNormals.style().marginLeft = 25; //move to the right
  
  Toggle uiColors = ui.addToggle("Colors", normalColors, 10, py, 20, 20); py += paso;
  uiColors.setLabel("Colors");
  Label uilColors = uiColors.captionLabel();
  uilColors.style().marginTop = -17; //move upwards (relative to button size)
  uilColors.style().marginLeft = 25; //move to the right  
  
  Toggle uiWireframe = ui.addToggle("Wireframe", isWireFrame, 10, py, 20, 20); py += paso;
  uiWireframe.setLabel("Wireframe");
  Label uilWireframe = uiWireframe.captionLabel();
  uilWireframe.style().marginTop = -17; //move upwards (relative to button size)
  uilWireframe.style().marginLeft = 25; //move to the right   

  Toggle uiSelection = ui.addToggle("Selection", isSelection, 10, py, 20, 20); py += paso;
  uiSelection.setLabel("Selection");
  Label uilSelection = uiSelection.captionLabel();
  uilSelection.style().marginTop = -17; //move upwards (relative to button size)
  uilSelection.style().marginLeft = 25; //move to the right 
  
  py += salto*paso;
  
  ui.addTextlabel("Modifiers", "MODIFIERS", 10, py); py += paso;
  
  Button uiRandom = ui.addButton("Random", 1, 10, py, 20, 20); py += paso;
  Label uilRandom = uiRandom.captionLabel();
  uilRandom.style().marginTop = 0;
  uilRandom.style().marginLeft = 22;  
  
  Button uiNoise = ui.addButton("Noise", 1, 10, py, 20, 20); py += paso;
  Label uilNoise = uiNoise.captionLabel();
  uilNoise.style().marginTop = 0;
  uilNoise.style().marginLeft = 22;
  
  Button uiLaplace = ui.addButton("Laplace", 1, 10, py, 20, 20); py += paso;
  Label uilLaplace = uiLaplace.captionLabel();
  uilLaplace.style().marginTop = 0;
  uilLaplace.style().marginLeft = 22;  

  py += salto*paso;
  
  ui.addTextlabel("ExtrusionSection", "EXTRUSION", 10, py); py += paso;  
  
  Slider uiShrink = ui.addSlider("Shrink", 0, 1, shrink, 10, py, 40, 10); py += paso/2;
  Slider uiExtrusion = ui.addSlider("Extrusion", -10, 10, extrusion, 10, py, 40, 10); py += paso;
  
  Button uiExtrude = ui.addButton("Extrude", 1, 10, py, 20, 20); py += paso;
  Label uilExtrude = uiExtrude.captionLabel();
  uilExtrude.style().marginTop = 0;
  uilExtrude.style().marginLeft = 22;    

  py += salto*paso;
  
  ui.addTextlabel("SelectionSection", "SELECTION", 10, py); py += paso;  

  Slider uiThreshold = ui.addSlider("Threshold", 0, 1, threshold, 10, py, 40, 10); py += paso;
  
  Button uiSelectRandom = ui.addButton("SelectRandom", 1, 10, py, 20, 20); py += paso;
  uiSelectRandom.setLabel("Sel. Random");
  Label uilSelectRandom = uiSelectRandom.captionLabel();
  uilSelectRandom.style().marginTop = 0;
  uilSelectRandom.style().marginLeft = 22;   
  
  Button uiSelectNoise = ui.addButton("SelectNoise", 1, 10, py, 20, 20); py += paso;
  uiSelectNoise.setLabel("Sel. Noise");
  Label uilSelectNoise = uiSelectNoise.captionLabel();
  uilSelectNoise.style().marginTop = 0;
  uilSelectNoise.style().marginLeft = 22;     
  
  Button uiSelectAll = ui.addButton("SelectAll", 1, 10, py, 20, 20); py += paso;
  uiSelectAll.setLabel("Sel. All");
  Label uilSelectAll = uiSelectAll.captionLabel();
  uilSelectAll.style().marginTop = 0;
  uilSelectAll.style().marginLeft = 22;  
}

/***************************
 * GUI :: controlEvent()
 *******/

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    
    // DISPLAY
    if (theEvent.controller().name()=="Normals") { 
      showNormals = !showNormals;
    }    
    if (theEvent.controller().name()=="Colors") { 
      normalColors = !normalColors;
    }   
    if (theEvent.controller().name()=="Wireframe") { 
      isWireFrame = !isWireFrame;
    }  
    if (theEvent.controller().name()=="Selection") { 
      isSelection = !isSelection;
    }      
    
    // MODIFIERS    
    if (theEvent.controller().name()=="Random") { 
      randomify(5);
    }  
    if (theEvent.controller().name()=="Noise") { 
      noisify(5);
    } 
    if (theEvent.controller().name()=="Laplace") { 
      laplacify();
    }     
    
    // EXTRUSION
    if (theEvent.controller().name()=="Shrink") { 
      shrink = theEvent.controller().value();
    }         
    if (theEvent.controller().name()=="Extrusion") { 
      extrusion = theEvent.controller().value();
    }     
    if (theEvent.controller().name()=="Extrude") { 
      extrudeFaces(faces, shrink, extrusion);
    }     
    
    // SELECTION
    if (theEvent.controller().name()=="Threshold") { 
      threshold = theEvent.controller().value();
    }        
    if (theEvent.controller().name()=="SelectRandom") { 
      selectRandom( threshold );
    }
    if (theEvent.controller().name()=="SelectNoise") { 
      selectNoise( threshold );
    }
    if (theEvent.controller().name()=="SelectAll") { 
      faces.clear();
      faces.addAll(mesh.faces);
    }    
    
    // UTILS
    if (theEvent.controller().name()=="Exit") {
      exit();
    }
    if (theEvent.controller().name()=="About") {
      isAbout = !isAbout;
    }  
    if (theEvent.controller().name()=="Reset") {
      reset();
    } 

    if (theEvent.controller().name()=="Export") { // grabar STL
      exportToSTL();
    }
  }
}

/***************************
 * GUI :: dropEvent()
 *******/
void dropEvent(DropEvent theDropEvent) {
  if (theDropEvent.isFile()) {
    filePath = theDropEvent.toString();
    println("Dropped in: " + filePath); 
    initMesh(filePath);
  }
}


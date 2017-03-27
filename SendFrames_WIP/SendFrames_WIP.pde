import processing.pdf.*;
import java.awt.print.PrinterJob;
import java.awt.print.PageFormat;
import java.awt.print.*;

import javax.print.*;
import javax.print.attribute.*;
import javax.print.attribute.standard.Sides;
import javax.print.attribute.standard.MediaPrintableArea;
import java.util.Arrays;




import codeanticode.syphon.*;
import java.io.*;
import javax.swing.JTextPane;


PGraphics canvas;



SyphonServer[] servers = new SyphonServer[3];

// Processing frames can be shared using the server. 

String myText = "";
PFont font;
Boolean newNNData = false;
String[] myNNData = new String[3];
int myNNDataCounter = 0;
final int numCharsPerLine = 26;
final boolean PRINT = false;
final int WIDTH = 297*2*2;
final int HEIGHT = 420*2;
final int FONTSIZE = 30;
final int CHARCOUNT = 150;
final int[] CHARCOUNTS = {CHARCOUNT,(int)(CHARCOUNT*1.4),(int)(CHARCOUNT*1.4*1.4)};
final int[] FONTSIZES = {FONTSIZE,(int)(FONTSIZE*1.4),(int)(FONTSIZE*1.4*1.4)};
final int[] STROKES = {1,2,4};
final String[] SCRIPTS = {"irvines.t7_cpu.t7","queer.t7_cpu.t7","witch.t7_cpu.t7"};
PImage img;
PFont myBookfont;
int pageNumber = 1; 

final String PATH = "/Users/fabienflorek/Projects/dwd/tempToPrint.pdf";


void settings(){
  size(WIDTH,HEIGHT,P3D);

   
  PJOGL.profile=1;
}

void setup() { 
  canvas = createGraphics(WIDTH, HEIGHT,P2D);
  //font = createFont("EBGaramond12-Regular",80);
  //pixelDensity(2);
  //textFont(font,80); 
  textAlign(LEFT);
  textMode(SHAPE);
  img = loadImage("images.jpeg");
  myBookfont = createFont("EBGaramond12-Regular",80,true);

 
  
  // Create syhpon server to send frames to VTP7 mapping software.
  servers[0] = new SyphonServer(this, "Processing Syphon1");
  servers[1] = new SyphonServer(this, "Processing Syphon2");
  servers[2] = new SyphonServer(this, "Processing Syphon3");


}
 
void doPdfNormal(String text) {

  PGraphics pdfcanvas = createGraphics(595 ,842,PDF,PATH);
  //PGraphics pdfcanvas = createGraphics(595,842);
  pdfcanvas.beginDraw();
  pdfcanvas.textFont(myBookfont);
  pdfcanvas.background(250);
  pdfcanvas.stroke(150);
  pdfcanvas.line(25, 800, 570, 800);
  pdfcanvas.textSize(10);
  pdfcanvas.fill(0);
  pdfcanvas.text(Integer.toString(pageNumber),550,810,595,842);
  pdfcanvas.textSize(12);
  pdfcanvas.text(text, 60,105, 495,780);
  pdfcanvas.dispose();
  pdfcanvas.endDraw();
  //image(pdfcanvas,0,0);
}

void doPdfCover(String text) {

  PGraphics pdfcanvas = createGraphics(595 ,842,PDF,PATH);
  //PGraphics pdfcanvas = createGraphics(595,842);
  pdfcanvas.beginDraw();
  pdfcanvas.textFont(myBookfont);
  pdfcanvas.background(250);
  pdfcanvas.stroke(150);
  pdfcanvas.line(25, 800, 570, 800);
  pdfcanvas.textSize(10);
  pdfcanvas.fill(0);
  pdfcanvas.text(Integer.toString(pageNumber),550,810,595,842);
  pdfcanvas.textSize(28);
  pdfcanvas.textAlign(CENTER);
  pdfcanvas.text("Chapter "+(pageNumber / 10 +1), 0,175, 595,780);
  pdfcanvas.textAlign(LEFT);
  pdfcanvas.textSize(12);
  pdfcanvas.text(text, 90,325, 425 , 780);
  pdfcanvas.dispose();
  pdfcanvas.endDraw();
  //image(pdfcanvas,0,0);
}

void createAndPrintPage(String text) {
  if (!PRINT) return;
  
  if (pageNumber%10==1) 
    doPdfCover(text);
  else
    doPdfNormal(text);
  
  try {
    printFile();
  }catch (Exception e) {
    e.printStackTrace();
  }

}

void printFile() throws PrintException, IOException {
    PrintService[] ps = PrintServiceLookup.lookupPrintServices(null, null);
    if (ps.length == 0) {
        throw new IllegalStateException("No Printer found");
    }
    System.out.println("Available printers: " + Arrays.asList(ps));
    PrintService myService = ps[0];
    
    DocAttributeSet das = new HashDocAttributeSet();
    das.add(new MediaPrintableArea(0, 0, 595 , 842, MediaPrintableArea.MM));


    FileInputStream fis = new FileInputStream(PATH);
    Doc pdfDoc = new SimpleDoc(fis, DocFlavor.INPUT_STREAM.AUTOSENSE, das);
    das.add(new MediaPrintableArea(0, 0, 210, 297, MediaPrintableArea.MM));

    DocPrintJob printJob = myService.createPrintJob();
    printJob.print(pdfDoc, new HashPrintRequestAttributeSet());
    fis.close();        
}

String runNNScript(String primeText,int nnScript) {
  String out ="";
  try {
    String line;
    String[] args = new String[] {"/bin/bash","-c","Projects/dwd/main.sh "+primeText+" "+ SCRIPTS[nnScript]};
    Process p = new ProcessBuilder(args).start();
    BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
    //throw away crap senteces at the starts
    //in.readLine();in.readLine();in.readLine();in.readLine();
    while ((line = in.readLine()) != null) {
       println(line);
       out+=line;
    }
  } catch (Exception err) {
    err.printStackTrace();
  }
  return out;
}

void draw() {
  textMode(SCREEN);
  if (!newNNData)   
    drawInput();
  else {
    //Charcounts[2] is the largers *2 per number of pages
    if (myNNDataCounter>=CHARCOUNTS[2]*2) {
        //we reached the end of datas
        newNNData=!newNNData;
        noLoop();
        myNNDataCounter = 0;
        pageNumber+=2;
        return;
    }
    //System.out.println(""+myNNDataCounter);
    if (myNNDataCounter <= (myNNData[0].contains(".") ? myNNData[0].lastIndexOf(".") : CHARCOUNTS[0]*2) && myNNDataCounter<=CHARCOUNTS[0]*2 && myNNDataCounter<myNNData[0].length()) 
      drawCanvas(myNNData[0].substring(0,myNNDataCounter),0);
    //System.out.println(myNNData[1]);
    if (myNNDataCounter <= (myNNData[1].contains(".") ? myNNData[1].lastIndexOf(".") : CHARCOUNTS[1]*2) && myNNDataCounter<=CHARCOUNTS[1]*2 && myNNDataCounter<myNNData[1].length()) 
      drawCanvas(myNNData[1].substring(0,myNNDataCounter),1);
    
    if (myNNDataCounter <= (myNNData[2].contains(".") ? myNNData[2].lastIndexOf(".") : CHARCOUNTS[2]*2) && myNNDataCounter<=CHARCOUNTS[2]*2 && myNNDataCounter<myNNData[2].length()) 
      drawCanvas(myNNData[2].substring(0,myNNDataCounter),2);
    myNNDataCounter+=1;
  }

}




void drawInput() {
  canvas.beginDraw(); // sets up the buffer
  canvas.background(250);
  canvas.textSize(40);
  canvas.text(myText, 30,30, width/2-60,height-100);
  canvas.strokeWeight(STROKES[1]);
  canvas.line(30, 800, width/2-30, 800);
  canvas.line(width/2+30, 800, width-60, 800);
  canvas.textSize(FONTSIZES[0]/2);
  canvas.fill(0);
  canvas.text(Integer.toString(pageNumber),width/2-45,810,width/2,842);
  canvas.text(Integer.toString(pageNumber+1),width-75,810,width,842);
  canvas.endDraw(); 
  image(canvas, 0, 0);
  servers[0].sendImage(canvas);
  servers[1].sendImage(canvas);
  servers[2].sendImage(canvas);

}

void drawCanvas(String text,int canvasNumber){
  canvas.beginDraw(); // sets up the buffer
  canvas.background(250);
  canvas.fill(220);
  canvas.strokeWeight(STROKES[canvasNumber]);
    canvas.line(30, 800, width/2-30, 800);
  canvas.line(width/2+30, 800, width-60, 800);
  canvas.textSize(FONTSIZES[canvasNumber]/3);
  canvas.fill(0);
  canvas.text(Integer.toString(pageNumber),width/2-45,810,width/2,842);
  canvas.text(Integer.toString(pageNumber+1),width-75,810,width,842);
  //canvas.image(img,50,50,100,100);
  canvas.textSize(FONTSIZES[canvasNumber]);
  //canvas.text(text, 30,30, width-60,height-60);
  if (text.length()<=CHARCOUNTS[canvasNumber]) canvas.text(text, 30,30, width/2-60,height-100);
  else {
    canvas.text(text.substring(0,CHARCOUNTS[canvasNumber]), 30,30, width/2-60,height-100);
    canvas.text(text.substring(CHARCOUNTS[canvasNumber],text.length()), width/2+30, 30, width/2-90,height-100);
    }
  
  canvas.endDraw(); 
  image(canvas, 0, 0);
  servers[canvasNumber].sendImage(canvas);

}



void keyPressed() { //everytime key is pressed, the value is stored within the function
  //we are still processing data from last inout ignore else
  if (newNNData) return;
  
  if (keyCode == BACKSPACE) { //checks if backspace was pressed
    if (myText.length() > 0) { 
      myText = myText.substring(0, myText.length()-1); 
    }
    loop();

  } 
  else if (keyCode == DELETE) { 
    myText = ""; 
  } 
  
  else if (keyCode != SHIFT) { 
      myText = myText + key;
  }
  
        if (keyCode == ' ') {
        myText = myText.substring(0, myText.length()-1);
        myText = myText + ' ';}
        
   if (keyCode == ENTER) {
     if (myText.equals("")) return;
     //input = myText; //inputs values become those of myText
       
       for (int i=0;i<3;i++) {
         String nntext = runNNScript("\""+myText+"\"",i); 
         System.out.println(""+i +"   "+nntext.length());
         System.out.println(""+i +"   "+nntext);
         myNNData[i] = nntext;
         createAndPrintPage(nntext);
     }

       
       newNNData=true;


      myText = ""; //myText is cleared of values and ready for new inputs

  }
}
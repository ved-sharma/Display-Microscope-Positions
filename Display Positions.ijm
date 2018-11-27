/****************************************************************************************************
Display Positions.ijm, Version 4.4.1 (November 27, 2018)
Author: Ved P. Sharma, E-mail: ved.sharma@einstein.yu.edu

Starting version 4.4
Changes
	- Updated the text in the introduction section
****************************************************************************************************/

/*
  This macro displays the positions added on our TES multiphoton microscope.
  It gives a visual map of where all the positions are located in x-y.
  This is helpful in finding if there are overlaps between different positions.

Following assumpution was made:
  z=6V corresponds to a 512x512 pixel^2 field
  z=4V corresponds to a 512x512*(4/6) =  341 pixel^2 field
  ... and so on

Code is base on the following series of transformations:
1. From the microscope stage coordinate system (top-right) to ImageJ coordinate system (top-left)
2a. Move ImageJ origin (0, 0) to the center of the canvas, if displaying only cell positions (xOffset and yOffset)
2b. Move ImageJ origin (0, 0) to the inside of the canvas, when displaying both the marker and cell positions (xOffset and yOffset)
3. Center each position by moving it by (position size/2) towards top-left direction. 

Features:
1. Checkbox option to open two .txt files. The first one should be the marker coordinates file and
    the second one should be the cell postions file.

2. Flexible canvas size based on x and y coordinates of added positions. 
    Square canvas is shown when displaying marker postions along with the cell postions.
    Origin (0, 0) lies inside the circle made by the three marker postions.
    Rectangular canvas is shown when displaying only cell postions. The origin (0,0) is at the center of the canvas.

3. All marker and cell postions are drawn centered and not at their top left position

4. Flexible X-Y axes line size, text size and line thickness of cell position outline

*/

var xOffset, yOffset;

Dialog.create("Display cell positions...");
Dialog.addNumber("\nX-Y calibration (zoom voltage):", 6);
Dialog.addChoice("Labels font size:", newArray("8", "12", "14", "18", "24"), "14");
items = newArray("Cell positions", "Marker positions + cell positions");
Dialog.addRadioButtonGroup("Display following positions:", items, 2, 1, "Cell positions");
Dialog.show();

zoomVoltage = Dialog.getNumber();
labelFontSize = Dialog.getChoice();
openTwoFiles = false;
if(!matches(Dialog.getRadioButton, "Cell positions"))
	openTwoFiles = true;

posWidth = 512*(zoomVoltage/6); // position width in pixels
extraCanvas = 2*posWidth; 
	// Enlarge canvas by these many pixels in X and Y, when displaying only cell positions
canvasEnlargeFactor = 1.05;
	// enlarge canvas size by this factor when dsiplaying both markers and cell postions

if(openTwoFiles) {
	path = File.openDialog("Select Marker Cooridinates text file...");
	filestring = File.openAsString(path);
	rows=split(filestring, "\n");
	positions = (rows.length - 4)/5 + 1;
	if(positions != 3)
		exit("Error: more than 3 positions found in Marker Coordinates text file.");
	xm = newArray(positions); // m for marker
	ym = newArray(positions);
	xmt = newArray(positions); // t for translated
	ymt = newArray(positions);

	for(i=0, a=0; i<rows.length; i++){
		if(startsWith(rows[i], "[Position")) {
			xm[a] = -parseFloat(substring(rows[i+1], 11));
				// negative sign to convert the top right coordinate system of the microscope stage
				// to the top left coordinate system of ImageJ
			ym[a] = parseFloat(substring(rows[i+2], 11));
			a++;
		}
	}		
// determine canvas size by fitting circle to 3 points, followed by rectangle fit
	newImage("Temp", "8-bit black", 100, 100, 1);
	makeSelection("point",xm,ym);
	run("Fit Circle");
	getSelectionBounds(xRect, yRect, wdRect, htRect);
	close(); // close temp image
//	print(xRect, yRect, wdRect, htRect);
	canvasSize = canvasEnlargeFactor*wdRect;
	canvasWidth = canvasSize;
	canvasHeight = canvasSize;
	xOffset = canvasEnlargeFactor*abs(xRect);
	yOffset = canvasEnlargeFactor*abs(yRect);
}

path = File.openDialog("Select Cell Positions text file...");
filestring = File.openAsString(path);
rows=split(filestring, "\n");
positions = (rows.length - 4)/5 + 1;
print(positions+" cell positions found.");
x = newArray(positions);
y = newArray(positions);

for(i=0, a=0; i<rows.length; i++){
	if(startsWith(rows[i], "[Position")) {
		x[a] = -parseFloat(substring(rows[i+1], 11));
			// negative sign to convert the top-right coordinate system of the microscope stage
			// to the top left coordinate system of ImageJ
		y[a] = parseFloat(substring(rows[i+2], 11));
		a++;
	}
}		

// find canvas size and Offsets for cell postions without markers
if(!openTwoFiles) {
	Array.getStatistics(x, min, max, mean, stdDev);
	canvasWidth = 2*maxOf(abs(min), abs(max));
	canvasWidth = canvasWidth + extraCanvas;

	Array.getStatistics(y, min, max, mean, stdDev);
	canvasHeight = 2*maxOf(abs(min), abs(max));
	canvasHeight = canvasHeight + extraCanvas;

	xOffset = canvasWidth/2;
	yOffset = canvasHeight/2;
//print(canvasWidth, canvasHeight, xOffset, yOffset);
}

newImage("Positions", "8-bit black", canvasWidth, canvasHeight, 1);
//newImage("Positions", "RGB black", canvasWidth, canvasHeight, 1);

if(openTwoFiles) {
	circleSize = canvasWidth/40;
//	print("circle size = "+circleSize);
	setColor("cyan");
	for(i=0; i<3; i++) {
		xmt[i] = xm[i]+xOffset;
		ymt[i] = ym[i]+yOffset;	
		fillOval(xmt[i]-circleSize/2, ymt[i]-circleSize/2, circleSize, circleSize);
	}
	
// draw circle encompassing marker coordinates
	makeSelection("point",xmt,ymt);
	run("Fit Circle");
	run("Line Width...", "line=20"); //setLineWidth() does not work
	frgd_Color = getValue("rgb.foreground");
	setForegroundColor(100, 100, 100); // draw circle in dark gray
	run("Draw", "slice");
	setForegroundColor(frgd_Color); // reset the background color
}

// draw X and Y axes
biggerDim = maxOf(canvasWidth, canvasHeight);
setColor("white");
setLineWidth(biggerDim/600); // line width dependent on canvas size
drawLine(0, yOffset, canvasWidth, yOffset); // draw x-axis in white
drawLine(xOffset, 0, xOffset, canvasHeight); // draw y-axis in white

// Draw zoom volatage at top left corner
textFontSize = biggerDim/20; // user can control the text font size here, which is dependent on the canvas size
textXoffset = biggerDim/200;
textYoffset = textFontSize + textXoffset;
setFont("SansSerif", textFontSize, "antiliased");
drawString("zoom Voltage = "+zoomVoltage+"V", textXoffset, textYoffset); // text location dependent on canvas size

// Draw cell positions as overlays
//run("Overlay Options...", "stroke=red width=10 fill=none show");
run("Overlay Options...", "stroke=red width="+biggerDim/600+" fill=none show");
for(i=0; i<a; i++) {
	makeRectangle(x[i]+xOffset-posWidth/2, y[i]+yOffset-posWidth/2, posWidth, posWidth); 
		// x and y offsets to translate origin (0, 0) to the center of the field
		// posWidth/2 correction to center each position
	run("Add Selection...");
}
run("Select None");
run("Labels...", "color=white font=&labelFontSize show"); // to display cell position numbers



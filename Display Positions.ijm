/*
  This macro displays the positions added on the TES multiphoton microscope.
  It gives a visual map of where all the positions are located in x-y.
  This is helpful in finding if there are overlaps between different positions.

Following assumpution was made:
  z=6V corresponds to a 512x512 um^2 field
  z=4V corresponds to a 512x512*(4/6) =  341 um^2 field
  z=2V corresponds to a 512x512*(2/6) =  171 um^2 field

// flexible  canvas size based on x and y coordinates of added positions
// center the postion squares
// checkbox option to open two txt files corresponding to marker coordinates and postions respectively

  Author: Ved P. Sharma, October 20, 2017
*/

var xOffset, yOffset;
//canvasSize = 5120*2;
Dialog.create("Display Positions...");
Dialog.addNumber("\nX-Y calibration (zoom voltage):", 6);
Dialog.addCheckbox("Open two files (marker coordinates and cell positions)", false);
Dialog.show();
zoomVoltage = Dialog.getNumber();
openTwoFiles = Dialog.getCheckbox();

if(openTwoFiles) {
	path = File.openDialog("Select Marker Cooridinates text file...");
print(path);
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
			ym[a] = parseFloat(substring(rows[i+2], 11));
			a++;
		}
	}		
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
		y[a] = parseFloat(substring(rows[i+2], 11));
//print(x[a], y[a]);
		a++;
	}
}		

canvasSize = calculateCS ();

newImage("Positions", "8-bit black", canvasSize, canvasSize, 1);
run("Set Scale...", "distance=1 known=1 unit=um");

circleSize = canvasSize/100;
print("circle size = "+circleSize);
run("Overlay Options...", "stroke=cyan width=2 fill=cyan show");
for(i=0; i<3; i++) {
	xmt[i] = xm[i]+xOffset-circleSize/2;
	ymt[i] = ym[i]+yOffset-circleSize/2;	
	makeOval(xmt[i], ymt[i], circleSize, circleSize);
	run("Add Selection...");
}
//run("Select None");

makeSelection("point",xmt,ymt);
run("Fit Circle");
run("Overlay Options...", "stroke=red width=10 fill=none show");
run("Add Selection...");

// draw X and Y axes
setColor("white");
setLineWidth(10);
drawLine(0, yOffset, canvasSize, yOffset); // draw x-axis in white
drawLine(xOffset, 0, xOffset, canvasSize); // draw y-axis in white
//setFont("SansSerif", 132, "antiliased");
//drawString("zoom Voltage = "+zoomVoltage+"V", 50, 200);


width = 512*(zoomVoltage/6);
run("Overlay Options...", "stroke=red width=10 fill=none show");
for(i=0; i<a; i++) {
	makeRectangle(x[i]+xOffset-width/2, y[i]+yOffset-width/2, width, width); 
		// canvasSize/2 to translate origin (0, 0) to the center of the field
		// width/2 correction to center each position
	run("Add Selection...");
}
run("Select None");

//************************** function for calculating canvas size ********************
function calculateCS() {
	if(openTwoFiles) {
		Array.getStatistics(xm, min, max, mean, stdDev);
		canvasWidth = abs(min) + abs(max);
		xOffset = 1.2*maxOf(abs(min), abs(max));

		Array.getStatistics(ym, min, max, mean, stdDev);
		canvasHeight = abs(min) + abs(max);
		yOffset = 1.2*maxOf(abs(min), abs(max));

		CS = 1.2*maxOf(canvasWidth, canvasHeight); // increase the canvas size by 20%
		return CS;
	}
	Array.getStatistics(x, min, max, mean, stdDev);
	canvasWidth = abs(min) + abs(max);
	Array.getStatistics(y, min, max, mean, stdDev);
	canvasHeight = abs(min) + abs(max);
	CS = 1.2*maxOf(canvasWidth, canvasHeight); // increase the canvas size by 20%
	return CS;
	
}


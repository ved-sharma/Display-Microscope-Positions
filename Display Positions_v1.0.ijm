/*
  This macro displays the positions added on the TES multiphoton microscope.
  It gives a visual map of where all the positions are located in x-y.
  This is helpful in finding if there are overlaps between different positions.

Following assumpution was made:
  z=6V corresponds to a 512x512 um^2 field
  z=4V corresponds to a 512x512*(4/6) =  341 um^2 field
  z=2V corresponds to a 512x512*(2/6) =  171 um^2 field

  Author: Ved P. Sharma, October 19, 2017
*/

canvasSize = 5120;
zoomVoltage = 6;

filestring = File.openAsString("");
rows=split(filestring, "\n");
positions = (rows.length - 4)/5 + 1;
print(positions+" positions found.");
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

newImage("Positions", "8-bit black", canvasSize, canvasSize, 1);
run("Set Scale...", "distance=1 known=1 unit=um");
setColor("white");
setLineWidth(1);
drawLine(0, canvasSize/2, canvasSize, canvasSize/2); // draw x-axis in white
drawLine(canvasSize/2, 0, canvasSize/2, canvasSize); // draw y-axis in white
setFont("SansSerif", 132, "antiliased");
drawString("zoom Voltage = "+zoomVoltage+"V", 50, 200);

width = 512*(zoomVoltage/6);
height = width;
run("Overlay Options...", "stroke=red width=2 fill=none set show");
for(i=0; i<a; i++) {
	makeRectangle(x[i]+canvasSize/2, y[i]+canvasSize/2, width, height);
	run("Add Selection...");
}
run("Select None");




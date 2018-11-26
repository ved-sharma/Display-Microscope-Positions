# Display-Microscope-Positions


![alt text](https://github.com/ved-sharma/Display-Microscope-Positions/blob/master/Data/markers%2BFOVs.png)

This macro displays the positions added on the TES multiphoton microscope.
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

//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=1 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xls use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area integrated limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images.");
Dialog.show();
ImagePath=getDirectory("Choose the folder with images");
list = getFileList(ImagePath);
list = Array.sort (list);

for (NumImages=0; NumImages<list.length; NumImages++) {
	if (endsWith(list[NumImages],"tif")) {
		//run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		open(ImagePath+list[NumImages]);
		ImageName = getTitle();
		print(ImageName);
		run("8-bit");
		run("Split Channels");
		selectWindow("C1-" + ImageName);
		rename("red");
		selectWindow("C2-" + ImageName);
		rename("green");
		selectWindow("C3-" + ImageName);
		rename("lines");
		selectWindow("lines");
		setAutoThreshold("Li dark");
		getThreshold(l,u);
		setThreshold(l+10,u);
		run("Convert to Mask");
		//run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
		run("Open");
		run("Close-");
		run("Skeletonize");
		run("Invert");
		run("Distance Map");
		rename("Distances");
		
		
		selectWindow("red");
		run("Duplicate...", "title=redmask");
		setAutoThreshold("IsoData dark");
		getThreshold(l,u);
		setThreshold(l-,u);
		run("Convert to Mask");
		imageCalculator("Min create", "red","redmask");
		run("Find Maxima...", "prominence=5 output=[Single Points]");
		rename("redpoints");
		run("Duplicate...", " ");
		run("Invert");
		run("Distance Map");
		rename("reddistance");
		selectWindow("green");
		run("Duplicate...", "title=greenmask");
		setAutoThreshold("RenyiEntropy dark");
		getThreshold(l,u);
		setThreshold(l-,u);
		run("Convert to Mask");
		imageCalculator("Min create", "green","greenmask");
		run("Find Maxima...", "prominence=5 output=[Single Points]");
		rename("greenpoints");
		run("Duplicate...", " ");
		run("Invert");
		run("Distance Map");
		rename("greendistance");

		selectWindow("redpoints");
		setThreshold(1,255);
		run("Analyze Particles...", "clear add");
		redcount = roiManager("count");
		run("Clear Results");
		selectWindow("Distances");
		roiManager("show all");
		roiManager("measure");
		selectWindow("greendistance");
		roiManager("show all");
		roiManager("measure");
		print("Red Foci");
		i=1;
		for (I = 1; I <= redcount; I++) {
			Distance = getResult("RawIntDen",I-1);
			focidis = getResult("RawIntDen", I+redcount-1);
			if(Distance <= 15){
				print(I,"	",i, "	", Distance*30, "	", focidis*30);
				i++;
			}
		}
		waitForUser;
		roiManager("Reset");
		
		selectWindow("greenpoints");
		setThreshold(1,255);
		run("Analyze Particles...", "clear add");
		greencount = roiManager("count");
		
		selectWindow("Distances");
		roiManager("show all");
		run("Clear Results");
		roiManager("measure");
		selectWindow("reddistance");
		roiManager("show all");
		roiManager("measure");
		print("Green Foci");
		j=1;
		for (J = 1; J <= greencount; J++) {
			Distance = getResult("RawIntDen",J-1);
			focidis = getResult("RawIntDen", J+greencount-1);
			if(Distance <= 15){
				print(J,"	",j, "	", Distance*30, "	", focidis*30);
				j++;
			}
		}
		waitForUser;
		
		run("Close All");
		run("Clear Results");
		roiManager("Reset");
		
	}
}

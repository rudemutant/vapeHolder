//polar litho import
module polLitho(
			file="polLitho add name",//image file
			imgD=[100,100,4.2,1],//x,y,thickest,thinnest
			rad=100,//radius of the projection
			hei=100,//projected height
			pAng=45,//angle to be projected
			slices=4096,
			rescale=true,//rescale the image to the projection
			invertP=false,//invert projection
			dispRot=[90,0,45],//display rotation
			centerY=true,//center on the y axis
			xyAdj=[0,0],//adjustment of the image before projection
			showCenter=0//if over 0, is the diameter of the sphere at the center
			){
	
	PZ=invertP?rad-(imgD[2]+imgD[3]):-rad;//new Z
	
	module litho(){//give z to svg image
		linear_extrude(imgD[2])
		translate(xyAdj)
		import(file);
	}

	imgScale=!rescale?[imgD[0],imgD[1]]:[
		(PI*(rad*2))*(pAng/360),
		hei ];

	if(rescale){echo("rescaled ",imgScale[0]/imgD[0]," ",imgScale[1]/imgD[1]);}

	sliceW=imgScale[0]/slices;
	sliceA=pAng/slices;
	
	if(showCenter>0){
		sphere(d=showCenter);
	}

	rotate(dispRot)
	translate(centerY?[0,-imgScale[1]/2]:[0,0,0])//move center to Y0
	for(i=[0:slices-1]){
		render()
		rotate([0,-sliceA*i,0]) 
		translate([-sliceW*i,0,PZ+imgD[3]])
		union(){
			//back bit
			translate([sliceW*i,0,-imgD[3]])
			cube([sliceW,imgScale[1],imgD[3]]);
			
			intersection(){
				//front bit
				translate([sliceW*i,0,0])
				cube([sliceW,imgScale[1],imgD[2]]);
				//litho
				resize(imgScale)
				litho();
			}
		}
	}
}

//polLitho();
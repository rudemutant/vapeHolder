

showShell=true;
showVape=false;
showHinges=true;
showWebbing=true;
showClasp=true;
showLitho=true;

//imports
use<lithoImport.scad>;

//printer stuff
pError=.25;

//vape measurements
vapDims=[58,29,77]+[pError,pError,pError];//vape body dimensions
rMin=7.5;//minor fillet radius 
rMaj=vapDims[1]/2;//major fillet radius

//cover stuff
meat=2;

//hinge stuff
hinges=4;
hingeGap=.5;
pinD=1.9;
hGap=.5;//designed gap between barrels
hingeJL=7.5;//hinge barrel lengths

hingeJLe=hingeJL-pError-hGap;
hingeJLE=hingeJL+pError+hGap;
leafW=5;

barrels=7;//greater than 3 
ballR=meat*.3;
pinH=(meat+ballR)*3-1.5;//pin height offset
anchorD=meat+ballR;//distance from the pin to touch meat

//web stuff
barrelO=0;//barrel length offset
webOffset=[0,0,5];
baseTrans=[0,0,(-(hingeJL*(barrels-1))/2)-(hingeJL/2)];
webD=meat*2;//web thickness

//mag-clamp dims
cMagDims=[5,1.5]+[pError*2,pError*2];//D,H

//display stuff

displayBox=[90,10,15];//angle,height,position Z

//circle display
cDisp=[90,20];

//charge port
chargePortO=13;
chargePortD=10;


module vapeBody(mindGaps=false,details=false,thicken=0){
	_rMaj=rMaj+thicken;
	_rMin=rMin+thicken;
	
	module corner(){
		rotate([0,0,-90])
		hull()
		rotate_extrude(angle=180,$fn=128)
		intersection(){
			translate([_rMaj-_rMin,0])
			circle(r=_rMin);
			
			square(_rMaj);//kills overlap error
	}}
	//body hull
	translate([0,0,-vapDims[2]/2])
	hull(){
		translate([(vapDims[0]/2)-rMaj,0,vapDims[2]-rMin])
		corner();//top right
		
		translate([(vapDims[0]/2)-rMaj,0,+rMin])
		rotate([180,0,0])
		corner();//bottom right
		
		translate([(-vapDims[0]/2)+rMaj,0,vapDims[2]-rMin])
		rotate([0,0,180])
		corner();//top left
		
		translate([(-vapDims[0]/2)+rMaj,0,+rMin])
		rotate([180,0,180])
		corner();//bottom left
	}	
	if(mindGaps){
		//hinge gaps
		cube([hingeGap,vapDims[1]+(meat*2),100],center=true);
		
		translate([(vapDims[0]/2)-rMaj,0,0])//z is manual)
		cube([hingeGap,vapDims[1]+(meat*2),100],center=true);
		
		cube([vapDims[0]+(2*meat),hingeGap,100],center=true);
	}
	module displayHole(){
		module side(){
			hull(){
				translate([rMaj+filletR,0,dh[1]/2])
				sphere(r=filletR+pError,$fn=128);
				
				translate([rMaj+filletR,0,-dh[1]/2])
				sphere(r=filletR+pError,$fn=128);
			}
		}
		module middle(){
			rotate_extrude(angle=dh[0],$fn=128){
				translate([0,-dh[1]/2])
				square( [rMaj+filletR+pError,dh[1]]);
				
				translate([rMaj+filletR,-dh[1]/2])
				circle(r=filletR+pError,$fn=128);
				
				translate([rMaj+filletR,dh[1]/2])
				circle(r=filletR+pError,$fn=128);
			}
		}
		dh=[90,10];
		filletR=meat;
		translate([(-vapDims[0]/2)+rMaj,0,0])
		rotate([0,0,180])
		rotate([0,0,(-displayBox[0]/2)])
		union(){
				
				side();
				
				rotate([0,0,displayBox[0]])
				side();
				
				middle();
		}
		
		
	}
	if(details){
		translate([0,0,20])
		displayHole();
		
		translate([0,0,-20])
		displayHole();
		
		//front litho
		translate([rMaj-(vapDims[0]/2),0,0])
		rotate([0,0,cDisp[0]/2+90])
		rotate_extrude(angle=cDisp[0])
		translate([0,-cDisp[1]/2])
		square([rMaj+meat+.1,cDisp[1]]);
		
		//charging port
		translate([-chargePortO,0,-vapDims[2]/2])
		cylinder(d=chargePortD,h=vapDims[2],center=true,$fn=128);
		//charging port anti-suctioncup
		translate([-chargePortO,0,-vapDims[2]/2-meat])
		rotate([0,90,0])
		cylinder(d=meat,h=vapDims[2],$fn=4);
		
		//signature
		#translate([-vapDims[0]/6.5,vapDims[1]/2,0])
		rotate([90,0,0])
		translate([0,0,-meat/2])
		linear_extrude(meat)
		rotate([0,0,90])
		//offset(r=1)
		scale(.3)
		import("/home/danny/Things/DB_sig1.svg",center=true);
	}
}

module vapeShell(){
//main body
	difference(){
		//basic skin
		//resize([(meat*2)+vapDims[0],(meat*2)+vapDims[1],(meat*2)+vapDims[2]])
		vapeBody(thicken=meat);
		
		vapeBody(details=true);//pokey bits
		
		//vape in/egress interference cutout
		translate([vapDims[0]/2,0,0])
		vapeBody();
		
		//basic cutout
		translate([vapDims[0]-(hingeGap/2),0,-(hingeGap/2)+vapDims[2]-((vapDims[2]/6)*2)])
		cube([2*vapDims[0],2*vapDims[1],2*vapDims[2]],center=true);
		
		//slidy bit
		translate([(vapDims[0]/2)-rMaj-(hingeGap/2),-vapDims[1],-vapDims[2]])
		cube([2*vapDims[0],2*vapDims[1],2*vapDims[2]],center=false);
		
		//mouth comfort rod
		translate([vapDims[0]/2,0,(vapDims[2]/2)-(rMaj)])
		rotate([0,-45,0])
		cylinder(d=vapDims[1]*1.5,h=vapDims[2],$fn=128);
}}

module hinge(swapSides=1,swapDouble=0){// zero|one, even|odd
	module pin(length=hingeJLE){
		translate([0,0,pinH])
		rotate([90,0,0])
		cylinder(d=pinD,h=length,$fn=128,center=true);
	}
	module head(){
		off=1;
		radius=5;
		rotate([90,0,0])
		rotate_extrude(angle=360,$fn=128)
		intersection(){
			translate([0,-hingeJLe/2,0])
			square(hingeJLe);
			
			translate([-off,0,0])
			circle(r=radius,$fn=512);
	}}
	module root(){
		//root ball
		translate([anchorD,-hingeJLe/2+ballR,meat])
		sphere(r=ballR,$fn=128);
	}
	module barrel(){
		hull(){
			translate([0,0,pinH])
			head();
			root();
	}}
	module leaf(){
		translate([leafW,-hingeJL/2,0])
		rotate([-90,0,0])
		//cylinder(d=meat,h=hingeJL,$fn=128);
		hull(){
			translate([0,0,hingeJL],$fn=128)
			sphere(d=meat,$fn=128);
			
			sphere(d=meat,$fn=128);
		}
	}
	module bead(double=true){
		difference(){
			union(){
				barrel();
				if(double){
					mirror([0,1,0])
					barrel();
			}}
			pin();
		}
		hull(){
			leaf();
			root();
			if(double){
				mirror([0,1,0])
				root();
	}}}
	//
	translate([0,-(hingeJL*(barrels-1))/2])
	for(i=[0:barrels-1]){
		translate([0,(i*hingeJL)])
		mirror([(i+swapSides)%2,0,0])
		bead(double=(i+swapDouble)%2);
}}

module hinges(){
	//clockwise from the top
	difference(){
		union(){
			translate([0,vapDims[1]/2,0])
			rotate([-90,0,0])
			mirror([0,1,0])
			hinge();

			translate([(vapDims[0]/2)-rMaj,vapDims[1]/2,0])
			rotate([-90,180,0])
			//mirror([0,1,0])
			hinge();

			translate([(vapDims[0]/2),0,0])
			rotate([90,-180,90])
			mirror([0,1,0])
			hinge();

			translate([(vapDims[0]/2)-rMaj,-vapDims[1]/2,0])
			rotate([-90,180,180])
			//mirror([0,1,0])
			hinge();
		}
		vapeBody();
}}

module webbing(){
	leafList=[
		//[0,vapDims[1]/2,0],
		[-leafW,vapDims[1]/2,0],
		[+leafW,vapDims[1]/2,0],
		//[(vapDims[0]/2)-rMaj,vapDims[1]/2,0],
		[(vapDims[0]/2)-rMaj-leafW,vapDims[1]/2,0],
		[(vapDims[0]/2)-rMaj+leafW,vapDims[1]/2,0],
		//[(vapDims[0]/2),0,0],
		[(vapDims[0]/2),+leafW,0],
		[(vapDims[0]/2),-leafW,0],
		//[(vapDims[0]/2)-rMaj,-vapDims[1]/2,0]
		[(vapDims[0]/2)-rMaj+leafW,-vapDims[1]/2,0],
		[(vapDims[0]/2)-rMaj-leafW,-vapDims[1]/2,0],
		//unhinged
		[-leafW,-vapDims[1]/2,0],
		[+leafW,-vapDims[1]/2,0],
		[-leafW,-vapDims[1]/2,0],
		[+leafW,-vapDims[1]/2,0],
	];
	leafOrderOld=[ [[1,2],[5,6]],//horizontal
					[[3,4],[7,8]],
					[0,3,4,7],//diagonal
					[1,2,5,6]];
	
	leafOrder=[ //[[3,4],[7,8],[8,8]],//horizontal
					//[[1,2],[5,6],[8,8]],
					[ [3,4],[7,8], ],
					[ [1,2],[5,6], ],
					//[1,2,1,2,3,4],//diagonal
					//[0,3,3,0,4,3]];
					[1,2,5,6,6],
					[0,3,4,7,8]
					];
					
	//connections
	module mLeaf(){
		hull(){
			translate([0,0,-barrelO])
			sphere(d=webD,$fn=128);
			translate([0,0,hingeJL+barrelO])
			sphere(d=webD,$fn=128);
		}
	}
	
	difference(){
		union(){
			//horizontal connections
			translate(baseTrans)
			for(j=[0:barrels-1]){
				translate([0,0,j*hingeJL])
					for(i=[0:len(leafOrder[0])-1]){
						hull(){
							translate(leafList[
											leafOrder[j%2][i][0]
										])
							mLeaf();
							translate(leafList[
											leafOrder[j%2][i][1]
										]
										)
							//cylinder(h=hingeJL,d=meat,$fn=128);
							mLeaf();
			
			}}}
			//diagonal connections
			echo("diagonal");
			translate(baseTrans+[0,0,hingeJL])
			for(j=[0:floor(barrels/2)-1]){
				translate([0,0,(j*2)*hingeJL])
				for(i=[0:len(leafOrder[2])-1]){
					hull(){
						translate(leafList[leafOrder[2][i]])
						//cylinder(h=hingeJL,d=meat,$fn=128);
						mLeaf();
						
						translate([0,0,-hingeJL])
						translate(leafList[leafOrder[3][i]])
						//cylinder(h=hingeJL,d=meat,$fn=128);
						mLeaf();
					}
					hull(){
						translate(leafList[leafOrder[2][i]])
						//cylinder(h=hingeJL,d=meat,$fn=128);
						mLeaf();
						
						translate([0,0,+hingeJL])
						translate(leafList[leafOrder[3][i]])
						//cylinder(h=hingeJL,d=meat,$fn=128);
						mLeaf();
					}
				}
			}
		}
		vapeBody(mindGaps=true);
}}

module magnet(){
	rotate([90,0,0])
	cylinder(d=cMagDims[0],h=cMagDims[1],$fn=128);
}

module magnetSkin(){
	rotate([90,0,0])
	difference(){
		hull(){
			translate([0,0,0])
			cylinder(d=cMagDims[0]+meat,h=cMagDims[1],$fn=128);
			
			translate([cMagDims[0]/2,-cMagDims[0]/2,cMagDims[0]/2])
			sphere(d=cMagDims[0],$fn=128);
		}
		cylinder(d=cMagDims[0],h=cMagDims[1],$fn=128);
	}
}

module magClasp(numC=4){//number of clasps
	leafL=hingeJL*2;
	zOff=hingeJL*2+2;
	function magOff(i)=[
		[	-hingeGap/2,
			(-vapDims[1]/2)-meat-(cMagDims[1]),
			(i*leafL)-zOff
		],
		[	hingeGap/2,
			(-vapDims[1]/2)-meat-(cMagDims[1]),
			(i*leafL)-zOff
		]
	];
	module shell(){
		if(showShell){
			difference(){
				union(){
					vapeShell();
					
					translate(webOffset)
					webbing();
					
					translate(webOffset)
					hinges();
					
					//magnet stuff
					for(i=[0:numC-1]){
							translate(magOff(i)[1])
							rotate([0,0,90])
							magnetSkin();//right side
						
						translate(magOff(i)[0])
						mirror([1,0,0])
						rotate([0,0,90])
						magnetSkin();//left side
					}
				}
				//more magnet stuff
				for(i=[0:numC-1]){
					translate(magOff(i)[1])
					rotate([0,0,90])
					#magnet();
					
					translate(magOff(i)[0])
						rotate([0,0,-90])
						magnet();//left side
				}
				vapeBody(details=true);
			}
		}
	}
	
	shell();
		
}

module magStat(){
	
}

module magDyn(){

}

module lithos(){
	//front litho
	lithoT=[1,2];//back,thickest part of litho that isn't the back
	lThick=[
		(lithoT[0]>meat?meat:lithoT[0]),
		((lithoT[0]+lithoT[1])>meat?
			lithoT[0]>meat?0:
			meat-lithoT[1]+lithoT[0]
		:lithoT[0])
	];
	echo("lithoT\n",lithoT);
	echo("lithoT[0]+lithoT[1]=",lithoT[0]+lithoT[1]);
	echo("meat=",meat);
	echo("lThick\n",lThick);
	
	translate([(-vapDims[0]/2)+rMaj,0,0])
	rotate([0,0,90])
	polLitho(
			file="circle.svg",//image file
			imgD=[25,25,lThick[1],lThick[0]],//x,y,thickest,thinnest
			rad=rMaj+meat,//radius of the projection
			hei=20,//projected height
			pAng=90,//angle to be projected
			slices=128,
			rescale=true,//rescale the image to the projection
			invertP=false,//invert projection
			dispRot=[90,0,45],//display rotation
			centerY=true,//center on the y axis
			xyAdj=[-.2,0],//adjustment of the image before projection
			showCenter=0,
	);


}

if(showLitho){
	lithos();
}

if(showClasp){
	magClasp();
}

if(showWebbing){
	if(!showClasp){
		translate(webOffset)
		webbing();
	}
}
if(showHinges){
	if(!showClasp){
		translate(webOffset)
		hinges();
	}
}
if(showVape){
	color("blue")
	vapeBody(thicken=0);
}
if(showShell){
	if(!showClasp){
		vapeShell();
	}
}
// Copyright (C) 2026 Geoff Sobering

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program (see the LICENSE file in this directory).  
// If not, see <https://www.gnu.org/licenses/>.

include <OpenSCAD_Lib/MakeInclude.scad>
include <OpenSCAD_Lib/chamferedCylinders.scad>
include <OpenSCAD_Lib/Hardware.scad>

firstLayerZ = 0.3;
upperLayerZ = 0.2;
bottomTwoLayersZ = firstLayerZ + upperLayerZ;

makeItemModule = false;
makeQuarterInchDrillBit = false;
makeQuarterInchReamer = false;
makeQuarterTwentyTap = false;

// Comfortable hand-grip:
baseOD = 25;
knurlXY = 3;

// Diameter of the flat-end on the bottom:
//flatEndFlatOD = 20; // Good in general, and for 19mm chamfer.
flatEndFlatOD = 23; // 3/4" chamfer bit.

flatEndSphereDia = baseOD+3;
flatEndZ = sqrt((flatEndSphereDia/2)^2 - (flatEndFlatOD/2)^2);
flatEndOffsetZ = flatEndZ;

echo(str("flatEndSphereDia = ", flatEndSphereDia));
echo(str("flatEndOffsetZ = ", flatEndOffsetZ));

// m3 machine-screw
nutRecessSide = M3_squareNutSide;
headRecessDia = M3_socketHeadRecesssDia;
holeDia = M3_holeDia;

module quarterInchReamer()
{
	name="quaterinchDia";
	topBanner(name);

	baseZ = 40;
	classic(drillHoleDia=6.7, baseZ=baseZ, boltPosZ=baseZ/2-2, toolRecessZ=35);

	bottomBanner(name);
}

module quarterInchDrillBit()
{
	name="quarterInchDrillBit";
	topBanner(name);

	toolRecessZ = 25;
	classic(drillHoleDia=6.5, baseZ=40, boltPosZ=toolRecessZ/2, toolRecessZ=toolRecessZ);

	bottomBanner(name);
}

module quarterTwentyTap()
{
	name="quarterTwentyTap";
	topBanner(name);

	tapShankZ = 25;
	tapShankDia = 5.8;

	tapSquareEndDia = 6.1; //tapShankDia;
	tapSquarteEndCZ = tapSquareEndDia/2;
	tapSquareEndZ = 10 + tapSquarteEndCZ; // including chamfer

	difference()
	{
		classic(drillHoleDia=0, baseZ=40, boltPosZ=tapShankZ/2, toolRecessZ=0);

		hull()
		{
			translate([0,0,-1]) simpleChamferedCylinder(d=tapShankDia, h=tapShankZ+1, cz=tapShankDia/2);
			#translate([0,0,tapShankZ]) cylinder(d=tapSquareEndDia, h=0.1, $fn=4);
		}
		translate([0,0,tapShankZ]) simpleChamferedCylinder(d=tapSquareEndDia, h=tapSquareEndZ, cz=tapSquarteEndCZ, $fn=4);
	}

	bottomBanner(name);
}

module itemModule()
{
	name="itemModule";
	topBanner(name);

	insetDia = 19.5; // 3/4" chamfer bit
	insetZ = 10; // 3/4" chamfer bit
	drillHoleDia = 6.5;
	bitShaftLen = 19;
	boltPosZ = insetZ + bitShaftLen/2;

	difference() 
	{
		classic(drillHoleDia=drillHoleDia, baseZ=40, boltPosZ=boltPosZ, toolRecessZ=100); // 1/4"
		
		// Inset for the tool:
		tcy([0,0,-100+insetZ], d=insetDia, h=100);
	}

	// Sacrificial layer at bottom of inset:
	tcy([0,0, insetZ], d=drillHoleDia+1, h=upperLayerZ);

	bottomBanner(name);
}

module topBanner(name)
{
	echo(str("Module: ", name, " vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"));
}

module bottomBanner(name)
{
	echo(str("End: ", name, " ^^^^^^^^^^^^^^^^^^^^^^^^"));
}

module classic(drillHoleDia, baseZ, boltPosZ, toolRecessZ)
{
	echo(str("boltPosZ = ", boltPosZ));
	echo(str("drillHoleDia = ", drillHoleDia));
	echo(str("toolRecessZ = ", toolRecessZ));

  difference()
  {
    exterior(baseZ=baseZ);

	// Hole/Recess for the tool shank:
	toolCZ = drillHoleDia/2;
	toolZ = toolRecessZ + toolCZ;
    translate([0,0,-1]) simpleChamferedCylinder(d=drillHoleDia, h=toolZ+1, cz=toolCZ);

	// Cut a slot:
	tcu([-0.25, 0, -10], [0.5, 100, 400]);

	boltHole(boltPosZ);
  }
}

module boltHole(boltPosZ)
{
	translate([0, baseOD/4+0.5, boltPosZ]) rotate([0,90,0])
	{
		// Through hole:
		tcy([0,0,-100], d=holeDia, h=200);
		// Head recess:
		tcy([0,0,4.5], d=headRecessDia, h=50);
		// Square nut recess:
		tcu([-nutRecessSide/2, -nutRecessSide/2, -50-4.5], [nutRecessSide, nutRecessSide, 50]);
	}
}

module exterior(baseZ)
{
	difference()
	{
		union()
		{
			cylinder(d=baseOD, h=baseZ);
			deltaAngle = 360/20;
			for(a = [0 : deltaAngle : 359])
			{
				rotate([0,0,a+deltaAngle/2])
				translate([baseOD/2-0.6, 0, 0])
					rotate([0,0,45])
					tcu([-knurlXY/2, -knurlXY/2, 0], [knurlXY,knurlXY,baseZ]);
			}
		}

		// Trim off the points:
		difference()
		{
			tcy([0,0,-10], d=100, h=400);
			tcy([0,0,-11], d=baseOD+2.6, h=410);
		}

		// Round off the top:
		translate([0,0,baseZ-baseOD/2-2.5]) difference()
		{
			cylinder(d=100, h=100);
			sphere(d=baseOD+5);
		}

		// Chamfer the bottom:
		translate([0,0,flatEndOffsetZ]) difference()
		{
			tcy([0,0,-100], d=100, h=100);
			tsp([0,0,0], d=flatEndSphereDia);
		}
	}
}

module clip()
{
	//tc([-200, -200, baseZ/2], 400);
	//tc([0, -200, -10], 400);
	tc([-200, 0, -10], 400);
	// tcy([0,0,24], d=200, h=400);
}

if(developmentRender)
{
	// display() itemModule();
	// display() quarterInchDrillBit();
	display() quarterTwentyTap();

	dx1 = 50;
	dx = 30;
	display() translate([dx1,0,0]) quarterInchReamer();
	display() translate([dx1+1*dx,0,0]) quarterInchDrillBit();
	display() translate([dx1+2*dx,0,0]) itemModule();
	display() translate([dx1+3*dx,0,0]) quarterTwentyTap();
}
else
{
	if (makeItemModule) itemModule();
	if(makeQuarterInchDrillBit) quarterInchDrillBit();
	if(makeQuarterInchReamer) quarterInchReamer();
	if(makeQuarterTwentyTap) quarterTwentyTap();
}

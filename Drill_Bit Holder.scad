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
makeQuarterInchDia = false;

//drillHoleDia = 3.96; // 5/32"
//drillHoleDia = 4.76; // 3/16"
// drillHoleDia = 6.5; // 1/4"

// Comfortable hand-grip:
baseOD = 25;
baseZ = 40;
knurlXY = 3;

// Diameter of the flat-end on the bottom:
//flatEndFlatOD = 20; // Good in general, and for 19mm chamfer.
flatEndFlatOD = 23; // 3/4" chamfer bit.

// Inset params:
insetDia = 19.5; // 3/4" chamfer bit
insetZ = 10; // 3/4" chamfer bit
bitShaftLen = 19; // 3/4" chamfer bit

// Position of the clamp-bolt:
//boltPosZ = baseZ/2; // Halfway, good for drill-bits.
boltPosZ = insetZ + bitShaftLen/2; // For shorter items.

flatEndSphereDia = baseOD+3;
flatEndZ = sqrt((flatEndSphereDia/2)^2 - (flatEndFlatOD/2)^2);
flatEndOffsetZ = flatEndZ;

echo(str("boltPosZ = ", boltPosZ));
echo(str("flatEndSphereDia = ", flatEndSphereDia));
echo(str("flatEndOffsetZ = ", flatEndOffsetZ));

// m3 machine-screw
nutRecessSide = M3_squareNutSide;
headRecessDia = M3_socketHeadRecesssDia;
holeDia = M3_holeDia;

/* boltLength = 18.2; // Measured 6-32 3/4" */
boltLength = 25.0; // Measured 6-32 1"

boltLengthInNut = 5.0; // "Tall" nyloc

clampOffset = (boltLength - boltLengthInNut)/2;
echo(str("clampOffset = ", clampOffset));

module quarterInchDia()
{
	name="quaterinchDia";
	topBanner(name);

	classic(drillHoleDia=6.5); // 1/4"

	bottomBanner(name);
}

module itemModule()
{
	name="itemModule";
	topBanner(name);

	classic(drillHoleDia=6.5); // 1/4"

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

module classic(drillHoleDia)
{
	
	echo(str("drillHoleDia = ", drillHoleDia));

  difference()
  {
    exterior();

    tcy([0,0,-100], d=drillHoleDia, h=200);

		// Cut a slot:
		tcu([-0.25, 0, -10], [0.5, 100, 400]);

		boltHole();
  }

  // Sacrificial layer at bottom of inset:
  tcy([0,0, insetZ], d=drillHoleDia+1, h=upperLayerZ);
}

module boltHole()
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

module exterior()
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

    // Inset for the tool:
    tcy([0,0,-100+insetZ], d=insetDia, h=100);
  }
}

module clip()
{
	//tc([-200, -200, baseZ/2], 400);
	//tc([0, -200, -10], 400);
  //tc([-200, 0, -10], 400);
}

if(developmentRender)
{
	// display() itemModule();

	display() quarterInchDia();
	display() translate([-50,0,0]) itemModule();
}
else
{
	if (makeItemModule) itemModule();
	if(makeQuarterInchDia) quarterInchDia();
}

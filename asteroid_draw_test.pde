// @pjs preload must be used to preload the image so that it will be available when used in the sketch  
/* @pjs preload="images/armored_io_logo.png"; */ 

Asteroid myAsteroid;
//PShape img;

void setup()
{
	println("setup test");
	size(500, 500);      // set screen size
    noStroke();            // don't draw any strokes around shapes
    smooth();              // turn on anti-aliasing
	noLoop();
	println("setup cool");
	//aArray = new Asteroid[1];
	//logo = loadImage("images/armored_io_logo.png");
	/*
	for( int i=0; i < aArray.length; i++ )
    {
		aArray[i] = new Asteroid(randomNum(3, 10));
    }
	*/
	//img = loadShape("images/asteroids2.svg");
	//aArray[0] = new Asteroid();
	myAsteroid = new Asteroid();
	
}

void draw()
{
	println("test");
	background( 128 ); // reset background, erase old drawing
	//image(logo, (width / 2) - (logo.width / 8), (height / 2) - (logo.height / 8), (logo.width / 4), (logo.height / 4));
	/*
	for (int i = 0; i < aArray.length; i++)
    {
		aArray[i].draw();  // draw the asteroid
    }
	*/
	//shape(img, 0, 0, 200, 200);
	myAsteroid.draw();
	noLoop();
}

void randomNum(little, big)
{
	return (Math.floor (Math.random() * (big - little) + little));
}

class Asteroid
{
	int asteroid_center_x;
	int asteroid_center_y;
	//int points = new Array();
	PShape img;
	
	Asteroid()
	{
		//asteroid_center_x = randomNum(0, width);
		asteroid_center_x = 0;
		//asteroid_center_y = randomNum(0, height);
		asteroid_center_y = 0;
		println("made asteroid: (" + asteroid_center_x + ", " + asteroid_center_y + ")");
		/*
		println("making asteroid with " + sides + " sides....");
		float size;
		size = randomNum(20,40); 
		println("asteroid size: " + size);
		
		for (i = 1; i < (sides + 1); i++)
		{
			var x = randomNum(asteroid_center_x, asteroid_center_x + size);
			var y = randomNum(asteroid_center_y, asteroid_center_y + size);
			println("    x = " + x + ", y = " + y);
			points[i + (i - 2)] = x;
			points[i + (i - 1)] = y;
		}
		
		for (i = 0; i < points.length; i += 2)
		{
			println("(" + points[i] + ", " + points[i + 1] + ")");
		}*/
		
		img = loadShape("images/asteroids2.svg");
		
	}
	
	void draw()
	{
		println("entering draw loop...");
		shape(img, asteroid_center_x, asteroid_center_y);
	}
/*
	stroke(0);
		beginShape();
		
			for(i = 0; i < sides; i += 2)
			{
				vertex(points[i], points[i + 1]);
			}
		
		
vertex(92, 116)
vertex(93, 128)
vertex(100, 101)
vertex(101, 108)
vertex(106, 105)
vertex(109, 105)
vertex(113, 118)
vertex(118, 113)
		endShape(CLOSE);
	}
} // end draw()
	*/

} //end class Asteroid
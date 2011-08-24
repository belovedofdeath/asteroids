// @pjs preload must be used to preload the image so that it will be available when used in the sketch  
/* @pjs preload="images/armored_io_logo.png"; */ 

//MEL'S DISCLAIMER: yes this code is ugly.  will become beautiful once it works. O.O

//import processing.video.*;
 
/*
    This is a basic particle system.  The particles move around and are
    either attracted to or repelled from the mouse.
     
    Asteroid System
    Asteroids:
      Member variables
        - position
        - velocity
        - acceleration
         
      Methods:
        - constructor
        - update()
        - draw()
     
*/
boolean debugOn = true;
Asteroid[] aArray;                // declare p - p is null!
PImage logo;
int killThreshold = 100; //how far away from center before it stops moving
int width = 500;
int height = 500;
int numAsteroids = 25; 
int backgroundColor = 0;
 
void setup()
{
    size(width, height);      // set screen size
    noStroke();            // don't draw any strokes around shapes
    smooth();              // turn on anti-aliasing
	
    if (debugOn) { console.log("setup cool."); }
    aArray = new Asteroid[numAsteroids];    // set up my array of Asteroids 
    if (debugOn) { console.log("instantiating asteroids..."); }
    createAsteroids();
	if (debugOn) { console.log("made asteroids."); }
	logo = loadImage("images/armored_io_logo.png");
	if (debugOn) { console.log("set image"); }
}
 
/**
This is a processing function.  It gets called automatically 25 times a second. 
You can make it update faster by setting frameRate( n ) in setup (where n is a number
of frames per second)
*/
void draw()   
{
	if (debugOn) { console.log("starting draw round..."); }
    background(backgroundColor);        // set background to black, erase old drawing
    if (debugOn) { console.log("set background."); }
    updateAsteroids();
	if (debugOn) { console.log("finished updating aArray"); }
	// format for image: iamge(PImage object, x, y, width, height)
	drawLogo();
	if (debugOn) { console.log("finished printing logo"); }
}

void drawLogo()
{
	var scaleLogo = 4;
	var doublingFactor = scaleLogo * 2;
	var logoX = (width / 2) - (logo.width / doublingFactor);
	var logoY = (height / 2) - (logo.height / doublingFactor);
	var logoDisplayWidth = (logo.width / scaleLogo);
	var logoDisplayHeight = (logo.height / scaleLogo);
	image(logo, logoX, logoY, logoDisplayWidth, logoDisplayHeight);
}

void createAsteroids()
{
	if (debugOn) { console.log("entering createAsteroids..."); }
	// loop through the Asteroid array (aArray) and instantiate new asteroids for each element and set each one with a random velocity
	for( int i=0; i < aArray.length; i++ )
    {
		if (debugOn) { console.log("   making asteroid...."); }
		aArray[i] = new Asteroid( random( width ), random( height ), 0, i );
		aArray[i].vel.set( random(-1, 1), random(-1, 1), 0 );		
    }
}

void updateAsteroids()
{
	if (debugOn) { console.log("entering updateAsteroids..."); }
	for (int i = 0; i < aArray.length; i++)
    {
		if (debugOn) { console.log("   updating asteroid...."); }
		if (aArray[i] != null)
		{
			aArray[i].draw();  // draw the asteroid
		}
    }
}
/**
This is a processing function.  It gets called automatically whenever the user releases
a mouse button
*/
void mouseReleased()
{
    console.log( "Mouse released!" );
    for ( int i=0;i<aArray.length;i++ )          // loop through all particles, and for each one...
    {
        aArray[i].attract = !aArray[i].attract;  // ...use NOT (!) to flip true to false and vice versa
        // eg: !true == false
        // so, if attract == true then !attract == false (note the exclamation mark)
    }
}
 
/**
This is a processing function - it gets called automatically
whenever the use released a key on the keyboard
*/
void keyReleased()
{
    if ( key == ' ' )    // check which key was pressed - note the single quotes ''
    {
        exit();          // quit the program
    }
}

void randomNum(little, big)
{
	return (Math.floor (Math.random() * (big - little) + little));
}
 
/**
This is our asteroid class - it first defines member variables, then a constructor, and then
it defines methods.
*/
class Asteroid
{
    // member variables
    PVector pos;    // pos.x pos.y pos.z
    PVector vel;    // vel.x vel.y vel.z
    PVector acc;    // acc.x acc.y acc.z
	int id;			//corresponds with array key
	int size;
	PShape img;
	float rotation;
    boolean attract;    // true if asteroids should move toward the center, false otherwise
     
    /**
    Constructor method - used with new, as in
    Asteroid p = new Asteroid( x, y, z );
    */
    Asteroid( float x, float y, float z, int idin )
    {
        // instantiate the vectors so we don't get null pointer exceptions
        pos = new PVector(x, y);   // set the position based on parameters
        vel = new PVector();
        acc = new PVector();
        attract = true;
		id = idin;
		var shapeName = "asteroid" + String(randomNum(2,5));
		img = loadShape("images/" + shapeName + ".svg");
		this.setAsteroidRotation();
		size = randomNum(20,40); //this will eventually be set by the type of attack is incoming
    } 
	
	void setAsteroidRotation() //seal of "works for now" from nick
	{
		console.log("setting rotation");
		var randomPercent = randomNum(1,2) == 1;
		var brakes = randomNum(20,80);
		
		//randomly set rotation to either clockwise or counterclockwise
		if (randomPercent)
		{
			rotation = Math.random() / brakes;
		} else {
			rotation = (Math.random() / brakes) * -1;
		}
	}
     
    /**
    update() - call once each frame to update the position of the particle
    */
    void draw()
    {
		if (stillAlive()) //this needs to say "if it's within X of the center, EXTERMINATE!!
		{
			img.rotate(rotation);
			attractor();               // change acc to make particles accelerate toward the mouse
			vel.add( acc );               // apply acceleration to velocity
			pos.add( vel );               // add velocity to positon (move particle)
			vel.mult( 0.98f );            // apply friction (otherwise particles end up moving too fast)
			bounce();                     // bounce off edges of screen
			acc.set( 0, 0, 0 );           // reset acceleration - we calculate is fresh each loop
			shape(img, pos.x, pos.y, size, size);
		}
	}  // end of Asteroid.update()
    
    void stillAlive(){
		//this is where i need to kill the asteroid if it's too close
		//this is where mel started fuckin' with shit
		PVector center = new PVector( width / 2, height / 2 );
		
		var distance = dist(center.x,center.y,this.x,this.y);
		var result = true;
		if (distance < killThreshold) //this needs to say "if it's within X of the center, EXTERMINATE!!
		{
			aArray[id] = null;
			result = false;
		}
		return result;
	}     
     
    /**
    bounce() - calculate bounces if the particle hits a screen edge
     
    */
    void bounce()
    {
         
        if ( pos.x < 0 || pos.x > width )  // check particle position - is it off the screen in x?
        {
            vel.x *= -1.0f;                // reverse x velocity
        }
         
        if ( pos.y < 0 || pos.y > height )  // check particle position - is it off the screen in x?
        {
            vel.y *= -1.0f;                  // reverse y velocity
        }
    }  // end of bounce()
     
    /**
    attractor()
    Move particles towards or away from the mouse
    by doing some basic vector math to determine the
    relationship between the particle and the mouse
    and based on that, calcuating an appropriate acceleration to
    move the particle either away from or to the mouse
    */
    void attractor()
    {
        float magnetism;          // magnetism factor - +tve values attract
         
        if ( attract == true ) // check if this particle should be attracted or repulsed
		{
            magnetism = 1.0f;      // make particles be attracted to the mouse
        } else {
            magnetism = -1.0f;    // make particles be repulsed by the mouse
        }
         
        PVector mouse = new PVector( width / 2, height / 2 ); // create mouse pos as a vector
        mouse.sub( pos );                              // subtract mouse pos from particle pos
        // mouse now contains the difference vector between this particle and the mouse
		
        float magnitude = mouse.mag();  // find out how far the particle is from the mouse
		
		if (magnitude > killThreshold) //if it's far away, animate it!
		{
			acc.set( mouse );               // store this as the acceleration vector 
			acc.mult( magnetism / (magnitude * magnitude) );  // scale the attraction/repuse effect using
                                                          // an inverse square
		} else { //if it's close, explode it! (ie: for now, just delete it)
			//aArray.splice(id, 1); //does this re-index the array? YES IT DOES! :D
			//this.destroy();
			aArray[id] = null;
		}
    }  // end of attractor()
}  // end of particle class
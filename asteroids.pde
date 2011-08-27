// @pjs preload must be used to preload the image so that it will be available when used in the sketch  
/* @pjs preload="images/cloud-city-transparent-bg.png"; */ 
/* @pjs preload="images/forcefield.png"; */ 

//import processing.video.*;

boolean debugOn = true;
boolean displayForceField = false;
Asteroid[] aArray; // declare p - p is null!
PImage logo;
PImage forcefield;
int killThreshold = 100; //how far away from center before it stops moving
int width = 500;
int height = 500;
int score;
int numAsteroids = 25; 
int backgroundColor = 0;

PFont font;
float fontX = 0;
float fontY = 0;

ArrayList psystems; // for explosions
 
void setup()
{
    size(width, height);      // set screen size
    noStroke();            // don't draw any strokes around shapes
    smooth();              // turn on anti-aliasing
	
	psystems = new ArrayList(); // for explosions
	
    aArray = new Asteroid[numAsteroids];    // set up my array of Asteroids 
    createAsteroids();
	logo = loadImage("images/cloud-city-transparent-bg.png");
	forcefield = loadImage("images/forcefield.png");
	
	font = loadFont("AmericanTypewriter-24.vlw");  
	textFont(font); 
}
 
/**
This is a processing function.  It gets called automatically 25 times a second. 
You can make it update faster by setting frameRate( n ) in setup (where n is a number
of frames per second)
*/
void draw()   
{
    background(backgroundColor); // set background to color, erase old drawing
    updateAsteroids();
	drawLogo();
	
	if (displayForceField)
	{
		image(forcefield, (width / 2) - (forcefield.width / 4), (height / 2) - (forcefield.height / 4), forcefield.width / 2, forcefield.height / 2);
		displayForceField = false;
	}
	
	//for explosions:
	for (int i = psystems.size() - 1; i >= 0; i--)
	{
		ParticleSystem psys = (ParticleSystem) psystems.get(i);
		psys.run();
		if (psys.dead())
		{
			psystems.remove(i);
		}
	}
	//end for explosions.
	
	fill(255);
	text(String(score), 15, 25); 
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

void forcefield()
{
	var scaleLogo = 4;
	var doublingFactor = scaleLogo * 2;
	var logoX = (width / 2) - (forcefield.width / doublingFactor);
	var logoY = (height / 2) - (forcefield.height / doublingFactor);
	var logoDisplayWidth = (forcefield.width / scaleLogo);
	var logoDisplayHeight = (forcefield.height / scaleLogo);
	image(forcefield, logoX, logoY, logoDisplayWidth, logoDisplayHeight);
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
	int pointValue; //value that asteroid is worth
	int colorValue; //value of asteroid's color in #FFCC00 format
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
		pointValue = randomNum(100,500);
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
			
			img.translate(img.width / 2, img.width / 2);
			img.rotate(rotation);
			img.translate((img.width / 2) * -1, (img.width / 2) * -1);
			attractor();               // change acc to make particles accelerate toward the mouse
			vel.add( acc );               // apply acceleration to velocity
			pos.add( vel );               // add velocity to positon (move particle)
			vel.mult( 0.98f );            // apply friction (otherwise particles end up moving too fast)
			bounce();                     // bounce off edges of screen
			acc.set( 0, 0, 0 );           // reset acceleration - we calculate is fresh each loopint 
			shape(img, pos.x, pos.y, size, size);
		}
	}  // end of Asteroid.update()
    
    void stillAlive(){
		//this is where i need to kill the asteroid if it's too close
		//this is where mel started fuckin' with shit
		PVector center = new PVector( width / 2, height / 2 );
		
		var distance = dist(center.x,center.y - 35,this.x,this.y);
		var result = true;
		if (distance < killThreshold) //this needs to say "if it's within X of the center, EXTERMINATE!!
		{
			//aArray[id] = null;
			//result = false;
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
    Move asteroids towards or away from the mouse
    by doing some basic vector math to determine the
    relationship between the asteroid and the mouse
    and based on that, calcuating an appropriate acceleration to
    move the asteroid either away from or to the mouse
    */
    void attractor()
    {
        float magnetism;          // magnetism factor - +tve values attract
         
        if ( attract == true ) // check if this asteroid should be attracted or repulsed
		{
            magnetism = 1.0f;      // make particles be attracted to the mouse
        } else {
            magnetism = -1.0f;    // make particles be repulsed by the mouse
        }
         
        PVector mouse = new PVector( width / 2, height / 2 ); // create mouse pos as a vector
        mouse.sub( pos );                              // subtract mouse pos from asteroid pos
        // mouse now contains the difference vector between this asteroid and the mouse
		
        float magnitude = mouse.mag();  // find out how far the asteroid is from the mouse
		
		if (magnitude > killThreshold) //if it's far away, animate it!
		{
			acc.set( mouse );               // store this as the acceleration vector 
			acc.mult( magnetism / (magnitude * magnitude) );  // scale the attraction/repuse effect using
                                                          // an inverse square
		} else { //if it's close, explode it! (ie: for now, just delete it)
			//forcefield();
			score += pointValue;
			displayForceField = true;
			explode(pos.x + (img.width / 2), pos.y + (img.height / 2));
			aArray[id] = null;
		}
    }  // end of attractor()
}  // end of asteroid class


// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.


// When the mouse is pressed, add a new particle system
void explode(xin, yin) {
  psystems.add(new ParticleSystem(int(random(5,25)),new Vector3D(xin, yin)));
}


// A subclass of Particle

// Created 2 May 2005

class CrazyParticle extends Particle {

  // Just adding one new variable to a CrazyParticle
  // It inherits all other fields from "Particle", and we don't have to retype them!
  float theta;

  // The CrazyParticle constructor can call the parent class (super class) constructor
  CrazyParticle(Vector3D l) {
    // "super" means do everything from the constructor in Particle
    super(l);
    // One more line of code to deal with the new variable, theta
    theta = 0.0;

  }

  // Notice we don't have the method run() here; it is inherited from Particle

  // This update() method overrides the parent class update() method
  void update() {
    super.update();
    // Increment rotation based on horizontal velocity
    float theta_vel = (vel.x * vel.magnitude()) / 10.0f;
    theta += theta_vel;
  }

  // Override timer
  void timer() {
    timer -= 0.5;
  }
  
  // Method to display
  void render() {
    // Render the ellipse just like in a regular particle
    super.render();

    // Then add a rotating line
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    stroke(255,timer);
    line(0,0,25,0);
    popMatrix();
  }
}


// A simple Particle class

class Particle {
  Vector3D loc;
  Vector3D vel;
  Vector3D acc;
  float r;
  float timer;

  // One constructor
  Particle(Vector3D a, Vector3D v, Vector3D l, float r_) {
    acc = a.copy();
    vel = v.copy();
    loc = l.copy();
    r = r_;
    timer = 100.0;
  }
  
  // Another constructor (the one we are using here)
  Particle(Vector3D l) {
    acc = new Vector3D(0,0.05,0);
    vel = new Vector3D(random(-1,1),random(-2,0),0);
    loc = l.copy();
    r = 3.0; //radius of particles
    timer = 100.0;
  }


  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    ellipseMode(CENTER);
    noStroke();
    fill(255,timer);
    ellipse(loc.x,loc.y,r,r);
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}


// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList particles;    // An arraylist for all the particles
  Vector3D origin;        // An origin point for where particles are birthed

  ParticleSystem(int num, Vector3D v) {
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.copy();                        // Store the origin point
    for (int i = 0; i < num; i++) {
      particles.add(new CrazyParticle(origin));    // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (Particle) particles.get(i);
      p.run();
      if (p.dead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}



// Simple Vector3D Class 

public class Vector3D {
  public float x;
  public float y;
  public float z;

  Vector3D(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }

  Vector3D(float x_, float y_) {
    x = x_; y = y_; z = 0f;
  }
  
  Vector3D() {
    x = 0f; y = 0f; z = 0f;
  }

  void setX(float x_) {
    x = x_;
  }

  void setY(float y_) {
    y = y_;
  }

  void setZ(float z_) {
    z = z_;
  }
  
  void setXY(float x_, float y_) {
    x = x_;
    y = y_;
  }
  
  void setXYZ(float x_, float y_, float z_) {
    x = x_;
    y = y_;
    z = z_;
  }

  void setXYZ(Vector3D v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }
  public float magnitude() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }

  public Vector3D copy() {
    return new Vector3D(x,y,z);
  }

  public Vector3D copy(Vector3D v) {
    return new Vector3D(v.x, v.y,v.z);
  }
  
  public void add(Vector3D v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }

  public void sub(Vector3D v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }

  public void mult(float n) {
    x *= n;
    y *= n;
    z *= n;
  }

  public void div(float n) {
    x /= n;
    y /= n;
    z /= n;
  }

  public void normalize() {
    float m = magnitude();
    if (m > 0) {
       div(m);
    }
  }

  public void limit(float max) {
    if (magnitude() > max) {
      normalize();
      mult(max);
    }
  }

  public float heading2D() {
    float angle = (float) Math.atan2(-y, x);
    return -1*angle;
  }

  public Vector3D add(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    return v;
  }

  public Vector3D sub(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
    return v;
  }

  public Vector3D div(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x/n,v1.y/n,v1.z/n);
    return v;
  }

  public Vector3D mult(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x*n,v1.y*n,v1.z*n);
    return v;
  }

  public float distance (Vector3D v1, Vector3D v2) {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }

}
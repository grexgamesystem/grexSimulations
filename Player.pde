class Player 
{
   // All the usual stuff
   PVector location;
   PVector velocity;
   PVector acceleration;
   float r;
   float boundary;
   float maxforce;    // Maximum steering force
   float maxspeed;    // Maximum speed
   color pColor;   
   int id;
   //PVector closest;
   int closestid;
   

   // Constructor initialize all values
   Player(float x, float y, int id) 
   {
      location = new PVector(x, y);
      r = 20;
      maxspeed = 3;
      maxforce = 0.2;
      boundary = 25;
      acceleration = new PVector(0, 0);
      velocity = new PVector(0, 0);
      pColor = color(0);
      this.id = id;
   }

   void applyForce(PVector force) 
   {
      // We could add mass here if we want A = F / M
      acceleration.add(force);
   }

   void applyBehaviors(ArrayList<Player> players) 
   {
      PVector boundaryForce = boundaries();
      PVector seekForce = seekTwo(players);
      boundaryForce.mult(3);
      applyForce(boundaryForce);
      applyForce(seekForce);
   }

   PVector seekTwo(ArrayList<Player> players) 
   {
      float innerDistance = r*2.0, outerDistance = r*6.0;
      PVector toAllSum = new PVector();            
      PVector fromInnerSum = new PVector();
      PVector fromMiddleSum = new PVector();      
      PVector toOther;
      PVector toClosest;      
      PVector steer;
      int innerCount=0, middleCount=0, farCount=0;

      // initialize "closest" other arbitrarily if distance is not zero (self)
      if (id != players.get(0).id) {         
         toClosest = PVector.sub(players.get(0).location, location);
         closestid =  players.get(0).id;
      } 
      else {
         toClosest = PVector.sub(players.get(1).location, location);
         closestid =  players.get(1).id;
      }      
      
      //for (Player other : players) 
      for (int i=0; i<players.size(); i++)
      {  Player other = players.get(i);       
         if (id != other.id) 
         {
            toOther = PVector.sub(other.location, location);    // from self to other
            float d = toOther.mag();
            if (d < toClosest.mag()) {
               toClosest = PVector.sub(other.location, location);
               closestid =  other.id;
            }
            // to estimate where most others are
            toAllSum.add(toOther.normalize(null));               
            // to separate from close players
            if (d < innerDistance) 
            {               
               // vector that points away from other player
               PVector diff = PVector.mult(toOther, -3.0);
               diff.normalize();
               diff.div(d);            // more weight to small distance
               fromInnerSum.add(diff);
               innerCount++;           // Keep track of how many
            } 
            else if (d < outerDistance)
            {
               // vector that points away from other player
               PVector diff = PVector.mult(toOther, -1.0);
               diff.normalize();
               diff.div(d);            // weight by distance
               fromMiddleSum.add(diff);               
               middleCount++;
            }
         }
      }

      if (innerCount > 0)              // too close, separate from inner ones
      {         
         fromInnerSum.normalize();
         fromInnerSum.mult(maxspeed);
         fromInnerSum.sub(velocity);   // steer = desired - velocity 
         fromInnerSum.limit(maxforce);
         pColor = color(255, 0, 0);    // red
         steer = fromInnerSum;
      } 
      else if (middleCount == 0)       // too far, move into flock and closest
      {
         toClosest.normalize();
         toClosest.mult(3.0);
         toAllSum.normalize();
         steer = PVector.add(toClosest, toAllSum);
         steer.normalize();
         steer.mult(maxspeed);
         steer.sub(velocity);
         steer.limit(maxforce);
         pColor = color(0, 0, 255);    // blue
      } 
      else if (middleCount == 1)       // kind of far, move into flock (could try random)
      {
         toAllSum.normalize();
         toAllSum.mult(maxspeed);
         toAllSum.sub(velocity);       // steer = desired - velocity 
         toAllSum.limit(maxforce);
         pColor = color(128, 128, 255);    // light blue
         steer = toAllSum;
      } 
      else if (middleCount == 2)       // in target, stay
      {
         pColor = color(0, 255, 0);    // green
         // force opposite to velocity to gradually stop
         steer = PVector.mult(velocity, -1.0);
         steer.limit(maxforce);
      } 
      else                             // a bit close, separate from middle ones (could try random)
      {
         fromMiddleSum.normalize();
         fromMiddleSum.mult(maxspeed);
         fromMiddleSum.sub(velocity);  // steer = desired - velocity 
         fromMiddleSum.limit(maxforce);
         pColor = color(255, 128, 128);    // light red
         steer = fromMiddleSum;
      }      
      return steer;
   }   

   PVector boundaries()
   {
      PVector desired = null;
      PVector steer =  new PVector(0, 0);
      if (location.x < boundary) {
         desired = new PVector(maxspeed, velocity.y);
      } 
      else if (location.x > width - boundary) {
         desired = new PVector(-maxspeed, velocity.y);
      }
      if (location.y < boundary) {
         desired = new PVector(velocity.x, maxspeed);
      } 
      else if (location.y > height - boundary) {
         desired = new PVector(velocity.x, -maxspeed);
      }
      if (desired != null) 
      {
         desired.normalize();
         desired.mult(maxspeed);
         steer = PVector.sub(desired, velocity);
         steer.limit(maxforce);
         //applyForce(steer);
      }
      return steer;
   }  

   // Method to update location
   void update() 
   {
      // Update velocity
      velocity.add(acceleration);
      // Limit speed
      velocity.limit(maxspeed);
      location.add(velocity);
      // Reset accelertion to 0 each cycle
      acceleration.mult(0);
   }

   void display() 
   {
      if (mousePressed) {
         PVector mouse = new PVector(mouseX, mouseY);
         if (PVector.sub(mouse, location).mag() < r) {
            println(location);
         }
      }
      fill(pColor);
      stroke(0);
      pushMatrix();
      translate(location.x, location.y);
      ellipse(0, 0, r, r);
      popMatrix();
   }
}
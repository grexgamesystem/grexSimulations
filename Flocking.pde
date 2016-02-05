int numOfPlayers = 10;

// list of players
ArrayList<Player> players;

void setup() 
{
   size(800, 600);   
   players = new ArrayList<Player>();
   for (int i = 0; i < numOfPlayers; i++) {
      players.add(new Player(random(width), random(height), i));
   }
}

void draw() 
{
   background(255);

   for (Player v : players) 
   {
      // game and boundaries
      v.applyBehaviors(players);
      // apply forces and display
      v.update();
      v.display();
   }
   
   fill(0);
   text("Drag the mouse to generate new players. Any key to reset.", 10, height-16);
}

void mouseDragged() {
   players.add(new Player(mouseX, mouseY, players.size()));
}

void keyPressed() 
{
   players = new ArrayList<Player>();
   for (int i = 0; i < numOfPlayers; i++) {
      players.add(new Player(random(width), random(height), i));
      println(players.get(i).location);
   }
}
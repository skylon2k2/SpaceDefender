
int rDown(float n) {
  return floor(random(n));
}
int rUp(float n) {
  return ceil(random(n));
}


class mover {
  float x, y, sx, sy, ax, ay;
  mover(float X, float Y) {
    this.x = X;
    this.y = Y;

    this.sx = 0;
    this.sy = 0;

    this.ax = 0;
    this.ay = 0;
  }

  void move() {

    this.sx += this.ax;
    this.sy += this.ay;

    this.x += this.sx;
    this.y += this.sy;
  }
}


class parallax extends mover {
  float d;
  parallax(int X, int Y) {
    super(X, Y);
    this.d = random(0.8);
    this.sy = 5*this.d;
  }

  void go() {
    this.move();
    stroke(255);
    strokeWeight(d);
    line(this.x, this.y, this.x-this.sx, this.y-this.sy);

    if (this.y >= height) {
      this.y -= height+this.sy;
    }
  }
}


class boomer extends mover { //Hero class
  int health;
  boomer(float X, float Y) {
    super(X, Y);
    this.health = 100;
  }

  void exist() {
    this.move();

    strokeWeight(3);
    stroke(0, 100, 255);
    fill(0, 0, 200);
    quad(this.x, this.y, this.x-30, this.y+60, this.x, this.y+50, this.x+30, this.y+60);

    strokeWeight(1);
    stroke(0);
    fill(150);

    pushMatrix();

    rectMode(CENTER);
    translate(this.x, this.y+30);
    rotate(atan2(mouseY-this.y-30, mouseX-this.x));
    rect(15, 0, 10, 10);

    popMatrix();

    ellipseMode(CENTER);
    ellipse(this.x, this.y+30, 20, 20);

    fill(0, 0, 0, 0);
    stroke(200, 200, 255);
    ellipse(this.x, this.y+30, 200, 200);
  }

  void shoot() {
    defend.add(new laser(this.x, this.y+30, mouseX, mouseY, 20));
  }
}


class zoomer extends mover { //Villains class
  ArrayList <laser> attack;
  int count, health, stronk;

  zoomer(float X, float Y) {
    super(X, Y);
    this.attack = new ArrayList<laser>();
    this.health = 1;
    this.sx = 5;

    this.count = (rUp(frameRate)+floor(frameRate))*5;
  }

  void exist() {
    this.move();

    if (this.x > width-30 || this.x < 30) {
      this.sx *= -1;
      this.y += 80;
    }

    strokeWeight(3);
    stroke(255, 100, 0);
    fill(200, 0, 0);
    quad(this.x, this.y, this.x-30, this.y-60, this.x, this.y-50, this.x+30, this.y-60);

    for (int i = 0; i < this.attack.size(); i++) {
      if (this.attack.get(i).y>height-20) {
        hero.health-=10;
      }

      if (dist(this.attack.get(i).x, this.attack.get(i).y, hero.x, hero.y+30)<100    ||    this.attack.get(i).y>height-20) { 
        this.attack.remove(i);
      }
    }
    for (int d = 0; d < defend.size(); d++) {

      if (2*(defend.get(d).x-this.x) > defend.get(d).y - this.y && -2*(defend.get(d).x-this.x) > defend.get(d).y - this.y && 0 < (defend.get(d).y + 60) - this.y) { 
        defend.remove(d);
        this.health -= 10;
      }
    }
  }
  void shoot() {
    count--;
    if (count == 0) {
      if (round<10) {
        this.attack.add(new laser(this.x, this.y, random(width), height-20, 5+round));
        this.count = (rUp(frameRate)+floor(frameRate))*5;
      }
      else {
        this.attack.add(new laser(this.x, this.y, random(width), height-20, 50));
        this.count = (rUp(frameRate)+floor(frameRate))*5;}
    }
  }
}


class laser extends mover {
  float dx, dy, fx, fy;
  //dx = deltax
  laser(float X, float Y, float FX, float FY, float speed) {
    super(X, Y);

    this.fx = FX;
    this.fy = FY;

    this.dx = this.fx - this.x;
    this.dy = this.fy - this.y;

    this.sx = speed * dx / dist(this.x, this.y, this.fx, this.fy);
    this.sy = speed * dy / dist(this.x, this.y, this.fx, this.fy);
  }


  void exist(float FX, float FY) {
    this.move();

    this.fx = FX;
    this.fy = FY;

    strokeWeight(8);
    line(this.x, this.y, this.x-this.sx, this.y-this.sy);
  }
}


/***Global Variables***/


int screen, defendCount;
float round;

parallax[] stars;
boomer hero;

ArrayList <laser> defend;

ArrayList <zoomer> villains;

//P = Pressed (aP = "a" key is pressed)
//mouseP[L/R/C] = holding the Left/Right/Center mouse button
//L = Left, R = Right, C = Center
boolean aP, dP, mouseLP, mouseRP; 

//PImage helpMe;



void setup() {
  fullScreen();
  frameRate(50);

  screen = 0;
  defendCount = 20;

  round = -1;

  aP = false;
  dP = false;

  mouseLP = false;
  mouseRP = false;

  //helpMe = loadImage("Help.jpg");

  hero = new boomer(width/2, height-200);

  stars = new parallax[1000];
  for (int s=0; s<stars.length; s++) {
    stars[s] = new parallax(rUp(width), rUp(height));
  }

  defend = new ArrayList<laser>();

  villains = new ArrayList<zoomer>();
  villains.add(new zoomer(30, 100));
}



void draw() {

  background(0, 0, 10);

  //parallax BG
  for (int s=0; s<stars.length; s++) {    
    stars[s].go();
  }
  //Home screen
  if (screen == 0) {

    hero.x = width/2;
    hero.y = height-200;
    hero.health = 100;

    round = -1;

    for (int v = 0; v<villains.size(); v++) {
      villains.remove(v);
    }

    rectMode(CENTER);

    textSize(100);
    textAlign(CENTER, CENTER);
    fill(255, 200, 0);
    text("Space Defender", width/2, (height/2)-300);

    fill(255);
    text("PLAY", width/2, (height/2)-100);
    text("HELP", width/2, (height/2)+100);
    text("EXIT", width/2, (height/2)+300);
  }

  //Game screen
  if (screen == 1) {

    //If all enemies have been defeated, this command is run
    if (villains.size() == 0) {

      if (hero.health > 100) hero.health = 100;
      round += 1;

      if (round == 10) {
        villains.add(new zoomer(30, 100));
        villains.get(0).health = 100;

        
      } else if (round > 10) screen = -5;
      else {
        for (int i = 0; i <= round; i++) {
          villains.add(new zoomer(30+(100*i), 100));
        }

        for (int v = 0; v<villains.size(); v++) {
          villains.get(v).sx += round;
          villains.get(v).health += round;
        }
      }
    }

    if (villains.size() == 1 && round == 10){
        textAlign(CORNER);
        fill(255,0,0);
        textSize(50);
        text("Boss", 100,100);
        
        rectMode(CORNER);
        strokeWeight(5);
        stroke(255);
        fill(255,0,0);
        rect(250,50,villains.get(0).health*4,50);
    }
    
    hero.exist();

    stroke(150, 150, 255);
    for (int i=0; i < defend.size(); i++) {

      defend.get(i).exist(mouseX, mouseY); //Processing all the lasers

      //Remove lasers that are out of bounds
      if (defend.get(i).x < 0 || defend.get(i).x > width || defend.get(i).y < 0 || defend.get(i).y > height) defend.remove(i);
    }

    defendCount--;
    if (defendCount < 0) { 
      defendCount = 0;
      fill(0, 255, 0);
      textAlign(CORNER);
      textSize(20);
      text("FIRE!", 10, height-310);

      if (mouseLP == true) {
        hero.shoot();
        defendCount = 20;
      }
    }

    rectMode(CORNER);
    strokeWeight(2);
    stroke(255);
    fill(50);
    rect(20, height-100, 20, -200);

    strokeWeight(0);
    fill(0, 255, 0);
    rect(22, height-100, 18, -(200-(defendCount*10)-2));

    rectMode(CORNER);
    strokeWeight(2);
    stroke(255);
    fill(50);
    rect(50, height-100, 20, -200);

    strokeWeight(0);
    fill(255, 0, 0);
    rect(52, height-100, 18, -(hero.health*2)+2);

    if (hero.x <= 30) {
      hero.x = 30;
    }
    if (hero.x >= width-30) {
      hero.x = width - 30;
    }
    if (hero.y <= 0) {
      hero.y = 0;
    }
    if (hero.y >= height-60) {
      hero.y = height - 60;
    }

    for (int v = 0; v<villains.size(); v++) {
      villains.get(v).exist();

      for (int a=0; a < villains.get(v).attack.size(); a++) { 
        villains.get(v).attack.get(a).exist(villains.get(v).x+1, villains.get(v).y+100); //Processing all the lasers

        //Remove lasers that are out of bounds
        if (villains.get(v).attack.get(a).x < 0 || villains.get(v).attack.get(a).x > width || villains.get(v).attack.get(a).y < 0) villains.get(v).attack.remove(a);
      }

      villains.get(v).shoot();
      if (villains.get(v).y >= height-300) hero.health = 0;
      if (villains.get(v).health <= 0) villains.remove(v);
    }

    noStroke();
    
    fill(0,255,0);
    rect(0,height,width,-20);
    
    fill(0,0,255);
    rect(123,height,44,-20);
    rect(567,height,88,-20);
    rect(910,height,100,-20);

    fill(255);
    rect(width-50, 0, 20, 50);
    rect(width-20, 0, 20, 50);


    if (hero.health <= 0) {
      hero.health = 100;
      screen = -6;
    }
  }


  if (screen == 2) {
    defendCount = 20;
    textSize(100);
    textAlign(CENTER, CENTER);
    text("CONTINUE", width/2, (height/2)-100);
    text("QUIT", width/2, (height/2)+100);
  }

  if (screen == 3) {
    textAlign(CENTER);
    textSize(100);
    text("win...",width/2, height/2);
    
    for (int i = 0; i < stars.length ; i++)
    stars[i].sy = 0;
  }


  if (screen == 4) {
    textSize (100);
    textAlign(CENTER);
    text("YOU WIN!", width/2, height/2);
  }

  if (screen == 5) {
    textSize (100);
    textAlign(CENTER);
    text("YOU LOSE", width/2, height/2);
  }

  if (screen == -1) screen = 0; //Home
  if (screen == -2) screen = 1; //Game
  if (screen == -3) screen = 2; //Pause
  if (screen == -4) screen = 3; //Help
  if (screen == -5) screen = 4; //Win
  if (screen == -6) screen = 5; //Lose
}







void mousePressed() {
  //Variables to tell the program when I am holding the mouse and which one
  if (mouseButton == LEFT) mouseLP = true;
  if (mouseButton == RIGHT) mouseRP = true;

  if (screen == 1) {
    if (mouseX <= width && mouseX >= width - 50 && mouseY <= 50 && mouseY >= 0 ) {
      screen = -3;
    }
  }

  if (screen == 0) {
    textSize(100);
    if (mouseX <= (width/2)+(textWidth("PLAY")/2) && mouseX >= (width/2)-(textWidth("PLAY")/2) && mouseY <= (height/2)-50 && mouseY >= (height/2)-150 ) screen = -2;
    if (mouseX <= (width/2)+(textWidth("HELP")/2) && mouseX >= (width/2)-(textWidth("HELP")/2) && mouseY <= (height/2)+150 && mouseY >= (height/2)+50 ) screen = -4;
    if (mouseX <= (width/2)+(textWidth("EXIT")/2) && mouseX >= (width/2)-(textWidth("EXIT")/2) && mouseY <= (height/2)+350 && mouseY >= (height/2)+250 ) exit();
  }

  if (screen == 2) {
    textSize(100);
    if (mouseX <= (width/2)+(textWidth("CONTINUE")/2) && mouseX >= (width/2)-(textWidth("CONTINUE")/2) && mouseY <= (height/2)-50 && mouseY >= (height/2)-150 ) screen = -2;
    if (mouseX <= (width/2)+(textWidth("QUIT")/2) && mouseX >= (width/2)-(textWidth("QUIT")/2) && mouseY <= (height/2)+150 && mouseY >= (height/2)+50 ) screen = -1;
  }

  if (screen == 3) {
    screen = -1;
  }

  if (screen == 4) {
    screen = -1;
  }

  if (screen == 5) {
    screen = -1;
  }

  //All negative screens are for transitioning, so to prevent mixup during transition
  if (screen == -1) screen = 0; //Home
  if (screen == -2) screen = 1; //Game
  if (screen == -3) screen = 2; //Pause
  if (screen == -4) screen = 3; //Help
  if (screen == -5) screen = 4; //Win
  if (screen == -6) screen = 5; //Lose
}




void mouseReleased() {
  if (mouseButton == LEFT) mouseLP = false;
  if (mouseButton == RIGHT) mouseRP = false;
}


void keyPressed() {
  if (key == 'a' || key == 'A') {
    hero.sx = -10;
    aP = true;
  }
  if (key == 'd' || key == 'D') {
    hero.sx = 10;
    dP = true;
  }
}


void keyReleased() {
  if ((key == 'a' || key == 'A') && dP == false) {
    hero.sx = 0;
    aP = false;
  } else if ((key == 'a' || key == 'A') && dP == true) {
    hero.sx = 10;
    aP = false;
  } else if ((key == 'd' || key == 'D') && aP == false) {
    hero.sx = 0;
    dP = false;
  } else if ((key == 'd' || key == 'D') && aP == true) {
    hero.sx = -10;
    dP = false;
  }
}

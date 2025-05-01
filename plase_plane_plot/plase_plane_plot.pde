/**
 * Visualize the phase plane plot for a nonlinear system.
 */


import net.objecthunter.exp4j.Expression;
import net.objecthunter.exp4j.ExpressionBuilder;
import controlP5.*;


// size of the grid
int spacing = 30; 

// coordinate translation 
float offsetX = 0;
float offsetY = 100;
float prevMouseX, prevMouseY;

// coordinate zero
float originX;
float originY;

// screen position for the red dot
float posX = 500;
float posY = 380;

// time flow for the system
float time = 0;
float prevTime = 0;

ControlP5 cp5;
Textfield exprInputX, exprInputY;

Expression exprX, exprY;
boolean succeed = true;


/**
 * Main method for the program. Called before the first frame. 
 * pre: none
 * post: setup for the first frame is finished. 
 */
void setup() {
    size(800, 800);
    background(255);
    
    // set up basic parameters
    originX = width / 2 + offsetX;
    originY = height / 2 + offsetY;
    
    // setup input fields
    cp5 = new ControlP5(this);
    inputSetup();
}


/**
 * Main method for the program. Called per timestep. 
 * pre: none
 * post: the frame for the current timestep is drawn.
 */
void draw() {
    background(255);
    
    originX = width / 2 + offsetX;
    originY = height / 2 + offsetY;
    
    drawGrid();
    drawPhasePlane();
    drawPoint();
    
    statusText();
}


/**
 * Set up text input fields.
 * pre: none.
 * post: text input fields are set up.
 */
void inputSetup() {
    String expressionX = "-(x-y)*(1-x-y)";
    String expressionY = "x*(2+y)";

    // text input field
    exprInputX = cp5.addTextfield("dx = ")
        .setPosition(70, 50)
        .setSize(300, 40)
        .setAutoClear(false)
        .setFocus(false)
        .setFont(createFont("Arial", 20))
        .setText(expressionX);
        
    exprInputY = cp5.addTextfield("dy = ")
        .setPosition(70, 100)
        .setSize(300, 40)
        .setAutoClear(false)
        .setFocus(false)
        .setFont(createFont("Arial", 20))
        .setText(expressionY);
        
        
    // input field label
    exprInputX.getCaptionLabel()
        .setVisible(true)
        .toUpperCase(false)
        .setColor(color(0))
        .align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER)
        .setPaddingX(10)
        .setPaddingY(10);
    
    exprInputY.getCaptionLabel()
        .setVisible(true)
        .toUpperCase(false)
        .setColor(color(0))
        .align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER)
        .setPaddingX(10)
        .setPaddingY(10);
        
    
    // setup defualt expressions
    exprX = new ExpressionBuilder(expressionX)
        .variable("x")
        .variable("y")
        .build();
    exprY = new ExpressionBuilder(expressionY)
        .variable("x")
        .variable("y")
        .build();
}


/**
 * Detect input change. 
 * pre: none.
 * post: input changes are detected and updated if valid.
 */
void keyPressed() {
    if (key == ENTER || key == RETURN) {
        String inputX = exprInputX.getText();
        String inputY = exprInputY.getText();

        // setup new expressions
        Expression newExprX = new ExpressionBuilder(inputX)
            .variable("x")
            .variable("y")
            .build();
        Expression newExprY = new ExpressionBuilder(inputY)
            .variable("x")
            .variable("y")
            .build();
    
        try {
            // plug in values for the variables
            newExprX.setVariable("x", 0);
            newExprX.setVariable("y", 0);
            newExprY.setVariable("x", 0);
            newExprY.setVariable("y", 0);
            
            // calculate the value for the expressions
            double xx = newExprX.evaluate();
            double yy = newExprY.evaluate();

            succeed = true;
            
        } catch (Exception ex) {
            
            succeed = false;
        }
        
        // replace old expressions with new expressions
        if (succeed) {
            exprX = newExprX;
            exprY = newExprY;
        }
    }
}


/**
 * Display status of current inputs.
 * pre: none.
 * post: good if inputs are valid, warning if not
 */
void statusText() {
    textSize(20);
    textAlign(LEFT, CENTER);
    
    if (succeed) {
        fill(0);
        text("Looks Good!", 70, 170);
    } else {
        fill(200, 0, 0);
        text("Invalid expression", 70, 170);
    }
}


/**
 * The function that defines the system. 
 * pre: none.
 * post: return the vector at a given position in the system. 
 * @param posX position in x-axis, 
 *        posY position in y-axis.
 * @return dir the vector at a given position.
 */
PVector F(float posX, float posY) {
    //translate the screen position to the coordinate position
    float x = (originX - posX) / (100);
    float y = (originY - posY) / (100);
    
    // plug in values for the variables
    exprX.setVariable("x", x);
    exprX.setVariable("y", y);
    exprY.setVariable("x", x);
    exprY.setVariable("y", y);
    
    // calculate the value and creates a vector
    double dx = exprX.evaluate();
    double dy = exprY.evaluate();
    PVector dir = new PVector((float) dx, (float) dy);
    
    // rescale the vector to fit on the screen
    dir.setMag(log(dir.mag() + 1) * 7);
    
    return dir;
}


/**
 * Draw the coordinate grid. 
 * pre: none.
 * post: the coordinate grid is drawn.
 */
void drawGrid() {
    stroke(220);
    fill(0);
    strokeWeight(1);
    
    textAlign(CENTER, CENTER);
    textSize(12);
        
    // Vertical lines and X-axis labels
    for (float x = originX % spacing; x < width; x += spacing) {
        line(x, 0, x, height);
        int coordX = round((x - originX) / spacing);
        if (abs(coordX) < 1000) { // prevent overflow labels
            text(coordX, x, originY + 12);
        }
    }
  
    // Horizontal lines and Y-axis labels
    for (float y = originY % spacing; y < height; y += spacing) {
        line(0, y, width, y);
        int coordY = -round((y - originY) / spacing); // y is inverted
        if (abs(coordY) < 1000) {
            text(coordY, originX + 18, y);
        }
    }
  
    // Axis lines (bold center lines)
    stroke(0);
    line(originX, 0, originX, height);   // Y-axis
    line(0, originY, width, originY);   // X-axis
    
    // Origin
    stroke(0); 
    strokeWeight(10); 
    point(originX, originY);
}


/**
 * Draw the entire phase plane for the system. 
 * pre: none.
 * post: the arrows of the system are drawn.
 */
void drawPhasePlane() {
    for (float x = originX % spacing; x < width; x += spacing) {    
        for (float y = originY % spacing; y < height; y += spacing) {
            drawArrow(x, y);
        }
    }
}


/**
 * Draw an arrow in the system at a given position.
 * pre: none.
 * post: the arrow is drawn.
 * @param baseX position in x-axis, 
 *        baseY position in y-axis.
 */
void drawArrow(float baseX, float baseY) {
    stroke(50);
    fill(150);
    strokeWeight(2);
    
    // calculate the slope
    PVector dir = F(baseX, baseY);
    PVector tip = new PVector(
        baseX + dir.x, 
        baseY + dir.y
    );
    
    // line
    line(baseX, baseY, tip.x, tip.y);
    
    // parameters for triangle
    float angle = atan2(dir.y, dir.x);
    float angleSize = log(dir.mag() + 1) * 3;
    
    float x1 = tip.x - angleSize * cos(angle - PI/10);
    float y1 = tip.y - angleSize * sin(angle - PI/10);
    float x2 = tip.x - angleSize * cos(angle + PI/10);
    float y2 = tip.y - angleSize * sin(angle + PI/10);
    
    // triangle
    strokeWeight(1);
    triangle(tip.x, tip.y, x1, y1, x2, y2);
}


/**
 * Draw the red dot on the screen, flowing in the system.
 * pre: none.
 * post: the red dot is drawn and its position at the next timestep
 * is calculated.
 */
void drawPoint() {
    strokeWeight(10);
    stroke(150, 20, 40);
    
    point(posX, posY);
    
    // calculate the red dot's next position if the time of the
    // system is changed
    if (prevTime != time) {
        float h = time - prevTime;
        PVector dir = RK4(h, posX, posY);
        posX += dir.x;
        posY += dir.y;
        if (h > 0) {
            prevTime = min(time, prevTime + 0.1);
        } else if (h < 0) {
            prevTime = max(time, prevTime - 0.1);
        }
    }
}


/**
 * Runge-Kutta 4 method for approximating solutions.
 * pre: none.
 * post: the position at the next timestep is calculated. 
 * @param h the time step, 
 *        x position in x-axis, 
 *        y position in y-axis.
 * @return dir the position at the next timestep.
 */
PVector RK4(float h, float x, float y) {
    PVector k1 = F(x, y);
    PVector k2 = F(
        x + h/2 * k1.x, 
        y + h/2 * k1.y
        );
    PVector k3 = F(
        x + h/2 * k2.x, 
        y + h/2 * k2.y
        );
    PVector k4 = F(
        x + h * k3.x, 
        y + h * k3.y
        );
    PVector dir = new PVector(
        (h / 6) * (k1.x + 2*k2.x + 2*k3.x + k4.x), 
        (h / 6) * (k1.y + 2*k2.y + 2*k3.y + k4.y)
        );
    return dir;
}


/**
 * Detects mouse clicking movement.
 * pre: none.
 * post: movement is detected. 
 */
void mousePressed() {
    if (mouseButton == LEFT) {
        prevMouseX = mouseX;
        prevMouseY = mouseY;
    } else if (mouseButton == RIGHT) {
        posX = mouseX;
        posY = mouseY;
    }
}


/**
 * Detects mouse dragging movement.
 * pre: none.
 * post: movement is detected.  
 */
void mouseDragged() {
    if (mouseButton == LEFT) {
        float dx = mouseX - prevMouseX;
        float dy = mouseY - prevMouseY;
        
        // update coordinate offset
        offsetX += dx;
        offsetY += dy;
        prevMouseX = mouseX;
        prevMouseY = mouseY;
        
        // update red dot offset
        posX += dx;
        posY += dy;
    }
}


/**
 * Detects mouse wheel movement.
 * pre: none.
 * post: movement is detected. 
 * @param event records the events created by the mouse.
 */
void mouseWheel(MouseEvent event) {
    float d = event.getCount();
    prevTime = time;
    time -= d * 0.7;
}

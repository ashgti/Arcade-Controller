int joy_up    = 4;
int joy_down  = 5;
int joy_left  = 6; 
int joy_right = 7;
int button_b  = 8;
int button_a  = 9;

const uint8_t HID_KEYBOARD_MODIFER_LEFTCTRL = (1 << 0);
const uint8_t HID_KEYBOARD_MODIFER_LEFTALT  = (1 << 2);
const uint8_t HID_KEYBOARD_SC_RIGHT_ARROW   = 0x4F;
const uint8_t HID_KEYBOARD_SC_LEFT_ARROW    = 0x50;
const uint8_t HID_KEYBOARD_SC_DOWN_ARROW    = 0x51;
const uint8_t HID_KEYBOARD_SC_UP_ARROW      = 0x52;

void setup() {
  Serial.begin(9600);
  pinMode(joy_up, INPUT);
  pinMode(joy_down, INPUT);
  pinMode(joy_left, INPUT);
  pinMode(joy_right, INPUT);
  pinMode(button_a, INPUT);
  pinMode(button_b, INPUT);
  
  /* Enable the Pull Up Resistors */
  digitalWrite(joy_up, HIGH);
  digitalWrite(joy_down, HIGH);
  digitalWrite(joy_left, HIGH);
  digitalWrite(joy_right, HIGH);
  digitalWrite(button_a, LOW);
  digitalWrite(button_b, LOW);
}

long cc = 0;
char last_ready = 0;
unsigned long next_repeat = 0;
unsigned long debounce[6] = { 0, 0, 0, 0, 0, 0 };

int last_values[6] = { 0, 0, 0, 0, 0, 0 }; 

const int debounce_delay = 10;
const int delay_repeat = 25;

void loop() {
  unsigned long c_time = millis();
  int a = 0, b = 0, up = HIGH, down = HIGH, left = HIGH, right = HIGH, tmp = 0;
  char ready = 0;

  tmp = digitalRead(button_a);
  if (last_values[0] != tmp) {
    /* it switched */
    debounce[0] = c_time;
  }
  
  if ((c_time - debounce[0]) > debounce_delay) {
    a = tmp;
    if (a == HIGH) {
       ready |= (1 << 0);
    }
  }
  last_values[0] = tmp;

  tmp = digitalRead(button_b);
  if (last_values[1] != tmp) {
    /* it switched */
    debounce[1] = c_time;
  }
  
  if ((c_time - debounce[1]) > debounce_delay) {
    b = tmp;
    if (b == HIGH) {
       ready |= (1 << 1);
    }
  }
  last_values[1] = tmp;
  
  tmp = digitalRead(joy_up);
  if (last_values[2] != tmp) {
    /* it switched */
    debounce[2] = c_time;
  }
  
  if ((c_time - debounce[2]) > debounce_delay) {
    up = tmp;
    if (up == LOW) {
       ready |= (1 << 2);
    }
  }
  last_values[2] = tmp;

  tmp = digitalRead(joy_down);
  if (last_values[3] != tmp) {
    /* it switched */
    debounce[3] = c_time;
  }
  
  if ((c_time - debounce[3]) > debounce_delay) {
    down = tmp;
    if (down == LOW) {
       ready |= (1 << 3);
    }
  }
  last_values[3] = tmp;
  
  tmp = digitalRead(joy_left);
  if (last_values[4] != tmp) {
    /* it switched */
    debounce[4] = c_time;
  }
  
  if ((c_time - debounce[4]) > debounce_delay) {
    left = tmp;
    if (left == LOW) {
       ready |= (1 << 4);
    }
  }
  last_values[4] = tmp;
  
  tmp = digitalRead(joy_right);
  if (last_values[5] != tmp) {
    /* it switched */
    debounce[5] = c_time;
  }
  
  if ((c_time - debounce[5]) > debounce_delay) {
    right = tmp;
    if (right == LOW) {
       ready |= (1 << 5);
    }
  }
  last_values[5] = tmp;
  
  if (ready > 0) {
    /** Debounced signal **/
    uint8_t mod = 0;
    if (a == HIGH)
      mod |= HID_KEYBOARD_MODIFER_LEFTCTRL;
    if (b == HIGH)
      mod |= HID_KEYBOARD_MODIFER_LEFTALT;
  
    Serial.write(mod);
    Serial.write((uint8_t)0);
  
    int sent_count = 0;

    if (right == LOW) {
      Serial.write(HID_KEYBOARD_SC_RIGHT_ARROW);
      sent_count++;
    }
    else if (left == LOW) {
      Serial.write(HID_KEYBOARD_SC_LEFT_ARROW);
      sent_count++;
    }
  
    if (down == LOW) {
      Serial.write(HID_KEYBOARD_SC_DOWN_ARROW);
      sent_count++;
    }
    else if (up == LOW) {
      Serial.write(HID_KEYBOARD_SC_UP_ARROW);
      sent_count++;
    }
    
    while (sent_count < 6) {
      Serial.write((uint8_t)0);
      sent_count++;
    }

    delay(delay_repeat);
    // last_ready = ready;
  }
}
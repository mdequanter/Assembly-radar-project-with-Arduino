//----------------------------------------
// Assembly via Arduino: Servo Motor SG90
//----------------------------------------
extern "C"
{
  void init_serial();
  void servo_motor();
  void HC_SR04_sensor();
  void print_msg();
}
//----------------------------------------
void setup()
{
  init_serial();
  servo_motor();
  
}
//----------------------------------------
void loop() {}

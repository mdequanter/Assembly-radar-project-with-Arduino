//---------------------------------------
// Assembly via Arduino - HC-SR04 Sensor
//---------------------------------------
extern "C"
{
  void init_serial();
  void HC_SR04_sensor();
  void print_msg();
}
//---------------------------------------
void setup()
{
  init_serial();
  HC_SR04_sensor();
}
//---------------------------------------
void loop(){
  print_msg();
}

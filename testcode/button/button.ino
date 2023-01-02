//-----------------------------------
// C Code: RGB LED ON/OFF via Buttons
//-----------------------------------
extern "C"
{
  void start();
  void btnLED();
}
//-----------------------
void setup()
{
  start();
}
//-----------------------
void loop()
{
  btnLED();
}

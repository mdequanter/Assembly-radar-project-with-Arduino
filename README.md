# assembly based on ATMEGA328P

I wrote in assembly on Arduino, with an ATMEGA328P because it is a great platform for embedded programming. It is low cost and easy to use, making it ideal for prototyping and experimentation. Additionally, assembly language provides direct access to hardware, allowing for ultimate control over how the microcontroller interacts with its environment. This is particularly useful when dealing with time-critical tasks, where extremely precise timing is required. Moreover, writing in assembly language makes it easier to make code more efficient and conserve memory, an important consideration when dealing with microcontrollers. For these reasons, using assembly language on the Arduino is an excellent choice for a variety of projects.

# Demo of an arduino with HCSR04 sensor

This program shows a demonstration of a radar using an ultrasonic sensor HC-SR04  . The ultrasonic sensor will send out a signal and listen for its echo, which is used to measure the distance from the sensor to any nearby objects. If an object is detected, the radar will indicate this by lighting up a circle on the screen that corresponds to the object’s location. 

Because it needed to be fast and very stable. The program was written in assembly.  Another great advantage is that it is working super fast, because the number of instructions are much less than writing the same code in C. The entire program only uses 850 bytes.  While the same program in C takes

Programmed in C :

![image](https://user-images.githubusercontent.com/74420584/209464494-0db1326b-2fc7-455a-acb5-d4de5fab5080.png)


This can help users detect obstacles that may be in their path or potential dangers like an approaching vehicle. 

![image](https://user-images.githubusercontent.com/74420584/209464272-2f67d1f1-7664-4409-9fca-2e80b27d89bf.png)



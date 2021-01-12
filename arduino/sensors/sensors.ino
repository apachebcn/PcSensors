#include <LiquidCrystal_I2C.h>
#include "pantalla.h"

#include <OneWire.h>

#define BEEPER_PIN A3
#define PANTALLA_TIMER_TO_OFF 10000;

#define TCMAX 80  // CPU
#define TGMAX 80  // GPU
#define TPMAX 60  // PLACA BASE

int i;
unsigned long pantalla_timer = 0;
int temp;
bool Alarma;
String data;
String item;
String label;
String value;
String TC;
int TC_before;
String TG;
int TG_before;
String TP;
int TP_before;
String FC;
int FC_before;
String FG;
int FG_before;
String FP;
int FP_before;
String TEMP_IN;
int TEMP_IN_before;
String TEMP_OUT1;
int TEMP_OUT1_before;
String TEMP_OUT2;
int TEMP_OUT2_before;

String Line0;
String Line1;
String Line2;
String Line3;

void setup()
{
    pinMode(BEEPER_PIN, OUTPUT);
    byte address = Pantalla::iniciar();
    Pantalla::presentacion();
    dallas(2, 1);
    dallas(3, 1);
    dallas(4, 1);
    Serial.begin(115200);
}

int16_t dallas(int x, byte start)
{
    OneWire ds(x);
    byte i;
    byte data[2];
    int16_t result;
    do
    {
        ds.reset();
        ds.write(0xCC);
        ds.write(0xBE);
        for (i=0; i<2; i++) data[i] = ds.read();
        result=(data[1]<<8) | data[0];
        result>>=4; if (data[1]&128) result |= 61440;
        if (data[0]&8) ++result;
        ds.reset();
        ds.write(0xCC);
        ds.write(0x44,1);
        if (start) delay(1000);
    } while (start--);
    int int_result = (int)result;
    if (int_result < 0) int_result = 0;
    return int_result;
}

String compare_and_mem(String value, int value_before)
{
    int value_num = value.toInt();
    if (!value_before) return "!";
    if (value_num == value_before) return "=";
    if (value_num > value_before) return ">";
    if (value_num < value_before) return "<";
    return "?";
}

void loop()
{
    if (!pantalla_timer)
    {
        pantalla_timer = millis() + PANTALLA_TIMER_TO_OFF;
        if (pantalla_timer < millis()) pantalla_timer = millis() + PANTALLA_TIMER_TO_OFF;
    }
    if (millis() > pantalla_timer)
    {
        lcd.noBacklight();
    }
    if (Serial.available() > 0)
    {
        lcd.backlight();
        pantalla_timer = 0;
        TC = TG = TP = "0";
        FC = FG = FP = "0";
        TEMP_IN = TEMP_OUT1 = TEMP_OUT2 = "0";
        lcd.setCursor(19,3);
        lcd.print("*");

        data = Serial.readString();

        int strIndex[] = {0, -1};
        int maxIndex = data.length()-1;
        for(i=0; i<=maxIndex; i++)
        {
            if(data.charAt(i)=='|' || i==maxIndex)
            {
                strIndex[0] = strIndex[1]+1;
                strIndex[1] = (i == maxIndex) ? i+1 : i;

                item = data.substring(strIndex[0], strIndex[1]);
                if (item.length())
                {
                    label = item.substring(0, 2);
                    if (label == "TC") TC = item.substring(2, item.length());
                    if (label == "TG") TG = item.substring(2, item.length());
                    if (label == "TP") TP = item.substring(2, item.length());
                    if (label == "FC") FC = item.substring(2, item.length());
                    if (label == "FG") FG = item.substring(2, item.length());
                    if (label == "FP") FP = item.substring(2, item.length());
                }
            }
        }

        Alarma = 0;
        if (TC.toInt() > TCMAX) Alarma = 1;
        if (TG.toInt() > TGMAX) Alarma = 1;
        if (TP.toInt() > TPMAX) Alarma = 1;
        if (Alarma)
        {
            digitalWrite(BEEPER_PIN, HIGH);
            delay(100);
        }
        digitalWrite(BEEPER_PIN, LOW);

        Line0 = "Pba ";
        Line0 += TP;
        Line0 += char(223);
        Line0 += compare_and_mem(TP, TP_before); TP_before = TP.toInt();
        for(i = Line0.length(); i < 10; i++)
        {
            Line0 += " ";
        }
        Line0 += FP; 
        Line0 += "Rpm";
        Line0 += compare_and_mem(FP, FP_before); FP_before = FP.toInt();
        for(i = Line0.length(); i < 20; i++)
        {
            Line0 += " ";
        }
        lcd.setCursor(0,0); lcd.print(Line0);

        Line1 = "Cpu ";
        Line1 += TC; 
        Line1 += char(223);
        Line1+= compare_and_mem(TC, TC_before); TC_before = TC.toInt();
        for(i = Line1.length(); i < 10; i++)
        {
            Line1 += " ";
        }
        Line1 += FC; 
        Line1 += "Rpm";
        Line1 += compare_and_mem(FC, FC_before); FC_before = FC.toInt();
        for(i = Line1.length(); i < 20; i++)
        {
            Line1 += " ";
        }
        lcd.setCursor(0,1); lcd.print(Line1);


        Line2 = "Gpu ";
        Line2 += TG; 
        Line2 += char(223);
        Line2 += compare_and_mem(TG, TG_before); TG_before = TG.toInt();
        for(i = Line2.length(); i < 10; i++)
        {
            Line2 += " ";
        }
        Line2 += FG; 
        Line2 += "Rpm";
        Line2 += compare_and_mem(FG, FG_before); FG_before = FG.toInt();
        for(i = Line2.length(); i < 20; i++)
        {
            Line2 += " ";
        }
        lcd.setCursor(0,2); lcd.print(Line2);

        temp = dallas(2, 0);
        TEMP_IN = String(temp); 

        temp = dallas(3, 0);
        TEMP_OUT1 = String(temp); 

        temp = dallas(4, 0);
        TEMP_OUT2 = String(temp);

        Line3 = "A:";
        Line3 += TEMP_IN; 
        Line3 += char(223);
        Line3 += compare_and_mem(TEMP_IN, TEMP_IN_before); TEMP_IN_before = TEMP_IN.toInt();
        for(i = Line3.length(); i < 7; i++)
        {
            Line3 += " ";
        }
        Line3 += "B:";
        Line3 += TEMP_OUT1; 
        Line3 += char(223);
        Line3 += compare_and_mem(TEMP_OUT1, TEMP_OUT1_before); TEMP_OUT1_before = TEMP_OUT1.toInt();
        for(i = Line3.length(); i < 14; i++)
        {
            Line3 += " ";
        }
        Line3 += "C:";
        Line3 += TEMP_OUT2; 
        Line3 += char(223);
        Line3 += compare_and_mem(TEMP_OUT2, TEMP_OUT2_before); TEMP_OUT2_before = TEMP_OUT2.toInt();
        for(i = Line3.length(); i < 20; i++)
        {
            Line3 += " ";
        }
        lcd.setCursor(0,3); lcd.print(Line3);
    }
}

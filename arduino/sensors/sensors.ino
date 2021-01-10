#include <LiquidCrystal_I2C.h>
#include "pantalla.h"

#include <OneWire.h>

#define BEEPER_PIN 5
#define LED_PIN 9

#define TCMAX 70
#define TGMAX 80
#define TPMAX 50

int i;
int temp;
bool Alarma;
String data;
String item;
String label;
String value;
String TC;
String TG;
String TP;
String FC;
String FG;
String FP;
String TEMP_IN;
String TEMP_OUT1;
String TEMP_OUT2;

String Line0;
String Line1;
String Line2;
String Line3;

void setup()
{
    pinMode(BEEPER_PIN, OUTPUT);
    pinMode(LED_PIN, OUTPUT);
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

void loop()
{
    digitalWrite(BEEPER_PIN, 0);
    if (Serial.available() > 0)
    {
        digitalWrite(LED_PIN, 1); delay(25); digitalWrite(LED_PIN, 0);
        TC = TG = TP = "0";
        FC = FG = FP = "0";
        TEMP_IN = TEMP_OUT1 = TEMP_OUT2 = "0";

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
            digitalWrite(BEEPER_PIN, 1);
            delay(50);
            digitalWrite(BEEPER_PIN, 0);
        }

        Line0 = "Pba ";
        Line0 += TP; 
        Line0 += char(223);
        for(i = Line0.length(); i < 10; i++)
        {
            Line0 += " ";
        }
        Line0 += FP; 
        Line0 += "Rpm";
        for(i = Line0.length(); i < 20; i++)
        {
            Line0 += " ";
        }
        lcd.setCursor(0,0); lcd.print(Line0);

        Line1 = "Cpu ";
        Line1 += TC; 
        Line1 += char(223);
        for(i = Line1.length(); i < 10; i++)
        {
            Line1 += " ";
        }
        Line1 += FC; 
        Line1 += "Rpm";
        for(i = Line1.length(); i < 20; i++)
        {
            Line1 += " ";
        }
        lcd.setCursor(0,1); lcd.print(Line1);


        Line2 = "Gpu ";
        Line2 += TG; 
        Line2 += char(223);
        for(i = Line2.length(); i < 10; i++)
        {
            Line2 += " ";
        }
        Line2 += FG; 
        Line2 += "Rpm";
        for(i = Line2.length(); i < 20; i++)
        {
            Line2 += " ";
        }
        lcd.setCursor(0,2); lcd.print(Line2);

        // sensor1.requestTemperatures();
        temp = dallas(2, 0);
        TEMP_IN = String(temp); 

        // sensor2.requestTemperatures();
        temp = dallas(3, 0);
        TEMP_OUT1 = String(temp); 

        // sensor3.requestTemperatures();
        temp = dallas(4, 0);
        TEMP_OUT2 = String(temp);

        Line3 = "IN=";
        Line3 += TEMP_IN; 
        Line3 += char(223);
        for(i = Line3.length(); i < 7; i++)
        {
            Line3 += " ";
        }
        Line3 += "O1=";
        Line3 += TEMP_OUT1; 
        Line3 += char(223);
        for(i = Line3.length(); i < 14; i++)
        {
            Line3 += " ";
        }
        Line3 += "O2=";
        Line3 += TEMP_OUT2; 
        Line3 += char(223);
        for(i = Line3.length(); i < 20; i++)
        {
            Line3 += " ";
        }
        lcd.setCursor(0,3); lcd.print(Line3);

        digitalWrite(BEEPER_PIN, 1);
    }

}

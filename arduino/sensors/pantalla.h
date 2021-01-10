#define PANTALLA_ANCHO_PX	20
#define PANTALLA_ALTO_PX	4

#ifndef Pantalla_h
#define Pantalla_h
#endif

//Definining Termometer Icon
byte tempchar1[8]={B00000, B00001, B00010, B00100, B00100, B00100, B00100, B00111,};//Row 0, Col 2
byte tempchar2[8]={B00111, B00111, B00111, B01111, B11111, B11111, B01111, B00011,};//Row 1, Col 2
byte tempchar3[8]={B00000, B10000, B01011, B00100, B00111, B00100, B00111, B11100,};//ROW 0, Col 3
byte tempchar4[8]={B11111, B11100, B11100, B11110, B11111, B11111, B11110, B11000,};//Row 1, Col 3



LiquidCrystal_I2C lcd(0x27, PANTALLA_ANCHO_PX, PANTALLA_ALTO_PX);

char Pantalla_buffer_segmento[(PANTALLA_ANCHO_PX/2)+1];

class Pantalla
{
    public:

        static void presentacion();
        static byte iniciar();
        static void apagar();
        static void encender();
        static void print_centrado(const __FlashStringHelper*, byte);
        // static void visor_sondas();

};

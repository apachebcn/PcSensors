#define PANTALLA_ANCHO_PX	20
#define PANTALLA_ALTO_PX	4

#ifndef Pantalla_h
#define Pantalla_h
#endif

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

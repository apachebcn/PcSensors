byte Pantalla::iniciar()
{
    byte error, address;

    Wire.begin();

    for(address = 1; address < 127; address++ ) 
    {
        // The i2c_scanner uses the return valor of
        // the Write.endTransmisstion to see if
        // a device did acknowledge to the address.
        Wire.beginTransmission(address);
        error = Wire.endTransmission();
        if (error == 0)
        {
            lcd._Addr = address;
            lcd.begin(PANTALLA_ANCHO_PX, PANTALLA_ALTO_PX);
            Pantalla::encender();
            return address;
        }
    }
    return 0;
}

void Pantalla::encender()
{
    lcd.backlight();
}

void Pantalla::apagar()
{
    lcd.noBacklight();
}

void Pantalla::presentacion()
{
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("PEDRO REINA ROJAS");
    lcd.setCursor(0, 1);
    lcd.print("-Sensores de mi PC-");
    lcd.setCursor(0, 3);
    lcd.print("Hola :-D");
}

with HAL; use HAL;
with MicroBit.Display;
with MicroBit.Time;
with MicroBit.Buttons; use MicroBit.Buttons;

procedure Main is
   -- Time from button press to when flashing starts
   TOTAL_TIME_MS : constant MicroBit.Time.Time_Ms := 21600000; -- 6 hours

   -- Number of pips on the display
   MAX_PIPS : constant Integer := 16;

   -- Frequency to flash at after time elapses
   FLASH_RATE_MS : constant MicroBit.Time.Time_Ms := 1000;

   -- Speed of button pressed animation
   ANIMATION_SPEED : constant MicroBit.Time.Time_Ms := 300;

   LastPress : MicroBit.Time.Time_Ms;

   subtype PipIndex is Integer range 1 .. MAX_PIPS;

   type Coordinate is record
      Row : MicroBit.Display.Coord;
      Col : MicroBit.Display.Coord;
   end record;

   -- Convert from pip index to location on the 5x5 microbit display:
   --
   -- 15 16  1  2  3
   -- 14  -  -  -  4
   -- 13  -  -  -  5
   -- 12  -  -  -  6
   -- 11 10  9  8  7
   function GetPipCoordinate(Pip : PipIndex) return Coordinate is
   begin
      if Pip <= 3 then
         return (Row => 0, Col => Pip + 1);
      elsif Pip <= 7 then
         return (Row => 0 + Pip - 3, Col => 4);
      elsif Pip <= 11 then
         return (Row => 4, Col => 4 - (Pip - 7));
      elsif Pip <= 15 then
         return (Row => 4 - (Pip - 11), Col => 0);
      else
         return (Row => 0, Col => 1);
      end if;
   end GetPipCoordinate;

begin
   LastPress := MicroBit.Time.Clock;

   loop

      if State(Button_A) = Pressed or State(Button_B) = Pressed then
         LastPress := MicroBit.Time.Clock;
      end if;

      declare
         TimeSinceMeal : constant MicroBit.Time.Time_Ms
           := (MicroBit.Time.Clock - LastPress);
         PipsOn : constant Integer
           := Integer(TimeSinceMeal) / (Integer(TOTAL_TIME_MS) / MAX_PIPS);
      begin

         MicroBit.Display.Clear;

         if TimeSinceMeal < ANIMATION_SPEED then
            -- Animation state 1 - middle dot
            MicroBit.Display.Set(2, 2);

         elsif TimeSinceMeal < ANIMATION_SPEED * 2 then
            -- Animation state 2 - middle ring
            MicroBit.Display.Set(1, 1);
            MicroBit.Display.Set(1, 2);
            MicroBit.Display.Set(1, 3);
            MicroBit.Display.Set(2, 1);
            MicroBit.Display.Set(2, 3);
            MicroBit.Display.Set(3, 1);
            MicroBit.Display.Set(3, 2);
            MicroBit.Display.Set(3, 3);

         elsif TimeSinceMeal < ANIMATION_SPEED * 3 then
            -- Animation state 3 - outer ring
            for Pip in 1 .. MAX_PIPS loop
               declare
                  PipCoordinates : constant Coordinate := GetPipCoordinate(Pip);
               begin
                  MicroBit.Display.Set(PipCoordinates.Col, PipCoordinates.Row);
               end;
            end loop;

         elsif PipsOn < MAX_PIPS or (TimeSinceMeal / FLASH_RATE_MS) mod 2 = 0 then
            -- Typical state, showing dots or flashed on
            for Pip in 1 .. Integer'Min(PipsOn, MAX_PIPS) loop
               declare
                  PipCoordinates : constant Coordinate := GetPipCoordinate(Pip);
               begin
                  MicroBit.Display.Set(PipCoordinates.Col, PipCoordinates.Row);
               end;
            end loop;

         end if;

         MicroBit.Time.Delay_Ms(100);

      end;
   end loop;

end Main;

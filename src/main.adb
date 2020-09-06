------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2018, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

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

         if PipsOn < MAX_PIPS or (TimeSinceMeal / FLASH_RATE_MS) mod 2 = 0 then
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

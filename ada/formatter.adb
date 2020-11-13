-- Screen Formatter in Ada
-- Nolan Donley
-- Input: any text file
-- Output: text file formatter to maximum 60 chars per Line
--      and also the line with most and least words
--
-- To compile:
-- gnatmake formatter.adb
--
-- To run:
-- formatter {absolute filepath}


with Text_IO, Ada.Command_line, Ada.Containers.Indefinite_Vectors, Ada.Strings.Fixed, Ada.Strings.Maps, Ada.Strings.Unbounded;
use Text_IO, Ada.Command_line, Ada.Containers, Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Maps, Ada.Strings.Unbounded;

procedure formatter is
  filename : String := Argument(1); -- filename
  file : File_Type; -- file object
  Numchars : Natural := 0; -- number of chars per line
  tmpLine : Unbounded_String; -- temp line to determine max and min
  longLine : Unbounded_String; -- stores longest line
  shortLine : Unbounded_String; -- stores shortest line
  numLines : Natural := 1; -- stores number of lines
  longLineNum : Natural := 0; -- longest line's line number
  shortLineNum : Natural := 0; -- shortest line's line number
  numWords : Natural := 0; -- num of words in tmp
  longLineNumWords : Natural := 0; -- longest lines number of words
  shortLineNumWords : Natural := 0; -- shortest lines number of words


  -- procedure to update the longest and shortest lines along with their line numbers
  procedure UpdateMinMax(sentence : Unbounded_String; num : Natural; wordCount : Natural) is
  begin
    if wordCount <= shortLineNumWords then
      shortLine := sentence;
      shortLineNum := num;
      shortLineNumWords := wordCount;
    end if;
    if wordCount >= longLineNumWords then
       longLine := sentence;
       longLineNum := num;
       longLineNumWords := wordCount;
    end if;
    if numLines = 1 then
      shortLine := sentence;
      shortLineNum := num;
      shortLineNumWords := wordCount;
    end if;
  end UpdateMinMax;

  -- procedure that takes a line of input and splits the words
  -- then outputs the words one at a time
  procedure Tokenize (input : String) is
     package String_Vectors is new Indefinite_Vectors (Positive, String);
     use String_Vectors;
     Start  : Positive := input'First;
     Finish : Natural  := 0;
     Output : Vector   := Empty_Vector;
     Word : Unbounded_String;

     -- function to strip a string of any characters in "The_Characters" String
     function Strip(The_String: String; The_Characters: String)
                  return String is
      Keep:   array (Character) of Boolean := (others => True);
      Result: String(The_String'Range);
      Last:   Natural := Result'First-1;
       begin
          for I in The_Characters'Range loop
             Keep(The_Characters(I)) := False;
          end loop;
          for J in The_String'Range loop
             if Keep(The_String(J)) then
                Last := Last+1;
                Result(Last) := The_String(J);
             end if;
          end loop;
          return Result(Result'First .. Last);
       end Strip;

  begin
     while Start <= input'Last loop
        Find_Token (input, To_Set (' '), Start, Outside, Start, Finish);
        exit when Start > Finish;
        Output.Append (input (Start .. Finish));
        Start := Finish + 1;
     end loop;

   -- for each word in Output array, if adding it to line < 60 then add it else
   -- create a new line and add it. Update the max and min before every new line.
   -- increment number of lines and set num words to 1
     for S of Output loop
        word := Trim(To_Unbounded_String(Strip(S, "0123456789")), Right);
        if Numchars + Length(word) <= 60 then
            Append(tmpLine, word);
            Append(tmpLine, " ");
            numWords := numWords + 1;
            if Numchars + Length(word) < 60 then
              Put(To_String(word) & ' ');
              Numchars := Numchars + 1;
            else
              Put(To_String(word));
            end if;
            Numchars := Numchars + Length(word);
          else
            UpdateMinMax(tmpLine, numLines, numWords);
            tmpLine := word & " ";
            numLines := numLines + 1;
            numWords := 1;
            new_line(1);
            Set_Col(8);
            Put(Integer'Image(numLines) & "  " & To_String(word) & " ");
            Numchars := Length(word) + 1;
        end if;
     end loop;
  end Tokenize;

-- main function to read file name in and tokenize one line at a time
begin
    new_line(1);
    Set_Col(8);
    Put(Integer'Image(numLines) & "  ");
    Open(File => file,
        Mode => In_File,
        Name => fileName);
    loop
      declare
        Line : String := Get_Line(file);
      begin
        Tokenize(Line(1..Line'Last - 1));
      end;
    end loop;
    Close (file);
exception
    when End_Error =>
      if Is_Open(file) then
          Close (file);
      end if;
      UpdateMinMax(tmpLine, numLines, numWords);
      new_line(2);
      Set_Col(1);
      Put("LONG");
      Set_Col(8);
      Put(Integer'Image(longLineNum));
      Set_Col(21);
      Put_Line(To_String(longLine));
      Set_Col(1);
      Put("SHORT");
      Set_Col(8);
      Put(Integer'Image(shortLineNum));
      Set_Col(21);
      Put_Line(To_String(shortLine));
      new_line(1);
end formatter;

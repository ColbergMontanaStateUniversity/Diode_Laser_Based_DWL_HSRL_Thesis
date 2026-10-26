function [I] = ReadILXCurrent(instr)

        write(instr,append("LAS:LDI?"));
        pause(.01)
        str = readline(instr);
        ch = char(str);
        I = str2double(ch(1:6));

end
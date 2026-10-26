function [T] = ReadILXTemperature(instr)

        write(instr,append("TEC:T?"));
        pause(.01)
        str = readline(instr);
        ch = char(str);
        T = str2double(ch(1:6));

end
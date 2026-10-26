function SETILXCurrent(instr,I)

    str = num2str(I);
    if str2double(str)<190 % upper current limit hardcode
        pause(0.01)
        write(instr,append("LAS:LDI ",str));
    else
        error("unrealistic laser set current")
    end


end
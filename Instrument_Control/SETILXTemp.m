function SETILXTemp(instr,T)

    str = num2str(T);
    if str2double(str)<30 % upper temperature limit hardcode
        pause(0.01)
        write(instr,append("TEC:T ",str));
    else
        error("unrealistic laser set temperature")
    end

end
function [Wavelength,Power] = ReadBristolWavemeter(tcpClient)
try
    % Define SCPI command
    scpiCommand = '*CLS';  % Example: Query instrument identification

    % Ensure both command and newline are row vectors
    commandToSend = [scpiCommand, char(10)];  % Concatenate with newline character (char(10))

    % Write SCPI command to the device
    write(tcpClient, uint8(commandToSend));  % Send command as uint8 array
    % disp(['SCPI command sent: ', scpiCommand]);

    % Define SCPI command
    scpiCommand = 'FETC:ALL?';  % Example: Query instrument identification

    % Ensure both command and newline are row vectors
    commandToSend = [scpiCommand, char(10)];  % Concatenate with newline character (char(10))
    
    
    % Write SCPI command to the device
    write(tcpClient, uint8(commandToSend));  % Send command as uint8 array
    % disp(['SCPI command sent: ', scpiCommand]);

    % Pause for a moment to wait for the response
    pause(.1);

    % Check if data is available to read
    if tcpClient.NumBytesAvailable > 0
        % Read response from the instrument
        dataReceived = read(tcpClient, tcpClient.NumBytesAvailable, 'uint8');
        receivedString = char(dataReceived);
        % disp(['Full response received: ', receivedString]);

        % Extract the last line of the response
        lines = strsplit(receivedString, '\n');
        DataLine = strtrim(lines{end-1});
        % disp(['Extracted last line: ', DataLine]);

        DataString = strsplit(DataLine,',');
        Wavelength = str2double(DataString(3)); %nm
        Power      = str2double(DataString(4)); %dBm
    else
        disp('No response received.');
    end

    % % Clear TCP/IP client
    % clear tcpClient;
    % disp('Connection closed.');

catch ME
    % Handle errors
    disp(['An error occurred: ', ME.message]);
end

end
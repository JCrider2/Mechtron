% Create a serial object
Port = ['COM3'];  % Replace with your port name
baudRate = 115200;      % Set your baud rate

s = serialport(Port, baudRate);

% Prepare for real-time plotting
figure;
subplot(2,1,1);
hAccelX = animatedline('Color', 'r');
hAccelY = animatedline('Color', 'g');
hAccelZ = animatedline('Color', 'b');
ax = gca;
ax.YGrid = 'on';
XLim = 50;
% Set axis limits (adjust as needed)
ax.YLim = [-16, 16];  % Adjust Y-axis limits based on your data range

subplot(2,1,2);
lGyroX = animatedline('Color','r');
lGyroY = animatedline('Color','g');
lGyroZ = animatedline('Color','b');
ax = gca;
ax.YGrid = 'on';
XLim = 50;
% Set axis limits (adjust as needed)
ax.YLim = [-1000, 1000];


% Matrix for storing all data (columns: timestamp, ax, ay, az)
allData = [];

% Buffer for storing data used for plot (size of buffer is 50)
plotBuffer = nan(50, 7);  % Preallocate buffer with NaNs, columns: timestamp, ax, ay, az

% Read data in a loop (you can modify the loop condition as needed)
try
    % Reduce latency by configuring buffer sizes
    configureTerminator(s, 'LF');
    flush(s);
    
    while true
        % Check for a key press to stop the loop
        if get(gcf, 'CurrentCharacter') == 'q'
            disp('Stopping the data reading loop...');
            break;
        end
        
        % Read a line of data
        if s.NumBytesAvailable > 0
            data = readline(s);
            
            % Split data into components
            splitData = strsplit(data, ',');
            
            if length(splitData) == 7
                % Extract timestamp and accelerometer data
                timestamp = str2double(splitData{1});
                axVal = str2double(splitData{2});
                ay = str2double(splitData{3});
                az = str2double(splitData{4});
                gx = str2double(splitData{5});
                gy = str2double(splitData{6});
                gz = str2double(splitData{7});

                
                % Store the data in allData matrix if valid
                if ~isnan(axVal) && ~isnan(ay) && ~isnan(az)
                    allData = [allData; timestamp, axVal, ay, az, gx, gy, gz];
                    
                    % Update the plot buffer by shifting and appending new data
                    plotBuffer(1:end-1, :) = plotBuffer(2:end, :);  % Shift data up
                    plotBuffer(end, :) = [size(allData, 1), axVal, ay, az, gx, gy, gz];  % Add new data to the end using index  % Add new data to the end
                    
                    % Update the plot
                    clearpoints(hAccelX);
                    clearpoints(hAccelY);
                    clearpoints(hAccelZ);
                    clearpoints(lGyroX);
                    clearpoints(lGyroY);
                    clearpoints(lGyroZ);
                    for j = 1:size(plotBuffer, 1)
                        if ~isnan(plotBuffer(j, 1))  % Only plot valid data
                            addpoints(hAccelX, plotBuffer(j, 1), plotBuffer(j, 2));
                            addpoints(hAccelY, plotBuffer(j, 1), plotBuffer(j, 3));
                            addpoints(hAccelZ, plotBuffer(j, 1), plotBuffer(j, 4));
                            addpoints(lGyroX, plotBuffer(j, 1), plotBuffer(j, 5));
                            addpoints(lGyroY, plotBuffer(j, 1), plotBuffer(j, 6));
                            addpoints(lGyroZ, plotBuffer(j, 1), plotBuffer(j, 7));
                        end
                    end
                    ax.XLim = [max(0, size(allData, 1) - XLim), size(allData, 1)];  % Keep X-axis limit increasing to show scrolling effect  % Keep X-axis limit fixed to buffer size
                    drawnow limitrate;  % Use 'limitrate' to improve performance and reduce lag
                    flushinput(s);
                end
            end
        end
    end
catch exception
    % Handle errors and clean up
    disp('An error occurred:');
    disp(exception.message);
end

% Close the serial port
clear s;
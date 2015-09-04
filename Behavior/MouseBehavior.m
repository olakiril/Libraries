classdef MouseBehavior
    
    properties
        % serial device handle
        ser = [];
        MAGIC = hex2dec('33');
        COMMAND_MAGIC = hex2dec('67');
        LEN = 7;
    end
    
    methods

        function self = open(self, dev_path)
            % open serial device
            self.ser = serial(dev_path);
            fopen(self.ser);
            
            bytes_pending = self.ser.BytesAvailable;
            if (bytes_pending > 0)
                fread(self.ser, bytes_pending, 'uint8');
            end
        end

        function self = close(self)
            % close serial device
            fclose(self.ser);
            self.ser = [];
        end

        function [distance touch] = query(self)
            % get the distance and touch status
            dat = uint8(fread(self.ser, self.LEN, 'uint8'));

            distance = typecast(dat(1:4),'uint32');
            touch = dat(5);
            crc = dat(6);
            magic = dat(7);

            if magic ~= self.MAGIC
                distance = nan;
                touch = nan;
                fread(self.ser, 1, 'uint8');
            end
        end
        
        function juice(self, dur)
            % send juice
            
            dat = uint8(ones(6,1));
            dat(1:2) = typecast(uint16(dur),'uint8'); % Time1
            dat(3:4) = 0;                             % Time2
            dat(5) = 0; % CRC
            dat(6) = self.COMMAND_MAGIC;
            
            fwrite(self.ser, dat, 'uint8');
        end
    end

end
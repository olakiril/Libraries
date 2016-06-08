function tcp = startListener(tcp)
% Start TCP listener.
% AE 2010-05-25

% Go on forever
while true
    
    % Open TCP socket and wait for incoming connection
    fprintf('Waiting for connection on port %d\n',tcp.port);
    tcp.socket = pnet('tcpsocket',tcp.port);
    tcp.con = pnet(tcp.socket,'tcplisten');
    if tcp.con < 0
        fprintf('Could not establish tcp connection!\n\n')
    else
        % Get IP address of connected host
        tcp.host = pnet(tcp.con,'gethost');
        fprintf('Host %d.%d.%d.%d connected\n\n',tcp.host);
        
       
        % Read name of init script and run it
        %   The init script is responsible for setting the matlab path
        [tcp,init] = getFunctionCall(tcp);
        fprintf('Running initialization: %s\n',init);
        run(init);
          
        
        try
            % make sure variable e holds experiment object
            assert(logical(exist('e','var')) && isa(e,'BasicExperiment'), ...
            'Start script must create variable e holding experiment object!')
            fprintf('Starting %s\n',class(e))

            % Indicate successful function call
            returnFunctionCall(tcp,init,0,struct);

            e = openWindow(e);
        
            % Assign this connection handle to the object        
            e = setConnection(e,tcp);
            
            fprintf('Connection stored succesfully\n');
            
            
            tcpMainListener(e);

        catch
            a = lasterror;
            fprintf('\nError message: %s\n\n',a.message);
            fprintf('Error identifier: %s\n',a.identifier);
            fprintf('\nError stack:\n');
            for i = 1:length(a.stack)
                fprintf('Line %0.0d in %s\n',a.stack(i).line,a.stack(i).file);
            end
            fprintf('\n\n');
            fprintf('Function call failed\n');
            % indicate failed function call
            returnFunctionCall(tcp,init,-1,struct);
        end
        
        % Start the main loop processing remote function calls. At the end
        % of the experiment, the TCP connection is closed and the function
        % returns.
    end
    fprintf('Connection closed remotely. Restarting...\n')
end

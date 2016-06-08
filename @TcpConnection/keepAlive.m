function keepAlive(tcp)
% keepAlive(tcp)
%
% This function sends a negative one through the pnet interface to Matlab.
% It is not good to expose this direct functionality because if this
% function is called at the wrong time (i.e. when Labview is not waiting
% for a function to return) the TCP stack will get corrupted and all hell
% will break lose.  The ideal thing to do would be for this function to be
% aware that a function has been called and not returned, so I've tried to
% implement this as the tcp.inFunctionCall counter.
%
% JC 2008-07-01

if tcp.inFunctionCall == 0
    warning('TcpConnection:keepAlive','Called keep alive, but according to the function stack Labview is not waiting for a function to return - aborting.  Check you experiment code calls for keepAlive');
    return
end

pnet(tcp.con, 'write', -1,[1 1],'int32');
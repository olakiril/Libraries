function connected = isConnected(tcp)
% Returns true if there is currently an open connection.
% AE 2007-10-04

connected = ~isempty(tcp.con) && pnet(tcp.con,'status') > 0;

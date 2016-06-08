function tcp = startListenerOld(tcp)
% Only for backwards compatibility
% AE 2010-05-25

tcp.socket = pnet('tcpsocket',tcp.port);
fprintf('\n* ||Waiting for connection on port %d\n',tcp.port);
tcp.con = pnet(tcp.socket,'tcplisten');
if tcp.con < 0
    error('TcpConnection:startListener','Could not establish tcp connection!')
end
tcp.host = pnet(tcp.con,'gethost');
fprintf('* Host %d.%d.%d.%d connected\n\n',tcp.host);

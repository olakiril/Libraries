function data = getDataTCP(ip,bus)

try
    con = pnet('tcpconnect',ip,bus);
    data = pnet(con,'read');
    pnet(con,'close');
catch
    pnet('closeall')
end
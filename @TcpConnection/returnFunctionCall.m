function tcp = returnFunctionCall(tcp,functionName,retValI32,retStruct)
% Return remote function call.
%    returnFunctionCall(tcpConnection,functionName,retValI32,retStruct)
%    
%    functionName: name of the function that sends the return
%    retValI32: return valus of type int32 (usually some kind of error
%               code)
%    retStruct: more complex return values are returned in a matlab
%               structure. Each field can contain matrices of doubles or
%               int32, or a cell array of strings.
%
% JC & AE 2007-10-04

% track the number of outstanding function calls (JC 2008-07-01)
if tcp.inFunctionCall == 0
    warning('TcpConnection:returnFuctionCall','A function tried to return to Labview but our record of the stack indicates that there are no functions to return.  This is either a bug in the specific experiment code or the TcpConnection library logic');
    return
end
tcp.inFunctionCall = tcp.inFunctionCall - 1;    

toReturn = [];

toReturn = [toReturn, fliplr(typecast(int32(length(functionName)),'uint8'))];
%pnet(tcp.con,'write',int32(length(functionName)));

toReturn = [toReturn, uint8(functionName)];
%pnet(tcp.con,'write',functionName);

toReturn = [toReturn, fliplr(typecast(int32(retValI32),'uint8'))];
%pnet(tcp.con,'write',int32(retValI32));

toReturn = [toReturn, writeStruct(tcp,retStruct)];

pnet(tcp.con, 'write', toReturn,[size(toReturn,1), size(toReturn,2)],'uint8');

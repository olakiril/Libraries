function dec = binBinaryToDec(bin)

% converts binary vectors to corresponding decimal numbers
% last position is 2^0, first is 2^n-1
%
% dim * n
%
% PHB 2007-04-10


bb = (size(bin,1)-1):-1:0;
dec = (2.^bb) * (bin>0);

    
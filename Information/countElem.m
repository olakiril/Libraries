function c = countElem(x,sv,ev)

%  counts the occurences for each value in [sv,ev)

if nargin<2
    sv=0;
    ev=max(x);
end

c =histc(x,sv:ev-1);
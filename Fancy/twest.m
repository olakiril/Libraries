

% draw a dot inside a square with no axis
fig_handle=figure(1);
cla;
% [hdot,hline] = graphdot([1 0 0]);
imagesc(randn(10,10));
% draw an x where user clicks in the figure
% stop when user hits a key
k=-1;
while k ~=1
   k=waitforbuttonpress;
   % get the coordinates of the point where user has clicked mouse
   pos= get(gca,'CurrentPoint');
   display([num2str(pos(1,1)) '  ' num2str(pos(1,2))]);

   
   text(pos(1,1),pos(1,2),'x');
end

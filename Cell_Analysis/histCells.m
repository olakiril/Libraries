function histCells(fc,varargin)

params.Thr = 0.05;
params.Bin = 16;
params.dir = 0;

params = getParams(params,varargin);

% do it for orientation or direction
if params.dir
    vonMissesIndex = 4;
    xlab = 'Binned Directions';
    p = 2*pi;
else
    vonMissesIndex = 3;
    xlab = 'Binned Orientations';
    p = pi;
end

% create even angle spaces
bcents = linspace(0,p,params.Bin+1);
bcents = .5*(bcents(1:end-1) + bcents(2:end));

% get Data
pOti = getPoti(fc);
ori = getVonMises(fc,vonMissesIndex);

sign = pOti<=params.Thr;
prcSign = sum(sign)/length(sign);

% plot
figure
subplot(1,4,1:3)
hist(ori(sign),bcents);
ylabel(gca,'# neurons');
set(gca,'XTick',0:round(p*100/params.Bin)/100:p)
set(gca,'XTickLabel',round(bcents/pi*(180)))
xlabel(gca,num2str(xlab));
set(gca,'box','off');

subplot(144)
axis off
AxisPro = axis;
Yscale = AxisPro(4)-AxisPro(3);

text(0,(AxisPro(3)+(Yscale*10)/12),' %Sign.Tun : ','FontWeight','Bold');
text(0,(AxisPro(3)+(Yscale*10)/12),['                       ' num2str(round(prcSign*100)) '%']);

text(0,(AxisPro(3)+(Yscale*8)/12), 'Total#Cells :','FontWeight','Bold');
text(0,(AxisPro(3)+(Yscale*8)/12),[ '                       ' num2str(length(sign)) ]);


set(gcf,'paperpositionmode','auto');
set(gcf,'Color',[1 1 1])


% Plots and identifies the various colorbrewer tables available.
% Is called by cbrewer.m when no arguments are given.
%
% Author: Charles Robert
% email: tannoudji@hotmail.com
% Date: 14.10.2011

load('colorbrewer.mat')

ctypes = fieldnames(colorbrewer);
ntypes = length(ctypes);

figure('position', [314 327 807 420])
for itype=1:ntypes
    
    cnames = fieldnames(colorbrewer.(ctypes{itype}));
    %fh(itype)=figure();
    
    subplot(1,ntypes,itype)
    
    for iname=1:length(cnames)
        
        ncol=length(colorbrewer.(ctypes{itype}).(cnames{iname}));
        fg=1./ncol; % geometrical factor

        X=fg.*[0 0 1 1];
        Y=0.1.*[1 0 0 1]+(2*iname-1)*0.1;
        F=cbrewer(ctypes{itype}, cnames{iname}, ncol);

        for icol=1:ncol
            X2=X+fg.*(icol-1);
            fill(X2,Y,F(icol, :), 'linestyle', 'none')
            text(-0.1, mean(Y), cnames{iname}, 'HorizontalAlignment', 'right', 'FontWeight', 'bold', 'FontSize', 10, 'FontName' , 'AvantGarde')
            xlim([-0.4, 1])
            hold all
        end % icol
        title(ctypes{itype}, 'FontWeight', 'bold', 'FontSize', 16, 'FontName' , 'AvantGarde')
        axis off
        set(gcf, 'color', [1 1 1])
    end % iname

end %itype

set(gcf, 'MenuBar', 'none')
set(gcf, 'Name', 'ColorBrewer Color maps')
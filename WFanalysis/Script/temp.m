axesH = findobj(gcf,'Type','ax');
for i = 1:6
    axesH(i).Title.Color = 'r';
end

for j = 7:length(axesH)
    axesH(j).Title.Color = 'b';
end

set(gcf, 'Position',[23,424,1888,560]);

set(gcf, 'Position',a);

saveas(gcf,'m1224_session.fig')

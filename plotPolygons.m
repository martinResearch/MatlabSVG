function handles=plotPolygons(polygons,colors)

hold on;
handles=cell(1,length(polygons));
for k =1 : length(polygons)
            poly=polygons{k};
            if (~isempty(poly))
                h=fill(poly(1,:),poly(2,:),colors(1:3,k)');
                handles{k}=h;
                if size(colors,1)==4
                    set(h,'facealpha',colors(4,k));
                end
                set(h,'ButtonDownFcn',@(src,~) clickCallback(k))
                set(h,'UserData',k);
            end
end

set(gcf,'Renderer','OpenGL');
%set(gcf,'Renderer','painters');

function clickCallback(k)
 fprintf('clicked on polygon %d\n',k)

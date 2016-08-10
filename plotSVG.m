function plotSVG(svg)


for idImage=1: length(svg.images)

    imagefile=svg.images{idImage}.file;
    imshow(imread(imagefile));
    axis('ij');
    hold on;
end

for idLayer =1: length(svg.layers)
    layer=svg.layers{idLayer};
    plotPolygons(layer.polys,layer.colors);
end


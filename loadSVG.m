%% License FreeBSD:
%     
%      Copyright (c) 2016  Martin de La Gorce
%      All rights reserved.
%      
%      Redistribution and use in source and binary forms, with or without
%      modification, are permitted provided that the following conditions are met:
%      
%      1. Redistributions of source code must retain the above copyright notice, this
%         list of conditions and the following disclaimer.
%      2. Redistributions in binary form must reproduce the above copyright notice,
%         this list of conditions and the following disclaimer in the documentation
%         and/or other materials provided with the distribution.
%      
%      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%      ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%      DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
%      ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%      (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%      LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%      ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%      SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%      
%      The views and conclusions contained in the software and documentation are those
%      of the authors and should not be interpreted as representing official policies,
%      either expressed or implied, of the FreeBSD Project.
%

function [svg]=loadSVG(file)
if nargin<=1
    display=false;
end

xDoc = xmlread(file);

svg=struct();
imagesXml =xDoc.getElementsByTagName('image');
svg.images=cell(1,length(imagesXml));
for k=0:length(imagesXml)-1
    item=imagesXml.item(k);
    image.x=str2num(char(item.getAttribute('x')));
    image.y=str2num(char(item.getAttribute('y')));
    image.width=str2num(char(item.getAttribute('width')));
    image.height=str2num(char(item.getAttribute('height')));
    image.file= fullfile( fileparts(file),char(item.getAttribute('xlink:href')));
    svg.images{k+1}=image;
end


layers=xDoc.getElementsByTagName('g');


svg.layers={};
svg.layers=cell(1,layers.getLength);
for idlayer=0:layers.getLength-1
    layerXml=layers.item(idlayer);
    if layerXml.hasAttribute('inkscape:label')
        layername=char(layerXml.getAttribute('inkscape:label'));
    else
        layername=[]
    end
        allPaths =layerXml.getElementsByTagName('path');
       % fprintf('found %d polygones...',allPaths.getLength)
        createModified=false;
        paths= cell(allPaths.getLength,1);
        for k =0:allPaths.getLength-1
            paths{k+1} = allPaths.item(k);
        end
        polys=cell(allPaths.getLength,1);
        colors=zeros(4,allPaths.getLength);
        stroke_colors=zeros(4,allPaths.getLength);
        svgids=cell(allPaths.getLength,1);
        nbpolys=allPaths.getLength;
        nbpoly_imported=0;
        for k=1:nbpolys
            thisItem= paths{k} ;
            [poly,stroke_color,fill_color,svgid]=readPath(thisItem);
            if ~isempty(poly)
                nbpoly_imported=nbpoly_imported+1;
                polys{k}=poly;
                svgids{k}=svgid;
                stroke_colors(:,k)=stroke_color;
                colors(:,k)=fill_color;
            end
        end
        if nbpoly_imported<allPaths.getLength
          warning('could not import  %d polygons over %d in layer \n',allPaths.getLength-nbpoly_imported,allPaths.getLength,idlayer+1)
        end
        layer.polys=polys;
        layer.colors=colors;
        layer.svgids=svgids;
        layer.name=layername;
        layer.stroke_colors=stroke_colors;
        svg.layers{idlayer+1}=layer;
        
    end

end








function [poly,stroke_color,fill_color,id]=readPath(thisItem)
id=char(thisItem.getAttribute('id'));
if strcmp(id,'path404705')
    fprintf('hello')
end
poly=[];
fill_color=[];
stroke_color=[];
if (~isempty(thisItem) )
    if ~thisItem.hasAttribute('d')
        thisItem.getParentNode().removeChild(thisItem)
        return
    end
    
    polyStr=char(thisItem.getAttribute('d'));
    if (lower(polyStr(1))~='m') && (polyStr(end)~='z')
        fprintf('not expected \n')
        thisItem.getParentNode().removeChild(thisItem);
        createModified=true;
        return
    end
    if any(polyStr=='c') ||  any(polyStr=='l')
        error('does not handle curves path yet edit path with id %s\n',id);
        thisItem.getParentNode().removeChild(thisItem);
        createModified=true;
        return
    else
        style=char(thisItem.getAttribute('style'));
        mapObj = containers.Map;
        C = strsplit(style,{';'});
        for i =1:length(C)
            D = strsplit(C{i},{':'});
            
            mapObj(D{1}) = D{2};
        end
        col=mapObj('fill');
        if mapObj.isKey('opacity')
            opacity=str2num(mapObj('opacity'));
        else
            opacity=1
        end
        if ~strcmp(col,'none')
            r=hex2dec(col(2:3))/255;
            g=hex2dec(col(4:5))/255;
            b=hex2dec(col(6:7))/255;
        else
            r=0;g=0;b=0;
        end
        fill_color=[r,g,b,opacity];
        
        col=mapObj('stroke');
        r=hex2dec(col(2:3))/255;
        g=hex2dec(col(4:5))/255;
        b=hex2dec(col(6:7))/255;
        stroke_color=[r,g,b,opacity];
        
        
        if polyStr(end)=='z'
            polyStr=polyStr(1:end-1);
        end
        polyIncs=reshape(str2num(polyStr(2:end)),2,[]);
        if polyStr(1)=='m'
            poly=cumsum(polyIncs,2);
        else
            poly=polyIncs;
        end
        
        
        % thisItem.getParentNode().removeChild(thisItem)
        
    end
end


end

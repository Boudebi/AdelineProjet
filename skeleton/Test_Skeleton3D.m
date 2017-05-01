clear all;
close all;

%load matrice_aorte

cheminToDicom = 'C:\Users\Benjamin\Documents\AdelineProjet.git\TSA\TSA CT 1\Segmentation 3';

nomImageCrop = strcat(cheminToDicom,'\Segmentation001.dcm');
imageCrop = dicomread(nomImageCrop);
imshow(imadjust(imageCrop))
[xCrop, yCrop] = getpts;
 imageInit = imcrop(imageCrop,[xCrop yCrop size(imageCrop,2) size(imageCrop,1)]);

nbrSliceAorte = 54;
matrice_aorte = zeros(size(imageInit,1),size(imageInit,2),nbrSliceAorte);
matrice_aorte = chargementDICOM(1, 54, matrice_aorte, cheminToDicom, xCrop, yCrop, imageCrop);

se = strel('sphere',5);
matrice_aorte = imopen(matrice_aorte, se);

skel = Skeleton3D(matrice_aorte);

% % Création du dossier Segmentation
% nomDossier = sprintf('/Skeleton');
% path_Seg = strcat(cheminToDicom, nomDossier);
% mkdir(path_Seg)

% disp('Conversion du Skeleton en dicom')
% % Enregistrement sous format png pour visualisation de chaque slice puis
% % conversion en dicom pour visualisation 3D
% for i =1:size(skel,3)
%     % ecriture en png
%     nomImage = sprintf('/Skeleton%d.png',i);
%     path_write_png = strcat(path_Seg, nomImage);
%     imwrite(skel(:,:,i),path_write_png)
%     
%     %%% Conversion des png en dicom %%%
%     
%     imageLoad1 = imread(path_write_png);
%     
%     % Les noms sont fonction de i, sinon pas dans l'ordre avec ITKsnap
%     if i<10
%         nomDICOM1 = sprintf('/Skeleton00%d.dcm',i);
%     elseif i<100
%         nomDICOM1 = sprintf('/Skeleton0%d.dcm',i);
%     elseif i<1000
%         nomDICOM1 = sprintf('/Skeleton%d.dcm',i);
%     end
%         
%     path_write_dicom = strcat(path_Seg, nomDICOM1);
%     % Besoin d'un header pour mettre tous les dicom dans le même fichier
%     headerdicom = dicominfo(nomImageCrop);
% 
%     % ecriture en dicom
%     dicomwrite(imageLoad1,path_write_dicom,headerdicom);
% end

% figure();
% col=[.7 .7 .8];
% hiso = patch(isosurface(matrice_aorte,0),'FaceColor',col,'EdgeColor','none');
% hiso2 = patch(isocaps(matrice_aorte,0),'FaceColor',col,'EdgeColor','none');
% axis equal;axis off;
% lighting phong;
% isonormals(matrice_aorte,hiso);
% alpha(0.5);
% set(gca,'DataAspectRatio',[1 1 1])
% camlight;
% hold on;
% w=size(skel,1);
% l=size(skel,2);
% h=size(skel,3);
% [x,y,z]=ind2sub([w,l,h],find(skel(:)));
% plot3(y,x,z,'square','Markersize',4,'MarkerFaceColor','r','Color','r');            
% set(gcf,'Color','white');
% view(140,80)

w = size(skel,1);
l = size(skel,2);
h = size(skel,3);

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,18);

% total length of network
wl = sum(cellfun('length',{node.links}));

skel2 = Graph2Skel3D(node,link,w,l,h);
[~,node2,link2] = Skel2Graph3D(skel2,18);

% calculate new total length of network
wl_new = sum(cellfun('length',{node2.links}));

% iterate the same steps until network length changed by less than 0.5%
while(wl_new~=wl)

    wl = wl_new;   
    
     skel2 = Graph2Skel3D(node2,link2,w,l,h);
     [A2,node2,link2] = Skel2Graph3D(skel2,0);

     wl_new = sum(cellfun('length',{node2.links}));

end;

% display result
figure();
col=[.7 .7 .8];
hiso = patch(isosurface(matrice_aorte,0),'FaceColor',col,'EdgeColor','none');
hiso2 = patch(isocaps(matrice_aorte,0),'FaceColor',col,'EdgeColor','none');
axis equal;axis off;
lighting phong;
isonormals(matrice_aorte,hiso2);
alpha(0.5);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;
for i=1:length(node2)
    x1 = node2(i).comx;
    y1 = node2(i).comy;
    z1 = node2(i).comz;
    
    if(node2(i).ep==1)
        ncol = 'c';
    else
        ncol = 'y';
    end;
    
    for j=1:length(node2(i).links)    % draw all connections of each node
        if(node2(link2(node2(i).links(j)).n2).ep==1)
            col='k'; % branches are blue
        else
            col='k'; % links are red
        end;
        if(node2(link2(i).n1).ep==1)
            col='k';
        end;

        
        % draw edges as lines using voxel positions
        for k=1:length(link2(node2(i).links(j)).point)-1            
            [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
            [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
            line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
        end;
    end;
    
    % draw all nodes as yellow circles
    plot3(y1,x1,z1,'o','Markersize',9,...
        'MarkerFaceColor',ncol,...
        'Color','k');
end;
axis image;axis off;
set(gcf,'Color','white');
drawnow;
view(-17,46);

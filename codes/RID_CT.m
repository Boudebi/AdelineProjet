% Segmentation et squeletisation de la crosse aortique et des carotides
%--------------------------------------------------------------------------

%Paul A. Yushkevich, Joseph Piven, Heather Cody Hazlett, Rachel Gimpel Smith, Sean Ho, James C. Gee, and Guido Gerig. User-guided 3D active contour segmentation of anatomical structures: Significantly improved efficiency and reliability. Neuroimage. 2006 Jul 1; 31(3):1116-28.
clear all
close all
clc

cheminToDicom = input('Entrer le chemin vers le dicom a charger: ','s');
%cheminToDicom = 'C:\Users\Benjamin\Documents\AdelineProjet.git\TSA\TSA CT 1';
imageStartAorte = input('Entrer le numéro (X) de la première image de l AORTE (IM-0001-000X-0001.dcm): ');
% 487 | 500
imageEndAorte = input('Entrer le numéro de la (X) de la dernière image de l AORTE(IM-0001-000X-0001.dcm): ');
% 540| 613
%imageStartCarotide = 420;%input('Entrer le numéro (X) de la première image pour les CAROTIDES (IM-0001-000X-0001.dcm): ');
% 504
%imageEndCarotide = 504;%input('Entrer le numéro de la (X) de la dernière image pour les CAROTIDES (IM-0001-000X-0001.dcm): ');
% 420



typeImage = upper(input('Entrez le type de fichier CT ou IRM : ','s'));
%cheminToDicom = 'C:\Users\adels\OneDrive\Documents\cours_ISBS2\S2\RID\TSA\TSA CT 1\';

% création de la matrice de travail

% selection des region d'interet
if strcmp(typeImage,'CT' )
    disp('Choissez l origine de la region d interet')
    if imageEndAorte<10
        nomImage = sprintf('/IM-0001-000%d-0001.dcm',imageEndAorte);
    elseif imageEndAorte<100
        nomImage = sprintf('/IM-0001-00%d-0001.dcm',imageEndAorte);
    elseif imageEndAorte<1000
        nomImage = sprintf('/IM-0001-0%d-0001.dcm',imageEndAorte);
    end
    
    nomImageCrop = strcat(cheminToDicom,nomImage);
    imageCrop = dicomread(nomImageCrop);
    imshow(imadjust(imageCrop))
    [xCrop, yCrop] = getpts;
    
elseif strcmp(typeImage,'IRM')
    disp('Choissez l origine de la region d interet')
    if imageEnd<10
        nomImage = sprintf('/IM-0001-000%d-0001.dcm',imageEnd);
    elseif imageEnd<100
        nomImage = sprintf('/IM-0001-00%d-0001.dcm',imageEnd);
    elseif imageEnd<1000
        nomImage = sprintf('/IM-0001-0%d-0001.dcm',imageEnd);
    end
    strImageEnd = int2str(imageEndAorte);
    nomImageCrop = strcat(cheminToDicom,nomImage);
    imageCrop = dicomread(nomImageCrop);
    imshow(imadjust(imageCrop))
    [xCrop, yCrop] = getpts;
end

% Permet d'avoir les dimensions pour construire la matrice ensuite
imageInit = imcrop(imageCrop,[xCrop yCrop size(imageCrop,2) size(imageCrop,1)]);

%construit une matrice 3D avec la longueur et largueur de la region d'interet
%comme la premiere image et une profondeur égale au nombre d'image contenue
%dans le dossier

nbrSliceAorte = imageEndAorte-imageStartAorte;
%nbrSliceCarotide = imageEndCarotide-imageStartCarotide;

matrice_aorte = zeros(size(imageInit,1),size(imageInit,2),nbrSliceAorte);
%matrice_carotide1 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
%matrice_carotide2 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
%matrice_carotide3 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
%matrice_carotide4 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);

% boucle pour charger le DICOM
disp('Chargement des DICOM')

matrice_aorte = chargementDICOM(imageStartAorte,imageEndAorte,matrice_aorte,cheminToDicom,xCrop,yCrop,imageCrop);
%matrice_carotide1 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide1,cheminToDicom,xCrop,yCrop,imageCrop);
%matrice_carotide2 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide2,cheminToDicom,xCrop,yCrop,imageCrop);
%matrice_carotide3 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide3,cheminToDicom,xCrop,yCrop,imageCrop);
%matrice_carotide4 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide4,cheminToDicom,xCrop,yCrop,imageCrop);

% ---------------------- Region growing pour aorte-------------------------

% initialisation des position x et y
disp('Veuillez selectionner le centre de l aorte : ')
imshow(imadjust(matrice_aorte(:,:,nbrSliceAorte)));
[x,y] = getpts;
y=round(y(1)); 
x=round(x(1));

disp('Segmentation par region growing')
[Vers, matrice_aorte] = regionGrowing2(matrice_aorte, [x,y,nbrSliceAorte]);
%[Vers, matrice_aorte] = regionGrowing2(matrice_aorte);
imshow(matrice_aorte(:,:,1))

%disp('Veuillez selectionner le centre des 4 carotides : ')

% initialisation des points pour les snake et les différentes carotides
% figure(); 
% imshow(imadjust(matrice_carotide1(:,:,1)));
% [x1, y1]=getpts;
% y1=round(y1(1)); 
% x1=round(x1(1));
% 
% figure(); 
% imshow(imadjust(matrice_carotide2(:,:,1)));
% [x2, y2]=getpts;
% y2=round(y2(1)); 
% x2=round(x2(1));
% 
% figure(); 
% imshow(imadjust(matrice_carotide3(:,:,1)));
% [x3, y3]=getpts;
% y3=round(y3(1)); 
% x3=round(x3(1));
% 
% figure(); 
% imshow(imadjust(matrice_carotide4(:,:,1)));
% [x4, y4]=getpts;
% y4=round(y4(1)); 
% x4=round(x4(1));
% 
% [Vers1, matrice_carotide1] = regionGrowing2(matrice_carotide1,[x1,y1,1]);
% [Vers2, matrice_carotide2] = regionGrowing2(matrice_carotide2,[x2,y2,1]);
% [Vers3, matrice_carotide3] = regionGrowing2(matrice_carotide3,[x3,y3,1]);
% [Vers4, matrice_carotide4] = regionGrowing2(matrice_carotide4,[x4,y4,1]);

% ------ Ajout des differentes segmentation dans la même matrice ----------
% prend le plus de slice possible
% nbrSlice = max([imageEndAorte imageEndCarotide]) - min([imageStartAorte imageStartCarotide]);
% matrice_totale = zeros(size(imageInit,1),size(imageInit,2),nbrSlice);
% 
% matrice_totale = matrice_aorte + matrice_carotide1 + matrice_carotide2+ matrice_carotide3+ matrice_carotide4;
matrice_totale = matrice_aorte;


% ------------------------- Visualisation ---------------------------------

% Création du dossier Segmentation
nomDossier = sprintf('/Segmentation');
path_Seg = strcat(cheminToDicom, nomDossier);
mkdir(path_Seg);

disp('Conversion de la segmentation en dicom')
% Enregistrement sous format png pour visualisation de chaque slice puis
% conversion en dicom pour visualisation 3D
for i =1:size(matrice_totale,3)
    % ecriture en png
    nomImage = sprintf('/Segmentation%d.png',i);
    path_write_png = strcat(path_Seg, nomImage);
    imwrite(matrice_totale(:,:,i),path_write_png)
    
    %%% Conversion des png en dicom %%%
    
    imageLoad1 = imread(path_write_png);
    
    % Les noms sont fonction de i, sinon pas dans l'ordre avec ITKsnap
        if i<10
        nomDICOM1 = sprintf('/Segmentation00%d.dcm',i);
    elseif i<100
        nomDICOM1 = sprintf('/Segmentation0%d.dcm',i);
    elseif i<1000
        nomDICOM1 = sprintf('/Segmentation%d.dcm',i);
        end
        
    path_write_dicom = strcat(path_Seg, nomDICOM1);
    % Besoin d'un header pour mettre tous les dicom dans le même fichier
    headerdicom = dicominfo(nomImageCrop);

    % ecriture en dicom
    dicomwrite(imageLoad1,path_write_dicom,headerdicom);
end

se = strel('sphere',5);
matrice_aorte = imopen(matrice_aorte, se);

skel = Skeleton3D(matrice_aorte);

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

disp('fin')
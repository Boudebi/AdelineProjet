% Segmentation et squeletisation de la crosse aortique et des carotides
%--------------------------------------------------------------------------

%Paul A. Yushkevich, Joseph Piven, Heather Cody Hazlett, Rachel Gimpel Smith, Sean Ho, James C. Gee, and Guido Gerig. User-guided 3D active contour segmentation of anatomical structures: Significantly improved efficiency and reliability. Neuroimage. 2006 Jul 1; 31(3):1116-28.
clear all
close all
clc

cheminToDicom = input('Entrer le chemin vers le dicom a charger: ','s');
imageStartAorte = input('Entrer le numéro (X) de la première image de l AORTE (IM-0001-000X-0001.dcm): ');
% 500
imageEndAorte = input('Entrer le numéro de la (X) de la dernière image de l AORTE(IM-0001-000X-0001.dcm): ');
% 613
imageStartCarotide = input('Entrer le numéro (X) de la première image pour les CAROTIDES (IM-0001-000X-0001.dcm): ');
% 504
imageEndCarotide = input('Entrer le numéro de la (X) de la dernière image pour les CAROTIDES (IM-0001-000X-0001.dcm): ');
% 420



typeImage = upper(input('Entrez le type de fichier CT ou IRM : ','s'));
%cheminToDicom = 'C:\Users\adels\OneDrive\Documents\cours_ISBS2\S1\RID\TSA\TSA CT 1\';

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
nbrSliceCarotide = imageEndCarotide-imageStartCarotide;

matrice_aorte = zeros(size(imageInit,1),size(imageInit,2),nbrSliceAorte);
matrice_carotide1 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
matrice_carotide2 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
matrice_carotide3 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);
matrice_carotide4 = zeros(size(imageInit,1),size(imageInit,2),nbrSliceCarotide);

% boucle pour charger le DICOM
disp('Chargement des DICOM')

matrice_aorte = chargementDICOM(imageStartAorte,imageEndAorte,matrice_aorte,cheminToDicom,xCrop,yCrop,imageCrop);
matrice_carotide1 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide1,cheminToDicom,xCrop,yCrop,imageCrop);
matrice_carotide2 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide2,cheminToDicom,xCrop,yCrop,imageCrop);
matrice_carotide3 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide3,cheminToDicom,xCrop,yCrop,imageCrop);
matrice_carotide4 = chargementDICOM(imageStartCarotide,imageEndCarotide,matrice_carotide4,cheminToDicom,xCrop,yCrop,imageCrop);

% ---------------------- Region growing pour aorte-------------------------

% initialisation des position x et y
disp('Veuillez selectionner le centre de l aorte : ')
imshow(imadjust(matrice_aorte(:,:,nbrSliceAorte)));
[x,y] = getpts;



disp('Segmentation par region growing')
matrice_aorte = regionGrowing2(matrice_aorte,[x,y,1],200,Inf, [], true, false);
imshow(matrice_aorte(:,:,1))

disp('Veuillez selectionner le centre des 4 carotides : ')

% initialisation des points pour les snake et les différentes carotides
figure(); 
imshow(imadjust(matrice_carotide1(:,:,1)));
[x1, y1]=getpts;

figure(); 
imshow(imadjust(matrice_carotide1(:,:,1)));
[x2, y2]=getpts;

figure(); 
imshow(imadjust(matrice_carotide1(:,:,1)));
[x3, y3]=getpts;

figure(); 
imshow(imadjust(matrice_carotide1(:,:,1)));
[x4, y4]=getpts;

matrice_carotide1 = regionGrowing2(matrice_carotide1,[x1,y1,1],200,Inf, [], true, false);
matrice_carotide2 = regionGrowing2(matrice_carotide2,[x2,y2,1],200,Inf, [], true, false);
matrice_carotide3 = regionGrowing2(matrice_carotide3,[x3,y3,1],200,Inf, [], true, false);
matrice_carotide4 = regionGrowing2(matrice_carotide4,[x4,y4,1],200,Inf, [], true, false);

% ------ Ajout des differentes segmentation dans la même matrice ----------
% prend le plus de slice possible
nbrSlice = max([imageEndAorte imageEndCarotide]) - min([imageStartAorte imageStartCarotide]);
matrice_totale = zeros(size(imageInit,1),size(imageInit,2),nbrSlice);

matrice_totale = matrice_aorte + matrice_carotide1 + matrice_carotide2+ matrice_carotide3+ matrice_carotide4;


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

disp('fin')
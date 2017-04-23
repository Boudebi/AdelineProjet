% Segmentation et squeletisation de la crosse aortique et des carotides
%--------------------------------------------------------------------------

%Paul A. Yushkevich, Joseph Piven, Heather Cody Hazlett, Rachel Gimpel Smith, Sean Ho, James C. Gee, and Guido Gerig. User-guided 3D active contour segmentation of anatomical structures: Significantly improved efficiency and reliability. Neuroimage. 2006 Jul 1; 31(3):1116-28. 
clear all 
close all
clc

cheminToDicom = input('Entrer le chemin vers le dicom a charger: ','s');
imageStartCarotides = input('Entrer le numéro (X) de la première image de CAROTIDES (IM-0001-000X-0001.dcm): ');
% RM1 : 39, RM2 : 113, RM3 : 70
imageEndAorte = input('Entrer le numéro de la (X) de la dernière image de l AORTE (IM-0001-000X-0001.dcm): ');
% RM1 : 165, RM2 : 250, RM3 : 188
typeImage = upper(input('Entrez le type de fichier CT ou IRM : ','s'));
%cheminToDicom = 'C:/Users/Solange/Desktop/Documents/ISBS3/RID/TSA CT 1/';

% création de la matrice de travail

% selection des region d'interet
disp('Choissez l origine de la region d interet')
    if imageEndAorte<10
        nomImage = sprintf('/IM-0001-000%d-0001.dcm',imageEndAorte);
    elseif imageEndAorte<100
        nomImage = sprintf('/IM-0001-00%d-0001.dcm',imageEndAorte);
    elseif imageEndAorte<1000
        nomImage = sprintf('/IM-0001-0%d-0001.dcm',imageEndAorte);
    end
    strImageEnd = int2str(imageEndAorte);
    nomImageCrop = strcat(cheminToDicom,nomImage);
    imageCrop = dicomread(nomImageCrop);
    imshow(imadjust(imageCrop))
    [xCrop, yCrop] = getpts;
    
% Permet d'avoir les dimensions pour construire la matrice ensuite
imageInit = imcrop(imageCrop,[xCrop yCrop size(imageCrop,2) size(imageCrop,1)]);

%construit une matrice 3D avec la longueur et largueur de la region d'interet 
%comme la premiere image et une profondeur égale au nombre d'image contenue
%dans le dossier

nbrSlice = imageEndAorte-imageStartCarotides;
matrice = zeros(size(imageInit,1),size(imageInit,2),nbrSlice);
matricesquelette = zeros(size(imageInit,1),size(imageInit,2),nbrSlice);

% boucle pour charger le DICOM
disp('Chargement des DICOM')
for i = imageStartCarotides : imageEndAorte
    
    % Modification du nom en fonction du chiffre utilisé pour adapter le
    % nombre de zéros devant le %d
    if i<10
        nomImage = sprintf('/IM-0001-000%d-0001.dcm',i);
    elseif i<100
        nomImage = sprintf('/IM-0001-00%d-0001.dcm',i);
    elseif i<1000
        nomImage = sprintf('/IM-0001-0%d-0001.dcm',i);
    end
    
    % concatène le chemin et le nom
    path = strcat(cheminToDicom , nomImage);
    
    % ouverture du dicom suivant le chemin spécifié avant
    imageInter =im2double( dicomread(path));
   
    
    % selection de la region d'interet car les images sont trop lourdes
    % pour l'ordinateur
    imageFinal = imcrop(imageInter,[xCrop yCrop size(imageInter,2) size(imageInter,1)]);
   
    % enregistrement dans la matrice de travail
    matrice(:,:,i-imageStartCarotides+1) = imageFinal;
end

% les images ayant beaucoup de bruit pour faire le region growing il faut
% lisser les images donc on fait un filtre gaussien puis moyenneur

% initialisation des position x et y
if strcmp(typeImage,'IRM')
    imshow(matrice(:,:,nbrSlice), [1 250]);
end

% verifie que le point seed est bien dans la region
if strcmp(typeImage, 'IRM')
    disp('Segmentation par threshold')
    for i = 1: nbrSlice-1
        matrice(:,:,nbrSlice-i) = threshold(matrice(:,:,nbrSlice-i));
        matrice(:,:,nbrSlice-i) = enleverbruit(matrice(:,:,nbrSlice-i));
    end
end


% Création du dossier Segmentation
nomDossier = sprintf('/Segmentation');
path_Seg = strcat(cheminToDicom, nomDossier);
mkdir(path_Seg);


disp('Conversion de la segmentation en dicom')
% Enregistrement sous format png pour visualisation de chaque slice puis
% conversion en dicom pour visualisation 3D
for i =1:size(matrice,3)
    % ecriture en png
    nomImage = sprintf('/Segmentation%d.png',i);
    path_write_png = strcat(path_Seg, nomImage);
    imwrite(matrice(:,:,i),path_write_png)
    
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
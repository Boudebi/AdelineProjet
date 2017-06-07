function[matrice] = chargementDICOM(imageStart, imageEnd, matrice, cheminToDicom, xCrop, yCrop, imageCrop)
% permet l'ouverture des image dicom
% input:
%   imageStart : première image à ouvrir
%   imageEnd : dernière image à ouvrir
%   matrice : matrice dans laquel on stocke les image en DOUBLE
%   cheminToDicom : chemin ABSOLU vers les images 
%   xCrop : coordonée x du rognage
%   yCrop : coordonée y du rognage
%   imageCrop : image déjà rognée pour avoir ses dimensions

for i = imageStart : imageEnd
    
    % Modification du nom en fonction du chiffre utilisé pour adapter le
    % nombre de zéros devant le %d
    if i<10
        nomImage = sprintf('/Segmentation00%d.dcm',i);
    elseif i<100
        nomImage = sprintf('/Segmentation0%d.dcm',i);
    elseif i<1000
        nomImage = sprintf('/Segmentation%d.dcm',i);
    end
    
    % concatène le chemin et le nom
    path = strcat(cheminToDicom , nomImage);
    
    % ouverture du dicom suivant le chemin spécifié avant
    %imageInter = imadjust(dicomread(path));
    imageInter = im2double(dicomread(path));
    
    
    % selection de la region d'interet car les images sont trop lourdes
    % pour l'ordinateur
    imageFinal = imcrop(imageInter,[xCrop yCrop size(imageCrop,2) size(imageCrop,1)]);
    
    % enregistrement dans la matrice de travail
    matrice(:,:,i-imageStart+1) = imageFinal;
end

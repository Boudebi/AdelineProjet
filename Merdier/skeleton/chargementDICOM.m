function[matrice] = chargementDICOM(imageStart, imageEnd, matrice, cheminToDicom, xCrop, yCrop, imageCrop)
% permet l'ouverture des image dicom
% input:
%   imageStart : premi�re image � ouvrir
%   imageEnd : derni�re image � ouvrir
%   matrice : matrice dans laquel on stocke les image en DOUBLE
%   cheminToDicom : chemin ABSOLU vers les images 
%   xCrop : coordon�e x du rognage
%   yCrop : coordon�e y du rognage
%   imageCrop : image d�j� rogn�e pour avoir ses dimensions

for i = imageStart : imageEnd
    
    % Modification du nom en fonction du chiffre utilis� pour adapter le
    % nombre de z�ros devant le %d
    if i<10
        nomImage = sprintf('/Segmentation00%d.dcm',i);
    elseif i<100
        nomImage = sprintf('/Segmentation0%d.dcm',i);
    elseif i<1000
        nomImage = sprintf('/Segmentation%d.dcm',i);
    end
    
    % concat�ne le chemin et le nom
    path = strcat(cheminToDicom , nomImage);
    
    % ouverture du dicom suivant le chemin sp�cifi� avant
    %imageInter = imadjust(dicomread(path));
    imageInter = im2double(dicomread(path));
    
    
    % selection de la region d'interet car les images sont trop lourdes
    % pour l'ordinateur
    imageFinal = imcrop(imageInter,[xCrop yCrop size(imageCrop,2) size(imageCrop,1)]);
    
    % enregistrement dans la matrice de travail
    matrice(:,:,i-imageStart+1) = imageFinal;
end

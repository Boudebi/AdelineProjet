function[BW] = threshold(Name)
% Cette fonction permet de segmenter les images IRM de l'aorte
% valeur du pixel max qui est censé se trouver dans notre région d'intérêt grace aux produits de contraste
% divisé par 3 pour ne pas avoir un pixel unique
    level = max(max(Name))/3;
    BW = im2bw(Name,level); % binarisation de l'image
end


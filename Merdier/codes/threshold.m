function[BW] = threshold(Name)
% Cette fonction permet de segmenter les images IRM de l'aorte
% valeur du pixel max qui est cens� se trouver dans notre r�gion d'int�r�t grace aux produits de contraste
% divis� par 3 pour ne pas avoir un pixel unique
    level = max(max(Name))/3;
    BW = im2bw(Name,level); % binarisation de l'image
end


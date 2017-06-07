function[ImageFermee] = enleverbruit(Name)
% Cette fonction permet de diminuer le bruit après segmentation des images
% IRM, nous effectuons donc une ouverture, puis une fermeture
SE = strel('disk',2); % fermeture ou ouverture avec un disque de 2 pixels
ImageOuverte = imopen(Name,SE);
ImageFermee = imclose(ImageOuverte,SE);
end

pkg load image;
max_recursion_depth(256*256);

% Recursive function for count the number of connected pixels for a pixel      
function [total, PV] = AdjacencyPixelsConnected(I, i, j, PV)
  total = 0;
  if PV(i,j) == 1
    return;
  endif
  
  PV(i,j) = 1;

  if I(i,j) == 0
    return
  elseif i == 1 || j == 1 || i == rows(I) || j == columns(I)
    total = -1;
    return
  else  
    total++;
  endif
  
  [t1, PV] = AdjacencyPixelsConnected(I, i-1, j-1, PV);
  [t2, PV] = AdjacencyPixelsConnected(I, i-1, j, PV);
  [t3, PV] = AdjacencyPixelsConnected(I, i-1, j+1, PV);
  [t4, PV] = AdjacencyPixelsConnected(I, i, j-1, PV);
  [t5, PV] = AdjacencyPixelsConnected(I, i, j+1, PV);
  [t6, PV] = AdjacencyPixelsConnected(I, i+1, j-1, PV);
  [t7, PV] = AdjacencyPixelsConnected(I, i+1, j, PV);
  [t8, PV] = AdjacencyPixelsConnected(I, i+1, j+1, PV);
  
  if t1 == -1 || t2 == -1 || t3 == -1 || t4 == -1 || t5 == -1 || t6 == -1 || t7 == -1 || t8 == -1
    total = -1;
  else
    total += t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8;
  endif  
endfunction

# Open the image
img = imread('./rice.tif');
[r c] = size(img);

# Erosion
dimension = 7;
mask = getnhood(strel('disk',dimension,0));
resultMat = zeros(256,256);
erosion = 256*ones(256+dimension*2, 256+dimension*2);
erosion(1 + dimension:256 + dimension,1 + dimension:256 + dimension) = img;

totalBits = 0;

for i=1:rows(mask)
  for j=1:columns(mask)
    if mask(i,j) == 1
      totalBits++;
    endif
  endfor
endfor

vetI = zeros(1, totalBits);    
vetJ = zeros(1, totalBits);

ii = 1;
for i=1:rows(mask)
  for j=1:columns(mask)
    if mask(i,j) == 1 
      vetI(1,ii) = i - (dimension + 1);
      vetJ(1,ii) = j - (dimension + 1);
      ii++;
    endif
  endfor
endfor

for i=1 + dimension:256 + dimension
  for j=1 + dimension:256 + dimension
    minvalue = 256;
    for ii=1:totalBits
      value = erosion(i + vetI(ii), j + vetJ(ii)); 
      if value < minvalue
        minvalue = value;
      endif  
    endfor
    resultMat(i-dimension,j-dimension) = minvalue;
  endfor
endfor

# Dilatation
background = zeros(256,256);
dilatation = zeros(256+dimension*2, 256+dimension*2);
dilatation(1 + dimension:256 + dimension,1 + dimension:256 + dimension)  = resultMat;

for i=1 + dimension:256 + dimension
  for j=1 + dimension:256 + dimension
    maxvalue = 0;
    for ii=1:totalBits
      value = dilatation(i + vetI(ii), j + vetJ(ii)); 
      if value > maxvalue
        maxvalue = value;
      endif  
    endfor
    background(i-dimension,j-dimension) = maxvalue;
  endfor
endfor

# Subtracting the background from the image to make a illumination more uniform
I = img - background;

# calculate the histogram
histogram = zeros(1, 256);
newImage = zeros(r, c);
for i = 1:r
  for j = 1:c
    histogram(I(i,j)+1)++;
  endfor
endfor

# Find the threshold
threshold = 0;
for i = 1: 256
  if histogram(i) <= 170 || i > 50
    threshold = i;
    break;
  endif  
endfor

# Binarizating the image
for i = 1:r
  for j = 1:c
  if I(i,j) <= 40
      newImage(i,j) = 0;
    else  
      newImage(i,j) = 255;
    endif  
  endfor
endfor

# Use the 8-adjacency for counting the number of rices
I = newImage;
AllPixelsRice = zeros(1,128*128);
total = 0;

PixelsVisited = zeros(r,c);

for i = 2:r-1
  for j = 2:c-1
    if PixelsVisited(i,j) == 0 && I(i,j) == 255
      PixelsVisited(i,j) = 1;
      totalPixelsRice = 0;
      
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i-1, j-1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i-1, j, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i-1, j+1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i, j-1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i, j+1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i+1, j-1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i+1, j, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      [t, PixelsVisited] = AdjacencyPixelsConnected(I, i+1, j+1, PixelsVisited);
      if t == -1
        continue;
      else
        totalPixelsRice += t;
      endif  
      
      total++;
      AllPixelsRice(1,total) += totalPixelsRice;
    endif
    PixelsVisited(i,j) = 1;
  endfor
endfor     

printf("Numero de Graos de Arroz: %d\n", total);
m = sum(AllPixelsRice(1, 1:total))/total; 
stdev= sqrt(sum(AllPixelsRice(1, 1:total).^2)/total - m.^2); 
printf("Valor medio da Area: %d\nDesvio Padrao da Area: %d\n", m, stdev);
printf("Area:\n");
for i=1:total
  printf("   Arroz %d: %d\n", i, AllPixelsRice(1,i));
endfor

figure;
imshow(img);
title("Original Image");

figure;
imshow(I);
title("Binarizated Image");
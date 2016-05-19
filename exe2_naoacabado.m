clear;
clc;
pkg load image;

function erosion = getNHood(img, mask, i, j)
  [n m] = size(img);
  [r c] = size(mask);
  erosion = zeros(r, c);
  centerI = round(r/2);
  centerJ = round(c/2);
  
  k = 1;
  for ii = i-centerI+1:i+(r-centerI)
    l = 1;
    for jj = j-centerJ+1:j+(c-centerJ)
      if ii >= 1 && ii <= n && j >= 1 && jj <= m
        erosion(k,l) = mask(k,l)*img(ii,jj);
      else
        erosion(k,l) = 0;
      endif
      l++;  
    endfor
    k++;
  endfor
endfunction

function histogram = getHistogram(image, l)
  [n m] = size(image);
  histogram = zeros(1, l);
  for i = 1:n
    for j = 1:m
      histogram(image(i,j)+1)++;
    endfor
  endfor
  histogram = histogram / m * n;
endfunction

function image = globalHistogramLinearization(img, l)
  [n m] = size(img);
  image = zeros(n, m);
  h = getHistogram(img, l);
  s = zeros(1,l);
  div = m * n;
  k = (l - 1) / div;
  
  for i = 1:l
    sumH = 0;
    for j = 1:i
      sumH += h(j);
    endfor
    s(i) = k * sumH;
  endfor
  
  for i = 1:n
    for j = 1:m
      image(i,j) = round(s(img(i,j) + 1));
    endfor
  endfor
  image = uint8(image);
endfunction

function image = localHistogramLinearization(img, l, nhoodI, nhoodJ)
  [n m] = size(img);
  centerI = round(nhoodI/2);
  centerJ = round(nhoodJ/2); 
  expImg = zeros(n + nhoodI - 1, m + nhoodJ - 1);
  expImg(centerI:n + centerI - 1, centerJ: m + centerJ - 1) = img;
  histogram = zeros(1,l);
  image = zeros(n,m);

  for i = centerI:n + centerI - 1
    for j = centerJ: m + centerJ - 1
      localImg = ones(nhoodI, nhoodJ);
      localImg = getNHood(img, localImg, i, j);
      localImg = globalHistogramLinearization(localImg, l);
      image(i,j) = localImg(centerI,centerJ);
    endfor
  endfor
endfunction

# open the images
carimg = imread('./car-ant.gif');
fig3img = imread('./Fig3.15(a).jpg');
l = 256;
nhoodI = nhoodJ = 3;

#{
image = globalHistogramLinearization(carimg, l);
figure;
imshow(carimg);
figure;
imshow(image);
#}


#image = localHistogramLinearization(carimg, l,nhoodI, nhoodJ);
img = carimg;
[n m] = size(img);
centerI = round(nhoodI/2);
centerJ = round(nhoodJ/2); 
expImg = zeros(n + nhoodI - 1, m + nhoodJ - 1);
expImg(centerI:n + centerI - 1, centerJ: m + centerJ - 1) = img;
histogram = zeros(1,l);
image = zeros(n,m);

for i = centerI:n + centerI - 1
  for j = centerJ: m + centerJ - 1
    localImg = ones(nhoodI, nhoodJ);
    localImg = getNHood(img, localImg, i, j);
    #localImg = globalHistogramLinearization(localImg, l);
    [n m] = size(localImg);
    Limage = zeros(n, m);
    h = getHistogram(localImg, l);
    s = zeros(1,l);
    div = m * n;
    k = (l - 1) / div;
    
    for ii = 1:l
      sumH = 0;
      for jj = 1:ii
        sumH += h(jj);
      endfor
      s(ii) = k * sumH;
    endfor
    
    for ii = 1:n
      for jj = 1:m
        Limage(ii,jj) = round(s(localImg(ii,jj) + 1));
      endfor
    endfor
    Limage = uint8(Limage);
    
    localImg = Limage;
    
    image(i,j) = localImg(centerI,centerJ);
  endfor
endfor


figure;
imshow(carimg);
figure;
imshow(image);



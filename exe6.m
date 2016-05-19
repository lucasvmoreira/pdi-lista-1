    pkg load image;
    
    
    # Open the image
    img = imread('./img/lena.tif');
    [r c] = size(img);
    freqCorteD = 0;
    ordem = 1;
    # Filtro passa-baixa Butterworth
    % creates a spherical structuring element whose radius is R pixels.)
    %SE = strel('sphere',R);
    %mask = getnhood(SE);
    %
    
     
    img = double(img);    
    [r c] = size(img);  
    u = img;    
    img = uint8(u);
    imwrite(img,'./img/lena.jpg');
    fftu = fft2(u,2*r-1,2*c-1);  
    fftu = fftshift(fftu);   
    subplot(2,2,1); 
    imshow(img,[]);   
    subplot(2,2,2);        
    fftshow(fftu,'log');
     
    % Initialize filter.
     
    filter1 = ones(2*r-1,2*c-1);    
    filter2 = ones(2*r-1,2*c-1);     
    filter3 = ones(2*r-1,2*c-1);     
    n = 1;    
    for i = 1:2*r-1     
      for j =1:2*c-1    
        dist = ((i-(r+1))^2 + (j-(c+1))^2)^.5;        
        % Use Butterworth filter.   
        filter1(i,j)= 1/(1 + (dist/120)^(2*n));         
        filter2(i,j) = 1/(1 + (dist/30)^(2*n));         
        filter3(i,j)= 1.0 - filter2(i,j);        
        filter3(i,j) = filter1(i,j).*filter3(i,j);   
      end   
    end
    
    % Update image with passed frequencies.
     
    fil_micro = fftu + filter3.*fftu;    
    subplot(2,2,3)    
    fftshow(filter3,'log')   
    fil_micro = ifftshift(fil_micro);   
    fil_micro = ifft2(fil_micro,2*r-1,2*c-1);    
    fil_micro = real(fil_micro(1:r,1:c));    
    fil_micro = uint8(fil_micro);   
    subplot(2,2,4)     
    imshow(fil_micro,[])
       
%    
%    figure;
%    imshow(img);
%    title("Original Image");
%    
%    figure;
%    imshow(filtered_image);
%    title("Filtered Image - D0 - Ordem 1");

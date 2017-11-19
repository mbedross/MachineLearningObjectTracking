function [Img,medianImg,imNameOut] = returnMedianImgAndImg( z, t, tEnd, numFrames, imgScaleFactor )
%This function finds the median background in the Image 'Img' by
%calculating the median of a group of integer 'numFrames' images.

%The images are located in the same z-Slice as Img, and at t+/-numFrames.
h = 1;
imgFormat = '.tiff';

%----------------------------------------------------------
%the section below is for image filenames of the format 'zzz (t)', for
%example: '005 (2).tiff'
%----------------------------------------------------------
if z>=0
    
%     if z<10
%         zIdx = strcat('00',int2str(z));
%         
%     elseif z<100
%         zIdx = strcat('0',int2str(z));
%     else
        zIdx = int2str(z);
%     end
else
    a_z = abs(z);
%     if a_z<10
%         zIdx = strcat('-00',int2str(a_z));
%         
%     elseif a_z<100
%         zIdx = strcat('-0',int2str(a_z));
%     else
        zIdx = strcat('-',int2str(a_z));
%     end
end
%------------------------------------------------------------
%------------------------------------------------------------
% zIdx = int2str(z);

if numFrames ==0
    
    tIdx = int2str(t);
    imName = strcat(zIdx,' (',tIdx,')',imgFormat);
    Img = normalizeGrayscale_127(imresize(imread(imName),imgScaleFactor));
    medianImg = 127;
    imNameOut = imName;
else

if t<=numFrames
    for k = 1 :numFrames*2+1
       
        tIdx = int2str(k);
        imName = strcat(zIdx,' (',tIdx,')',imgFormat);
        sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
        if t ==k
            i = h;
            imNameOut = imName;
        end
        h=h+1;
    end
    
else if t>tEnd-numFrames
        
        for k = tEnd-(2*numFrames) :tEnd
            
            tIdx = int2str(k);
            imName = strcat(zIdx,' (',tIdx,')',imgFormat);
            sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
            if t ==k
                i = h;
                imNameOut = imName;
            end
            h=h+1;
        end
        
        
    else
        for k = t-numFrames :t+numFrames 
            
            tIdx = int2str(k);
            imName = strcat(zIdx,' (',tIdx,')',imgFormat);
            sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
            if t ==k
                i = h;
                imNameOut = imName;
            end            
            h=h+1;
        end
    end
end

    sampleImgs_n = normalizeGrayscale_127(sampleImgs);
    Img = sampleImgs_n(:,:,i);
    medianImg=getMedianImage(sampleImgs_n);
end
end
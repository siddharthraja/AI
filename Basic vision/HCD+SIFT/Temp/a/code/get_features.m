% Local Feature Stencil Code
% CS 4495 / 6476: Computer Vision, Georgia Tech
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

% Placeholder that you can delete. Empty features.
gy = fspecial('sobel');
gx = gy';
% Image gradients
[Ix , Iy] = gradient(image);

%witghting for the window
weight = fspecial('Gaussian', feature_width , feature_width/2);
winOffset = feature_width/2 ;

%preallocate features
features = zeros(length(x), 128);

%bin edges for histogram
bins = [ 0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi] - (pi/8);

%Iterate over all interest points
for i=1:length(x)
    x_i = y(i);
    y_i = x(i);
    
    %feature at this keypoint
    featureI = zeros(1,128);
    %get gradients in the window
    windowIx = Ix(x_i-winOffset+1:x_i+winOffset, y_i-winOffset+1:y_i+winOffset);
    windowIy = Iy(x_i-winOffset+1:x_i+winOffset, y_i-winOffset+1:y_i+winOffset);
    %weight window by gaussian
    
    windowIx = windowIx .* weight;
    windowIy = windowIy .* weight;
    %Iterate over each window in in the 4x4 grid
    binCount = 1;
    for subWinI=1:4:13
        for subWinJ=1:4:13
            subWindowIx = windowIx(subWinI:subWinI+3, subWinJ:subWinJ+3);
            subWindowIy = windowIy(subWinI:subWinI+3, subWinJ:subWinJ+3);
            %column vector of all gradients at each pixel
            subWinGradients = [subWindowIx(:), subWindowIy(:)];
            angles = zeros(length(subWinGradients), 1);
            for angleI=1:length(angles)
                angles(angleI) = mod(atan2(subWinGradients(angleI,2), subWinGradients(angleI,1)), 2*pi);
            end
            %reshape angles
            angles = angles';
            tempHist = histcounts(angles, bins);

            %normalize to 1
            tempHist = tempHist/norm(tempHist);
            %clamp to 0.2
            tempHist(tempHist > 0.2) = 0.2;
            %renormalize
            tempHist = tempHist/norm(tempHist);
 
            featureI(binCount:binCount+7) = tempHist;
            
            binCount=binCount + 8;
            
            
            
            
        end
    end
    
    features(i, :) = featureI;
    
    
end




end









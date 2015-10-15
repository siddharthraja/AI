% by Siddharth Raja
% Returns a set of feature descriptors for a given set of interest points. 


function [features] = get_features(image, x, y, feature_width)



    f_number = length(x);
    g = fspecial('Gaussian', feature_width , feature_width/2);
    gw = fspecial('Gaussian', feature_width/2 , 2); % window weights
    features = zeros(f_number, 128);
    win_step = 16;
    subwin_step = 4;
    bins = [0:45:360] * pi/180; % buckets
    [magnitudes, angles] = imgradient(image);
    angles = angles + 180;
    angles = angles .* pi/180;
    % magnitudes = imfilter(magnitudes, gw);
    
    for i=1:f_number
        descriptors = zeros(1,128); 
        step = 1;
        iterator = 1:subwin_step:win_step;
        
        win = angles(y(i)-feature_width/2+1 : y(i)+feature_width/2, x(i)-feature_width/2+1 : x(i)+feature_width/2);
        
        for I = iterator
            for J = iterator
                subwin_ang = win(I:I + subwin_step - 1, J:J + subwin_step - 1);
                % subwin_mag = magnitudes(I:I + subwin_step - 1, J:J + subwin_step - 1);
                orientations = subwin_ang(:);
                % ang = zeros(length(orientations), 1);               
                hist = histcounts(orientations', bins);  
                % Normalize, clipping and renormalize
                hist = hist / norm(hist);
                hist(hist > 0.2) = 0.2;
                hist = hist / norm(hist);
                descriptors(step:step+7) = hist;
                step = step + 8;
                
            end
        end
        features(i, :) = descriptors;
    end  
    fprintf('finished get_features\n');
        
end









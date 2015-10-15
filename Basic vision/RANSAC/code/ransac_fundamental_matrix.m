% RANSAC Stencil Code
% By Siddharth

function [ Best_Fmatrix, inliers_a, inliers_b] = ransac_fundamental_matix(matches_a, matches_b)

% homogenization of points
uv1a = [matches_a ones(size(matches_a ,1),1)];
uv1b = [matches_b ones(size(matches_b ,1),1)];
% init inliers matrices
inliers_a = zeros(size(uv1a,1), 2);
inliers_b = zeros(size(uv1a,1), 2);

bestcount = 0;
approx = 0.025;

% looping for RANSAC
for i = 1:8000
    
    % calculate F for 8 random points
    r = randperm(size(uv1a,1));
    a = uv1a(r(1:8),:);
    b = uv1b(r(1:8),:);    
    %Get fundamental matrix for these 8 points
    Ftemp = estimate_fundamental_matrix(a,b);
    
    % x * F * x' < approx (almost 0)
    count = 0;
    for j = 1:size(uv1a,1)
        X = abs(uv1a(j,:) * Ftemp *  uv1b(j,:)');
        if X <= approx
            count = count + 1;
        end
    end
    if count > bestcount
        bestcount = count;
        Best_Fmatrix = Ftemp;
    end
    
end

display(bestcount);
% get inliers based on Best_Fmatrix and approx value
for  i = 1:size(uv1a,1)
     X = abs(uv1a(i,:) * Best_Fmatrix *  uv1b(i,:)');
     if X <= approx
         inliers_a(i, 1:2) = uv1a(i, 1:2);
         inliers_b(i, 1:2) = uv1b(i, 1:2);
     end
end

% remove unwanted (zero) valued rows
inliers_a(all(inliers_a==0,2),:) = [];
inliers_b(all(inliers_b==0,2),:) = [];
num = 400;
if size(inliers_a, 1) > num
    inliers_a = inliers_a(1:num,:);
    inliers_b = inliers_b(1:num,:);
end

end


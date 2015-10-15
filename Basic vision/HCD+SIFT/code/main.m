% Controller file to call all the necessary functions that do Harris Corner detection and SIFT pipeline
% credits: James Hays

% This script 
% (1) Loads and resizes images
% (2) Finds interest points in those images                 
% (3) Describes each interest point with a local feature   
% (4) Finds matching features                               
% (5) Visualizes the matches
% (6) Evaluates the matches based on ground truth correspondences

close all


% Notre Dame
% image1 = imread('../data/Notre Dame/921919841_a30df938f2_o.jpg');
% image2 = imread('../data/Notre Dame/4191453057_c86028ce1f_o.jpg');
% eval_file = '../data/Notre Dame/921919841_a30df938f2_o_to_4191453057_c86028ce1f_o.mat';

% Mount Rushmore
image1 = imread('../data/Mount Rushmore/9021235130_7c2acd9554_o.jpg');
image2 = imread('../data/Mount Rushmore/9318872612_a255c874fb_o.jpg');
eval_file = '../data/Mount Rushmore/9021235130_7c2acd9554_o_to_9318872612_a255c874fb_o.mat';

% Episcopal Gaudi
% image1 = imread('../data/Episcopal Gaudi/4386465943_8cf9776378_o.jpg');
% image2 = imread('../data/Episcopal Gaudi/3743214471_1b5bbfda98_o.jpg');
% eval_file = '../data/Episcopal Gaudi/4386465943_8cf9776378_o_to_3743214471_1b5bbfda98_o.mat';
% % 
image1 = single(image1)/255;
image2 = single(image2)/255;


%make images smaller to speed up the algorithm. This parameter gets passed
%into the evaluation code so don't resize the images except by changing
%this parameter.
scale_factor = 0.5; 
image1 = imresize(image1, scale_factor, 'bilinear');
image2 = imresize(image2, scale_factor, 'bilinear');

% Avoiding to work with grayscale images. Matching with color
% information might be helpful.
image1_bw = rgb2gray(image1);
image2_bw = rgb2gray(image2);


feature_width = 16; %width and height of each local feature, in pixels. 

%% Find distinctive points in each image. Szeliski 4.1.1
[x1, y1] = get_interest_points(image1_bw, feature_width);
[x2, y2] = get_interest_points(image2_bw, feature_width);

%% Create feature vectors at each interest point. Szeliski 4.1.2
[image1_features] = get_features(image1_bw, x1, y1, feature_width);
[image2_features] = get_features(image2_bw, x2, y2, feature_width);


%% Match features. Szeliski 4.1.3
[matches, confidences] = match_features(image1_features, image2_features);

display(matches);

% set 'num_pts_to_visualize' and 'num_pts_to_evaluate' to some constant (e.g. 100) 
% if hundreds of interest points are detected or threshold based on confidence

% Two visualization functions. Optional.
num_pts_to_visualize = size(matches,1);
show_correspondence(image1, image2, x1(matches(1:num_pts_to_visualize,1)), ...
                                    y1(matches(1:num_pts_to_visualize,1)), ...
                                    x2(matches(1:num_pts_to_visualize,2)), ...
                                    y2(matches(1:num_pts_to_visualize,2)));
                                 
show_correspondence2(image1, image2, x1(matches(1:num_pts_to_visualize,1)), ...
                                     y1(matches(1:num_pts_to_visualize,1)), ...
                                     x2(matches(1:num_pts_to_visualize,2)), ...
                                     y2(matches(1:num_pts_to_visualize,2)));
% 
% % This evaluation function will only work for the particular Notre Dame
% % image pair specified in the starter code.  Comment out this function if
% % you are not testing on the Notre Dame, Mount Rushmore, or Episcopal Gaudi
% % image pairs. Only those pairs have ground truth available. You can use
% % collect_ground_truth_corr.m to build the ground truth for other image
% % pairs if you want, but it's very tedious. 
num_pts_to_evaluate = size(matches,1);
evaluate_correspondence(image1, image2, eval_file, scale_factor, ... 
                        x1(matches(1:num_pts_to_evaluate,1)), ...
                        y1(matches(1:num_pts_to_evaluate,1)), ...
                        x2(matches(1:num_pts_to_evaluate,2)), ...
                        y2(matches(1:num_pts_to_evaluate,2)));













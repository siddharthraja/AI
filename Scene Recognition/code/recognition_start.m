% Starter code by James Hays and Sam Birch


%% Step 0: Set up parameters, vlfeat, category list, and image paths.

%combinations of features / classifiers implemented:
% 1) Tiny image features and nearest neighbor classifier
% 2) Bag of sift features and nearest neighbor classifier
% 3) Bag of sift features and linear SVM classifier
%The starter code is initialized to 'placeholder' just so that the starter
%code does not crash when run unmodified and you can get a preview of how
%results are presented.

FEATURE = 'tiny image';
% FEATURE = 'bag of sift';
% FEATURE = 'placeholder';

CLASSIFIER = 'nearest neighbor';
% CLASSIFIER = 'support vector machine';
% CLASSIFIER = 'placeholder';

% set up paths to VLFeat functions. 
% See http://www.vlfeat.org/matlab/matlab.html for VLFeat Matlab documentation
run ('../vlfeat-0.9.20/toolbox/vl_setup');

data_path = '../data/'; %change if you want to work with a network copy

%This is the list of categories / directories to use. The categories are
%somewhat sorted by similarity so that the confusion matrix looks more
%structured (indoor and then urban and then rural).
categories = {'Kitchen', 'Store', 'Bedroom', 'LivingRoom', 'Office', ...
       'Industrial', 'Suburb', 'InsideCity', 'TallBuilding', 'Street', ...
       'Highway', 'OpenCountry', 'Coast', 'Mountain', 'Forest'};
   
%This list of shortened category names is used later for visualization.
abbr_categories = {'Kit', 'Sto', 'Bed', 'Liv', 'Off', 'Ind', 'Sub', ...
    'Cty', 'Bld', 'St', 'HW', 'OC', 'Cst', 'Mnt', 'For'};
    
%number of training examples per category to use. Max is 100. For
%simplicity, we assume this is the number of test cases per category, as
%well.
num_train_per_cat = 100; 

%This function returns cell arrays containing the file path for each train
%and test image, as well as cell arrays with the label of each train and
%test image. By default all four of these arrays will be 1500x1 where each
%entry is a char array (or string).
fprintf('Getting paths and labels for all train and test data\n')
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_image_paths(data_path, categories, num_train_per_cat);
%   train_image_paths  1500x1   cell      
%   test_image_paths   1500x1   cell           
%   train_labels       1500x1   cell         
%   test_labels        1500x1   cell          

%% Step 1: Represent each image with the appropriate feature
% Each function to construct features should return an N x d matrix, where
% N is the number of paths passed to the function and d is the 
% dimensionality of each image representation. 

fprintf('Using %s representation for images\n', FEATURE)

switch lower(FEATURE)    
    case 'tiny image'
        % get_tiny_images.m 
        train_image_feats = get_tiny_images(train_image_paths);
        save('train_image_feats.mat', 'train_image_feats')
        test_image_feats  = get_tiny_images(test_image_paths);
        save('test_image_feats.mat', 'test_image_feats')
        
    case 'bag of sift'
        % build_vocabulary.m
        % check if file already exists, delete vocab.mat to have the code rebuild it
        if ~exist('vocab.mat', 'file') 
            fprintf('No existing visual word vocabulary found. Computing one from training images\n')
            vocab_size = 10; 
            %Larger values will work better (to a point) but be slower to compute
            vocab = build_vocabulary(train_image_paths, vocab_size);
            save('vocab.mat', 'vocab')
        end
        
        % get_bags_of_sifts.m
        % check if file already exists, delete train_image_feats.mat to have the code rebuild it
        if ~exist('train_image_feats.mat', 'file') 
            train_image_feats = get_bags_of_sifts(train_image_paths);
            save('train_image_feats.mat', 'train_image_feats')
        end
        % check if file already exists, delete test_image_feats.mat to have the code rebuild it
        if ~exist('test_image_feats.mat', 'file')
            test_image_feats  = get_bags_of_sifts(test_image_paths);
            save('test_image_feats.mat', 'test_image_feats')
        end
    case 'placeholder'
        train_image_feats = [];
        test_image_feats = [];
        
    otherwise
        error('Unknown feature type')
end


%% Step 2: Classify each test image by training and using the appropriate classifier
% Each function to classify test features will return an N x 1 cell array,
% where N is the number of test cases and each entry is a string indicating
% the predicted category for each test image. Each entry in
% 'predicted_categories' must be one of the 15 strings in 'categories',
% 'train_labels', and 'test_labels'. 

fprintf('Using %s classifier to predict test set categories\n', CLASSIFIER)
load('train_image_feats.mat')
load('test_image_feats.mat')
switch lower(CLASSIFIER)    
    case 'nearest neighbor'
        % nearest_neighbor_classify.m 
        predicted_categories = nearest_neighbor_classify(train_image_feats, train_labels, test_image_feats);
        
    case 'support vector machine'
        % svm_classify.m 
        predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats);
        
    case 'placeholder'
        %The placeholder classifier simply predicts a random category for
        %every test case
        random_permutation = randperm(length(test_labels));
        predicted_categories = test_labels(random_permutation); 
        
    otherwise
        error('Unknown classifier type')
end



%% Step 3: Build a confusion matrix and score the recognition system
% This function will recreate results_webpage/index.html and various image
% thumbnails each time it is called. View the webpage to help interpret
% your classifier performance. Where is it making mistakes? Are the
% confusions reasonable?
create_results_webpage( train_image_paths, ...
                        test_image_paths, ...
                        train_labels, ...
                        test_labels, ...
                        categories, ...
                        abbr_categories, ...
                        predicted_categories)






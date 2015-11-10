% Code by siddharth
%This function will train a linear SVM for every category (i.e. one vs all)
%and then use the learned linear classifiers to predict the category of
%every test image. Every test feature will be evaluated with all 15 SVMs
%and the most confident SVM will "win". Confidence, or distance from the
%margin, is W*X + B where '*' is the inner product or dot product and W and
%B are the learned hyperplane parameters.

function predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats)
% image_feats is an N x d matrix, where d is the dimensionality of the
%  feature representation.
% train_labels is an N x 1 cell array, where each entry is a string
%  indicating the ground truth category for each training image.
% test_image_feats is an M x d matrix, where d is the dimensionality of the
%  feature representation. You can assume M = N unless you've modified the
%  starter code.
% predicted_categories is an M x 1 cell array, where each entry is a string
%  indicating the predicted category for each test image.


category_list = unique(train_labels); 
% disp(train_image_feats);
% disp(test_image_feats);
W_mat = zeros(size(category_list,1), size(train_image_feats, 2));
B_mat = zeros(size(category_list,1), 1);
% label specific one vs all    
for i = 1:size(category_list)
    category = char(category_list(i));
    matching_indices = strcmp(category, train_labels);
    labels = double(ones(size(train_image_feats,1), 1) * (-1));
    labels(matching_indices) = 1;    
    [W, B] = vl_svmtrain(train_image_feats', labels, 0.0001);
    W_mat(i,:) = W';
    B_mat(i,:) = B;    
end

for i = 1:size(test_image_feats, 1)
    X = test_image_feats(i, :);
    dist = (W_mat * X' + B_mat)';
    %disp(dist);
    max_ind = find(dist == max(dist));
    predicted_categories(i, 1) = category_list(max_ind(1));
end



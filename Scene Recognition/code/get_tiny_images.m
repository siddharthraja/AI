% code by siddharth

%This feature is inspired by the simple tiny images used as features in 
%  80 million tiny images: a large dataset for non-parametric object and
%  scene recognition. A. Torralba, R. Fergus, W. T. Freeman. IEEE
%  Transactions on Pattern Analysis and Machine Intelligence, vol.30(11),
%  pp. 1958-1970, 2008. http://groups.csail.mit.edu/vision/TinyImages/

function image_feats = get_tiny_images(image_paths)


% suggested functions: imread, imresize

image_feats = zeros(size(image_paths, 1), 256);
for i=1:size(image_paths)
    img = imread(num2str(cell2mat(image_paths(i))));
    img = imresize(img, [16 16]);
    image_feats(i, :) = reshape(img, 1, 256);
end






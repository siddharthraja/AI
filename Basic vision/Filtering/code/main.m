close all; % closes all figures

image1 = im2single(imread('../data/cat.bmp'));
image2 = im2single(imread('../data/dog.bmp'));


%% Filtering and Hybrid Image construction
cutoff_frequency = 4.5;

filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);

low_frequencies = my_imfilter(image1, filter);
high_frequencies = my_imfilter(image2, filter);
high_frequencies = image2 - high_frequencies;

hybrid_image = low_frequencies + high_frequencies;

%% Visualize and save outputs
figure(1); imshow(low_frequencies)
figure(2); imshow(high_frequencies + 0.5);
imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);

% Fundamental Matrix Estimation Stencil Code
% by Henry Hu

% This script 
% (1) Loads 2D points from image pairs and the images themselves
% (2) Estimates the fundamental matrix                   
% (3) Draws the epipolar lines on images

clear
close all

formatSpec = '%f';
size2d_norm = [2 Inf];

file_2d_pic_a = fopen('../data/pts2d-pic_a.txt','r');
file_2d_pic_b = fopen('../data/pts2d-pic_b.txt','r');
Points_2D_pic_a = fscanf(file_2d_pic_a,formatSpec,size2d_norm)';
Points_2D_pic_b = fscanf(file_2d_pic_b,formatSpec,size2d_norm)';

ImgLeft  = imread('../data/pic_a.jpg');
ImgRight = imread('../data/pic_b.jpg');


%% Calculate the fundamental matrix given corresponding point pairs
F_matrix = estimate_fundamental_matrix(Points_2D_pic_a, Points_2D_pic_b);

%% Draw the epipolar lines on the images
draw_epipolar_lines(F_matrix,ImgLeft,ImgRight,Points_2D_pic_a,Points_2D_pic_b);

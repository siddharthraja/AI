% Camera Calibration Stencil Code
% by Henry Hu, Grady Williams, James Hays


clear
close all

formatSpec = '%f';
size2d_norm = [2 Inf];
size3d_norm = [3 Inf];

file_2d_pic_b = fopen('../data/pts2d-pic_b.txt','r');
file_3d = fopen('../data/pts3d.txt','r');
Points_2D = fscanf(file_2d_pic_b,formatSpec,size2d_norm)';
Points_3D = fscanf(file_3d,formatSpec,size3d_norm)';


%% Calculate the projection matrix given corresponding 2D and 3D points
M = calculate_projection_matrix(Points_2D,Points_3D);

disp('The projection matrix is:')
disp(M);

[Projected_2D_Pts, Residual] = evaluate_points( M, Points_2D, Points_3D);
fprintf('\nThe total residual is: <%.4f>\n\n',Residual);

visualize_points(Points_2D,Projected_2D_Pts);

%% Calculate the camera center using the M found from previous step
Center = compute_camera_center(M);

fprintf('The estimated location of camera is: <%.4f, %.4f, %.4f>\n',Center);
plot3dview(Points_3D, Center)







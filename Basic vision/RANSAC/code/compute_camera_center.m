% Camera Center Stencil Code
% By Siddhrth
% Returns the camera center matrix for a given projection matrix

% 'M' is the 3x4 projection matrix
% 'Center' is the 1x3 matrix of camera center location in world coordinates

function [ Center ] = compute_camera_center( M )

%%%%%%%%%%%%%%%%
% Your code here
%%%%%%%%%%%%%%%%
Q = M(:,1:3);
m4 = M(:,4);
Center = -inv(Q)*m4; 

end


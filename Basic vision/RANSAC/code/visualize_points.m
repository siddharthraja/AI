% Plot Points Stencil Code
function [] = visualize_points( Actual_Pts, Project_Pts)
    figure(11)
    plot(Actual_Pts(:,1),Actual_Pts(:,2),'ro');
    hold on
    plot(Project_Pts(:,1),Project_Pts(:,2),'+');
    legend('Actual Points','Projected Points');
    hold off
end


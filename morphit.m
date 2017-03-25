%%%%%%%%%%%%%%%%%%%%%
%% Shayan Fazeli   %%
%% 91102171        %%
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function frame = morphit(im1, im2, im1_points, im2_points,...
                         triangulation, fraction);
%first we have to compute the state we are in.
%this state corresponds the frame we are working on:

state_points = (1-fraction) * (im1_points) + (fraction) * (im2_points);

%how many triangles are there in the picture?
number_of_triangles = size(triangulation, 1);

%now, in order to use affine to transform triangle by triangle,
%we need to know the transform that maps each:
affines1 = zeros(3, 3, number_of_triangles);
affines2 = zeros(3, 3, number_of_triangles);

%now filling the above sets, the target is that
%we find an affine transformation for each triangle that we have:
for t_indice = 1:number_of_triangles
    T1 = fitgeotrans(im1_points(triangulation(t_indice,:),:),...
                     state_points(triangulation(t_indice,:),:),'Affine');
    T2 = fitgeotrans(im2_points(triangulation(t_indice,:),:),...
                     state_points(triangulation(t_indice,:),:),'Affine');
   %using those transformation objects to fill our affines array:
   affines1(:,:,t_indice) = T1.T';
   affines2(:,:,t_indice) = T2.T';
end

%now warping:
changed1 = changer(im1, affines1, triangulation);
changed2 = changer(im2, affines2, triangulation);

%outputing the frame:
frame = uint8((1-fraction)*double(changed1)+fraction*double(changed2));

%THE END
















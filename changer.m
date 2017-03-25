%%%%%%%%%%%%%%%%%%%%%
%% Shayan Fazeli   %%
%% 91102171        %%
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%to apply the changes this function is a help:
function changed = changer(im, affine, triangulation)

%first we need to know how many triangles do we have:
number_of_triangles = size(triangulation,1);

%we have to work with all the layers, so first, we get them out:
R = im(:,:,1);
G = im(:,:,2);
B = im(:,:,3);
%the final one, is going to be a transformed version of the input, so
%first we assign them to a copied version of that:
targetR = R;
targetG = G;
targetB = B;

%we need "all" the indices, in order to get them, we use
%find function. as we know, find function returns the
%non-zero elements indices, so by using "ones", we can get them all:
[rows, cols] = find(ones(size(im,1),size(im,2)));

%what triangle is where?
T = pointLocation(triangulation, cols, rows);
%receiving the indices:
indices = ~isnan(T);
%again the triangles:
triangles = T(indices);
%and the columns and rows, the valid ones:
columns = cols(indices);
rows = rows(indices);

%now for each triangle...
for triangle = 1:number_of_triangles
    %first, the transform for that triangle must be known:
    transform = affine(:,:,triangle);
    %the indices corresponding to that triangle
    %indicate where we should work on:
    t_indices = find(triangles==triangle);
    %number of the indices corresponding to this triangle:
    num_of_ts = length(t_indices);
    
    %barycentric coordinate system:
    b_coordinates = [columns(t_indices)'; rows(t_indices)'; ones(1, num_of_ts)];
    %from where?
    first = floor(pinv(transform)*b_coordinates);
    
    %checking the boundaries:
    valids = (first(1,:) > 0 & first(1,:) <= size(im,2) & first(2,:) >0 & first(2,:)<=size(im,2));
    first=first(:,valids);
    b_coordinates=b_coordinates(:,valids);
    
    %computing the indices:
    destination_indices = round(sub2ind([size(im,1), size(im,2)], b_coordinates(2,:), b_coordinates(1,:)));
    source_indices = round(sub2ind([size(im,1), size(im,2)], first(2,:), first(1,:)));
    
    %assiging the target:
    targetR(destination_indices)=R(source_indices);
    targetG(destination_indices)=G(source_indices);
    targetB(destination_indices)=B(source_indices);
end
%outputting the changed frame and that's it:
changed = cat(3, targetR, cat(3, targetG, targetB));

end

%THE END
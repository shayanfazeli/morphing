%%%%%%%%%%%%%%%%%%%%%
%% Shayan Fazeli   %%
%% 91102171        %%
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%preparing the script:
clear all;
clc;

%reading the images:
im1 = imread('man1.jpg');
im2 = imread('man2.jpg');

%extracting their sizes for further usage:
[height1, width1, depth1] = size(im1);
[height2, width2, depth2] = size(im2);

%resizing them to get two same sized images:
im1 = imresize(im1, [max(height1,height2), max(width1, width2)]);
im2 = imresize(im2, [max(height1,height2), max(width1, width2)]);

%now again computing the dimensions:
[height, width, depth] = size(im1);

%now we have to prompt the user to get us some points
%we can use for our triangulation process. best thing
%to use for this purpose would be the "cpselect":
disp('After selecting your points, just close the window.');
[im1_points, im2_points] = cpselect(im1, im2, 'Wait', true);

%adding the corner points:
im1_points = [im1_points; 1, 1; height,1; 1,width; height,width];
im2_points = [im2_points; 1, 1; height,1; 1,width; height,width];

%now we have the points, it's time to get started on this:

%computing the mean poitns:
mean_points = (im1_points + im2_points)/(2.0);

%performing delaunay algorithm and get the triangulation of the mean
%points.
triangulation = delaunayTriangulation(mean_points);

%plotting the triangulations:
subplot(1,2,1);
imshow(im1);
hold on;
triplot(triangulation);
hold off;
subplot(1,2,2);
imshow(im2);
hold on;
triplot(triangulation);
hold off;
disp('the script is paused.');
pause;
close all;

%going in for the computation:
%opening a video file and get ready to write frames in:
out = VideoWriter('result');
open(out);
%assign the number of frames:
number_of_frames = 50;
%assigning a waitbar to our for:
prcnt = 0;
h=waitbar(prcnt, 'Initializing...');
%now step by step we change it from image 1 to image 2:
for frame = 1:number_of_frames
    %updating the waitbar:
    if mod(frame,number_of_frames/5)==1
        prcnt = (frame)/(number_of_frames);
        waitbar(prcnt, h, sprintf('Please wait... \n%d%%',floor(100*prcnt) ));
    end
    %compute the fraction. the fraction is going to tell us
    %what portion of the final image is going to be derived from image 1
    %and what portion will be related to image 2. in fact it leaves us
    %with some sort of weighed averaging.
    fraction = frame / number_of_frames;
    %now passing the whole thing to another function, 
    %receiving the frame from it.
    morphed_image = morphit(im1, im2, im1_points, im2_points,...
                            triangulation, fraction);
    
    %now writing the derived frame down to the video file we opened:
    writeVideo(out, morphed_image);
    if frame == 25
       imwrite(morphed_image, 'hw6_q1.jpg');
    end
end
%closing up the waitbar indicating that the procedure is completed:
waitbar(1, h, sprintf('DONE. \n%d%%',floor(100) ));
close(h);
%closing the video file:
close(out);

%THE END

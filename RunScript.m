%SourceDir = '/media/Windows7/Users/Colin/Documents/MATLAB/Mosaic/Images/random-imgur-downloader/originals'
%ThumbnailDir = '/media/Windows7/Users/Colin/Documents/MATLAB/Mosaic/Images/random-imgur-downloader/thumbs'
%InputImage = '/media/Windows7/Users/Colin/Documents/MATLAB/Mosaic/Images/random-imgur-downloader/InputImage/gTuNy.jpg'
SourceDir = '/home/colin/Mosaic/InputImages/Images'
ThumbnailDir = '/home/colin/Mosaic/InputImages/Thumbnails'
InputImage = '/home/colin/Mosaic/InputImages/OriginalImage/IMG_1893.JPG'
%InputImage = '/home/colin/Mosaic/InputImages/OriginalImage/Lambeau_Field.jpg'

pkg load geometry

bMakeFourComparisonPlot = false;
bShowImageAsItIsBeingCreated = false;
bRotateInputImage = true;
bShowVerboseLogging = false;

ImageSize = [50, 50];

ThumbnailSizeFile = strcat(ThumbnailDir, '/.size');
try
  SizeData = csvread(ThumbnailSizeFile);
  if ((SizeData(1) ~= ImageSize(1)) || 
      (SizeData(2) ~= ImageSize(2)))
    ResizeImages(SourceDir, ThumbnailDir, ImageSize)
  endif
catch
  ResizeImages(SourceDir, ThumbnailDir, ImageSize)
end_try_catch


NumberOfBinsToMatch = 256; % NES resolution
%NumberOfBinsToMatch = 512; % NES resolution
%NumberOfBinsToMatch = 1024; % NES resolution

Bins = CreateColorBins(NumberOfBinsToMatch, true) / 256;
%Bins = CreateColorBins(NumberOfBinsToMatch) / 256;
%HSVBins = rgb2hsv(Bins);

% Now get a list of the file names and the nearest swatches
%[FileNames, NearestSwatch] = SortImages(ThumbnailDir, HSVBins)
[FileNames, NearestSwatch] = SortImages(ThumbnailDir, Bins);

% Plot the distribution of the swatches
figure(6)
hist(NearestSwatch, range(NearestSwatch))
xlabel('Swatch Number')
ylabel('NumImages')
title('Number of images in each swatch')

% Get a matrix of closest color swatches, to look for replacements
%ColorSwatchDistances = DetermineColorSwatchMatrix(HSVBins)
ColorSwatchDistances = DetermineColorSwatchMatrix(Bins);

%Load the key image
ImageToCopy = imread(InputImage);
if bRotateInputImage
  ImageToCopy = imrotate(ImageToCopy, 270);
endif

% Create a dummy image where everything will be copied
NewImage = uint8(zeros(size(ImageToCopy, 1), size(ImageToCopy, 2), 3));
NewImage = imresize(NewImage, 2)

% Allocate space for the sample image
ImageSample = zeros(ImageSize(1), ImageSize(2));

ones_image = ones(ImageSize(1), ImageSize(2));

figure(1)
imshow(ImageToCopy)

xStep = ImageSize(1);
yStep = ImageSize(2);

% Loop through each section
parfor xImageCounter = 1:xStep:size(ImageToCopy, 1)
  xImageCounter
  parfor yImageCounter = 1:yStep:size(ImageToCopy, 2)
    yImageCounter;

    if xImageCounter + xStep > size(NewImage, 1)
      XSize = size(NewImage, 1) - xImageCounter + 1;
    else
      XSize = xStep;
    endif

    if yImageCounter + yStep > size(NewImage, 2)
      YSize = size(NewImage, 2) - yImageCounter;
    else
      YSize = yStep;
    endif

    ImageSample = ImageToCopy(xImageCounter: xImageCounter + XSize - 1, yImageCounter: yImageCounter + YSize - 1, :);
    %ImageSampleSwatch = DetermineClosestColorSwatch(ImageSample, HSVBins)
    ImageSampleSwatch = DetermineClosestColorSwatch(double(ImageSample) / 255, Bins);

    if bMakeFourComparisonPlot
    % Plot the sample I'm comparing to
    figure(3)
    subplot(2,2,1)
    imshow(ImageSample)
    title('Original Image')

    % Plot an image of the swatch I'm assuming is the best
    %SampleSwatchRGB = uint8(hsv2rgb(HSVBins(ImageSampleSwatch,:)) * 255);
    %SampleSwatchRGB = uint8(hsv2rgb(Bins(ImageSampleSwatch,:)) * 255);
    SampleSwatchRGB = (Bins(ImageSampleSwatch,:));
    R = SampleSwatchRGB(1) * ones_image;
    G = SampleSwatchRGB(2) * ones_image;
    B = SampleSwatchRGB(3) * ones_image;
    SampleSwatchImage(:,:,1) = R;    
    SampleSwatchImage(:,:,2) = G;    
    SampleSwatchImage(:,:,3) = B;    
    subplot(2,2,2)
    imshow(SampleSwatchImage)
    %imshow(SampleSwatchRGB)
    title('Best fit swatch')
    endif

    % Loop through each color swatch, best to worst, to determine the best image
    bKeepGoing = true;
    [S, I] = sort(ColorSwatchDistances(:,ImageSampleSwatch));
    ClosestLoopIndex = 0;
    while bKeepGoing
      ClosestLoopIndex = ClosestLoopIndex + 1
      % Determine which, if any, thumbnails are in the current swatch
      MatchingIndices = find(NearestSwatch == I(ClosestLoopIndex));
      % Check if we found one
      if length(MatchingIndices) > 0
        MatchingImage = MatchingIndices(randperm(length(MatchingIndices)))(1);
        ThumbName = FileNames{MatchingImage};
        NewThumb = imread(ThumbName);

        if size(NewThumb,3) == 1
          NewThumb(:,:,2) = NewThumb(:,:,1);
          NewThumb(:,:,3) = NewThumb(:,:,1);
        endif

        NewThumb = resize(NewThumb, XSize, YSize, size(NewThumb, 3));

        %{
        if xImageCounter + xStep > size(NewImage, 1)
          NewThumb = resize(NewThumb, size(NewImage, 1) - xImageCounter, size(NewThumb, 2), size(NewThumb, 3))
        endif

        if yImageCounter + yStep > size(NewImage, 2)
          NewThumb = resize(NewThumb, size(NewThumb, 1), size(NewImage, 2) - yImageCounter, size(NewThumb, 3))
        endif
        %}

        NewImage(xImageCounter: xImageCounter + XSize - 1, yImageCounter: yImageCounter + YSize - 1, :) = NewThumb;

        if bMakeFourComparisonPlot
        
        figure(3)
        subplot(2,2,3)
        imshow(NewThumb)
        title('Matched Image')

        % Plot an image of the swatch I'm assuming is the best
        %SampleSwatchRGB = uint8(hsv2rgb(HSVBins(MatchingIndices(MatchingImage),:)) * 255)
        %SampleSwatchRGB = uint8(hsv2rgb(HSVBins(NearestSwatch(MatchingImage), :)) * 255)
        %SampleSwatchRGB = uint8(hsv2rgb(Bins(NearestSwatch(MatchingImage), :)) * 255)
        SampleSwatchRGB = Bins(NearestSwatch(MatchingImage), :)
        R = SampleSwatchRGB(1) * ones_image;
        G = SampleSwatchRGB(2) * ones_image;
        B = SampleSwatchRGB(3) * ones_image;
        SampleSwatchImage(:,:,1) = R;    
        SampleSwatchImage(:,:,2) = G;    
        SampleSwatchImage(:,:,3) = B;    
        figure(3)
        subplot(2,2,4)
        imshow(SampleSwatchImage)
        title('Best matched swatch')
        endif

        if bShowImageAsItIsBeingCreated 
        figure(2)
        imshow(NewImage)
        endif

        if bShowImageAsItIsBeingCreated || bMakeFourComparisonPlot
          drawnow()
        endif

        bKeepGoing = false;
      elseif ClosestLoopIndex == size(I, 1)
        bKeepGoing = false;
      endif
    endwhile
  endparfor
endparfor

figure(2)
imshow(NewImage)


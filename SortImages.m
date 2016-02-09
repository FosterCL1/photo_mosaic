function [Name, swatch] = SortImages(InputDir, Bins, varargin)

pkg load image

PlotNum = -1
if nargin == 3
  if varargin{1} == 4
    PlotNum = 4
  endif
endif

OutputSize = [15,15];

file_list = ls(InputDir);

RGB2XYZ = [0.5767309  0.1855540  0.1881852
 0.2973769  0.6273491  0.0752741
 0.0270343  0.0706872  0.9911085];

% Pre allocate the memory for speed
Name = cell(size(file_list, 1), 1);
%RGB = zeros(size(file_list, 1), 3);
NumImages = 0
swatch = [];

for file_counter = 1:size(file_list, 1)
  if (file_list(file_counter, 1) ~= '.')

    CurrentName = strcat(InputDir, '/', file_list(file_counter,:))
    %sprintf('Reading file %s\n', strcat(InputDir, file_list(file_counter,:)))
    sprintf('Reading file (%d of %d) %s\n', file_counter, size(file_list, 1), CurrentName)

    %Image = imread(strcat(InputDir, '/', file_list(file_counter, :)));
    Image = imread(CurrentName);

    if size(Image, 3) == 1
      % Make the image RGB
      temp = zeros(size(Image, 1), size(Image, 2), 3);
      temp(:,:,1) = Image;
      temp(:,:,2) = Image;
      temp(:,:,3) = Image;
      Image = temp;
    endif

    NumImages++;
    Name{NumImages} = CurrentName;
    if PlotNum > 0
      BestSwatch = DetermineClosestColorSwatch(Image, Bins, PlotNum)
    else
      BestSwatch = DetermineClosestColorSwatch(Image, Bins)
    endif
    swatch = [swatch; BestSwatch];
  endif
endfor
endfunction

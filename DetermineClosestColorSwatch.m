%function swatch = DetermineClosestColorSwatch(InputImage, InputHSV)
function swatch = DetermineClosestColorSwatch(InputImage, InputRGB, varargin)

NumXPixels = size(InputImage, 1);
NumYPixels = size(InputImage, 2);
NumColorSwatches = size(InputRGB, 1);

bShowImage = false;
if nargin > 2
  if varargin{1} > 0
  bShowImage = true;
  FigNum = varargin{1};
  endif
endif

if size(InputImage, 3) == 1
  sprintf('Changing image to RGB from B&W');
  InputImage(:,:,2) = InputImage(:,:,1);
  InputImage(:,:,3) = InputImage(:,:,1);
endif

if strcmp(typeinfo(InputImage(1,1,1)), 'scalar')
  % Do nothing, we're all good!
else
  InputImage = double(InputImage) / 255;
endif

%ClosestCount = zeros(size(InputHSV, 1), 1);
ClosestCount = zeros(NumColorSwatches, 1);
% Find the nearest color bin of each pixel

% New matrix method
%if (NumXPixels * NumYPixels * NumColorSwatches) < 2e9

%keyboard
ImageArray = [InputImage(:,:,1)(:), InputImage(:,:,2)(:), InputImage(:,:,3)(:)];

[dummy, ClosestSwatches] = minDistancePoints(ImageArray, InputRGB);
ClosestCount(min(ClosestSwatches):(max(ClosestSwatches))) = hist(ClosestSwatches, range(ClosestSwatches) + 1)(:);
%for SwatchCounter = 1:NumColorSwatches
%
%  Differences = ImageArray - InputRGB(SwatchCounter,:);
%  DifferenceMatrix = Differences * Differences';
%
%endfor

%DistanceMatrix = ImageArray * InputRGB';


% Old loop method
%else
if 0
for xpixel = 1:NumXPixels
  for ypixel = 1:NumYPixels
  %{
    if strcmp(typeinfo(InputImage(1,1,1)), 'scalar')
      %sprintf('Input was a double')
        rgbpixel = squeeze(InputImage(xpixel, ypixel, :));
    else
      %sprintf('Input was a uint8')
        rgbpixel = double(squeeze(InputImage(xpixel, ypixel, :))) / 255;
    endif
  %}
    rgbpixel = squeeze(InputImage(xpixel, ypixel, :));

    %hsvpixel = rgb2hsv(rgbpixel');
    minDistance = inf
    %for hsvcounter = 1:size(InputHSV,1)
    for hsvcounter = 1:NumColorSwatches
      %difference = InputHSV(hsvcounter) - hsvpixel;
      difference = InputRGB(hsvcounter,:) - rgbpixel';
      %current_distance = sqrt(difference * difference');
      current_distance = difference * difference';
      if current_distance < minDistance
      ClosestPoint = hsvcounter;
      minDistance = current_distance;
      endif
    endfor
  ClosestCount(ClosestPoint) += 1;
  endfor
endfor
endif

BestSwatch = find(ClosestCount == max(ClosestCount));
swatch = BestSwatch(1);

if bShowImage
  figure(FigNum)
  subplot(1,2,1)
  imshow (InputImage)
  title('Original')
  subplot(1,2,2)
  SwatchImage = ones(size(InputImage,1), size(InputImage,2), 3);
  SwatchImage(:,:,1) = SwatchImage(:,:,1) * InputRGB(BestSwatch(1), 1);
  SwatchImage(:,:,2) = SwatchImage(:,:,2) * InputRGB(BestSwatch(1), 2);
  SwatchImage(:,:,3) = SwatchImage(:,:,3) * InputRGB(BestSwatch(1), 3);
  imshow(SwatchImage)
  title('Matched')
  drawnow()
endif
endfunction


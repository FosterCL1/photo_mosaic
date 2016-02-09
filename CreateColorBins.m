function rval = CreateColorBins(NumColorBins, varargin)

show_bins = false;

if nargin > 1
  if (varargin{1})
    show_bins = true;
  endif
endif

step = 256 / (NumColorBins ^ (1/3));

rval = [];
for Red = 0:step:255
  for Green = 0:step:255
    for Blue = 0:step:255
      rval = [rval;[Red, Green, Blue]];
    endfor
  endfor
endfor

if (show_bins)
  figure
  % The value will be a perfect cube, so:
  imshow(reshape(rval / 256, [round(size(rval, 1) ^ (2/3)), round(size(rval, 1) ^ (1/3)), 3]))
endif


endfunction

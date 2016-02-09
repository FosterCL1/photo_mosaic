function ResizeImages(InputDir, OutputDir, OutputSize)

pkg load image

%OutputSize = [25,25];

file_list = ls(InputDir);

parfor file_counter = 1:size(file_list, 1)
  if (file_list(file_counter, 1) ~= '.')

    sprintf('Reading file (%d of %d) %s\n', file_counter, size(file_list, 1), strcat(InputDir, '/', file_list(file_counter,:)))

    try
      Image = imread(strcat(InputDir, '/', file_list(file_counter, :)));
    
      NewImage = imresize(Image, OutputSize);

      imwrite(NewImage, strcat(OutputDir, '/', file_list(file_counter, :)));
    catch
      sprintf('Image resize failed for %s\n', strcat(InputDir, '/', file_list(file_counter,:)))
    end_try_catch

  endif
endparfor

SizeFile = strcat(OutputDir, '/.size');
csvwrite(SizeFile, OutputSize)

endfunction 

function M = DetermineColorSwatchMatrix(Bins)

M = zeros(size(Bins,1));

for xCounter = 1 : size(Bins, 1)
  for yCounter = xCounter : size(Bins, 1)
    PointA = Bins(xCounter, :);
    PointB = Bins(yCounter, :);
    M(xCounter, yCounter) = GetDistanceBetweenTwoColors(PointA, PointB);
  endfor
endfor

M = M + M';

endfunction

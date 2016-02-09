function Distance=GetDistanceBetweenTwoColors(ColorA, ColorB)
Difference = ColorA - ColorB;
Distance = Difference * Difference';
end

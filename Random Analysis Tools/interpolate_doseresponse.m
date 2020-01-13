function y = interpolate_doseresponse(x,bottom,top,logEC50,hillslope)

% Use this script to find intermediate data points in dose response curve
% that may not have been collected during experiment

% x=log10(conc)

y = bottom + (top-bottom)/(1+10^((logEC50-x)*hillslope));
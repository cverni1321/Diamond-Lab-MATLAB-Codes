function [o,v]=nanstd2(i,opt,DIM)
% STD calculates the standard deviation.
% 
% [y,v] = std(x [, opt[, DIM]])
% 
% opt   option 
%	0:  normalizes with N-1 [default]
%		provides the square root of best unbiased estimator of the variance
%	1:  normalizes with N, 
%		this provides the square root of the second moment around the mean
% 	otherwise: 
%               best unbiased estimator of the standard deviation (see [1])      
%
% DIM	dimension
% 	N STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% y	estimated standard deviation
%
% features:
% - provides an unbiased estimation of the S.D. 
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: RMS, SUMSKIPNAN, MEAN, VAR, MEANSQ,
%
%
% References(s):
% [1] http://mathworld.wolfram.com/StandardDeviationDistribution.html


%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%	$Revision: 1.10 $
%	$Id: std.m,v 1.10 2003/09/26 07:42:22 schloegl Exp $
%	Copyright (c) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	


if nargin>2
        [s,n,y] = sumskipnan(i,DIM);
else
        [s,n,y] = sumskipnan(i);
        if nargin<2,
                opt = 0;
        end;
end;

y = (y - (real(s).^2+imag(s).^2)./n);   % n * (summed squares with removed mean)

if opt==0, 
        % square root if the best unbiased estimator of the variance 
        ib = inf;
        o  = sqrt(y./max(n-1,0));	% normalize
        
elseif opt==1, 
	ib = NaN;        
        o  = sqrt(y./n);
else
        % best unbiased estimator of the mean
        if exist('unique')==2, 
		% usually only a few n's differ
                [N,tmp,tix] = unique(n(:));	% compress n and calculate ib(n)
        	ib = sqrt(N/2).*gamma((N-1)./2)./gamma(N./2);	%inverse b(n) [1]
	        ib = ib(reshape(tix,size(y)));	% expand ib to correct size
                
        elseif exist('histo3')==2, 
		% usually only a few n's differ
                [N,tix] = histo3(n(:)); N = N.X;
                ib = sqrt(N/2).*gamma((N-1)./2)./gamma(N./2);	%inverse b(n) [1]
	        ib = ib(reshape(tix,size(y)));	% expand ib to correct size
                
        else	% gamma is called prod(size(n)) times 
                ib = sqrt(n/2).*gamma((n-1)./2)./gamma(n./2);	%inverse b(n) [1]
        end;	
        o  = sqrt(y./n).*ib;
end;

if nargout>1,
	v = y.*((max(n-1,0)./(n.*n))-1./(n.*ib.*ib)); % variance of the estimated S.D. ??? needs further checks
end;
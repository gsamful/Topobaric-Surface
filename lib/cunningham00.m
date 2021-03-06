function gsf = cunningham00(s, t, x, X, M, Y, x0, varargin)
%CUNNINGHAM00  The Cunningham (2000) geostrophic stream function.
%
%
% gsf = cunningham00(s, t, p, P, A, Y, p0)
% computes the Cunningham (2000) geostrophic stream function gsf, using the
% expression given by McDougall and Klocker (2010), on a surface with
% practical / Absolute salinity, potential / Conservative temperature, and
% pressure given by s, t, and p respectively, and with reference value for
% p given by p0, in an ocean with pressure P, specific volume A, and
% hydrostatic acceleration potential Y, and with equation of state for the
% specific volume given by eos.m in the path. The specific volume should be
% calculated by A = eos(S, T, P) where S is the practical / Absolute
% salinity and T is the potential / Conservative temperature at the data
% sites of P. The hydrostatic acceleration potential should be calculated
% as Y = hsap3(P, ATMP, ETAN, A, grav), where ATMP is the atmospheric
% pressure, ETAN is the sea-surface height, and grav the gravitational
% acceleration. If p0 is empty, it is taken as the mean of p. Inputs s and
% t may instead be S and T, in which case s and t is determined by linear
% interpolation of S and T through P onto p.
%
% gsf = cunningham00(s, t, z, Z, R, Y, z0, grav, rho_c)
% computes the Cunningham (2000) geostrophic stream function gsf, using the
% expression given by McDougall and Klocker (2010), on a surface with
% practical / Absolute salinity, potential / Conservative temperature, and
% depth given by s, t, and z respectively, and with reference value for z
% given by z0, in a Boussinesq ocean with in-situ density R and hydrostatic
% acceleration potential Y given at depths Z, with gravitational
% acceleration grav and Boussinesq reference density rho_c, and with
% equation of state for the in-situ density given by eos.m in the path. The
% in-situ density should be calculated by R = eos(S, T, Z
% * 1e-4 * grav * rho_c) where S is the practical / Absolute salinity and T
% is the potential / Conservative temperature at the depths Z. The
% hydrostatic acceleration potential should be calculated as Y =
% hsap3(Z, ATMP, ETAN, R, grav, rho_c), where ATMP is the atmospheric
% pressure and ETAN is the sea-surface height. If z0 is empty, it is taken
% as the mean of z. Inputs s and t may instead be S and T, in which case s
% and t is determined by linear interpolation of S and T through Z onto z.
% Note z and Z must be positive and increase downwards.
%
%
% --- Input:
% s [nx, ny] or [nz, nx, ny]: the practical / Absolute salinity, 
%  on the surface, or at all data sites
% t [nx, ny] or [nz, nx, ny]: the potential / Conservative temperature
%  on the surface, or at all data sites
% p [nx, ny]: pressure on surface [dbar]
% z [nx, ny]: depth on surface [m, positive]
% P [nz, nx, ny] or [nz, 1]: pressure at all data sites [dbar]
% Z [nz, nx, ny] or [nz, 1]: depth at all data sites [m, positive]
% A [nz, nx, ny]: specific volume [m^3 kg^-1]
% R [nz, nx, ny]: in-situ density [kg m^-3]
% Y [nz, nx, ny]: acceleration potential from hydrostatic balance [m^2 s^-2]
% p0 [1, 1] or []: reference p value
% z0 [1, 1] or []: reference z value
% grav [1, 1]: gravitational acceleration [m s^-2]
% rho_c [1, 1]: Boussinesq reference density [kg m^-3]
%
% Note: nz is the maximum number of data points per water column,
%       nx is the number of data points in longitude,
%       ny is the number of data points in latitude.
%
% Note: physical units for s and t are determined by eos.m.
%
%
% --- Output:
% gsf [nx, ny]: geostrophic stream function [m^2 s^-2]
%
%
% --- Requirements:
% hsap2
% interp1qn2 - https://www.mathworks.com/matlabcentral/fileexchange/69713
%
%
% --- References:
% Cunningham, S. A. Circulation and volume flux of the North Atlantic using
% synoptic hydrographic data in a Bernoulli inverse. Journal of marine
% research 58, 1?35 (2000).
%
% McDougall, T. J. & Klocker, A. An approximate geostrophic streamfunction
% for use in density surfaces. Ocean Modelling 32, 105?117 (2010).

% --- Copyright:
% Copyright 2019 Geoff Stanley
%
% This file is part of Topobaric Surface.
% 
% Topobaric Surface is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published
% by the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% Topobaric Surface is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with Topobaric Surface.  If not, see
% <https://www.gnu.org/licenses/>.
%
% Author(s) : Geoff Stanley
% Email     : g.stanley@unsw.edu.au 
% Email     : geoffstanley@gmail.com
% Version   : 1.0
%
% Modified by : --
% Date        : --
% Changes     : --


% Input checking
narginchk(7,9);

[nx,ny] = size(x);
nz = size(X,1);
is3D = @(F) ndims(F) == 3 && all(size(F) == [nz,nx,ny]);
lead1 = @(x) reshape(x, [1 size(x)]);


if is3D(s) % Interpolate 3D s and t onto the surface
    try
        [s,t] = interp1qn2_mex(lead1(x), X, s, t);
    catch
        [s,t] = interp1qn2(lead1(x), X, s, t);
    end
end

% If x0 not provided, use the mean
if isempty(x0)
    x0 = nanmean(x(:));
end

% See McDougall and Klocker (2010) for this formulation of the Cunningham
% (2000) stream function. The non-Boussinesq version is 
%\int \nu(S(p'),T(p'),p') dp' - \int  \nu(s,t,p') dp'


% Calculate the easy terms involving integrals of hydrostatic balance:
y  = hsap2(s, t, x, X, M, Y, varargin{:});
y0 = hsap2(s, t, x, x0, X,   varargin{:});


% Calculate the geostrophic stream function
gsf = y - y0;

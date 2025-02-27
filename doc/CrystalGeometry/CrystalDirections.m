%% Miller Indices
%
% Miller indices are used to describe directions with respect to the
% crystal reference system.
%
%% Crystal Lattice Directions
%
% Since lattice directions are always subject to a certain crystal
% reference frame, the starting point for any crystal direction is the
% definition of a variable of type <crystalSymmetry.crystalSymmetry.html
% crystalSymmetry>

cs = crystalSymmetry('triclinic',[5.29,9.18,9.42],[90.4,98.9,90.1]*degree,...
  'X||a*','Z||c','mineral','Talc');

%%
% The variable |cs| containes the geometry of the crystal reference frame
% and, in particular, the alignment of the crystallographic a,b, and, c axis.

a = cs.aAxis
b = cs.bAxis
c = cs.cAxis

%%
% A lattice direction |m = u * a + v * b + w * c| is a vector with
% coordinates u, v, w with respect to these crystallographic axes. Such a
% direction is commonly denoted by [uvw] with coordinates u, v, w called
% Miller indices. In MTEX a lattice direction is represented by a variable
% of type <Miller.Miller.html Miller> which is defined by

m = Miller(1,0,1,cs,'uvw')

%%
% for values |u = 1|, |v = 0|, and, |w = 1|. To plot a crystal direction as
% a <SphericalProjections.html spherical projections> do

plot(m,'upper','labeled','grid')

%% Crystal Lattice Planes
%
% A crystal lattice plane (hkl) is commonly described by its normal vector
% |n = h * a* + k * b* + l * c*| where a*, b*, c* describes the reciprocal
% crystal coordinate system. In MTEX a lattice plane is defined by

m = Miller(1,0,1,cs,'hkl')

%%
% By default lattice planes are plotted as normal directions. Using the
% option |plane| we may alternatively plot the trace of the lattice plane
% with the sphere.

hold on
% the normal direction
plot(m,'upper','labeled')

% the trace of the corresponding lattice plane
plot(m,'plane','linecolor','r','linewidth',2)
hold off

%%
% Note that for non Euclidean crystal frames uvw and hkl notations usually
% lead to different directions.
%s
%% Trigonal and Hexagonal Convention
%
% In the case of trigonal and hexagonal crystal symmetry often four digit
% Miller indices [UVTW] and (HKIL) are used, as they make it more easy to
% identify symmetrically equivalent directions. This notation is redundant
% as the first three Miller indeces always sum up to zero, i.e., $U + V +
% T = 0$ and $H + K + I = 0$. The syntax is

% import trigonal Quartz lattice structure
cs = loadCIF('quartz')

% a four digit lattice direction
m = Miller(2,1,-3,1,cs,'UVTW')

plot(m,'upper','labeled')

n = Miller(1,1,-2,3,cs,'hkil')

hold on
plot(n,'upper','labeled')
hold off

drawNow(gcm,'figSize','normal')

%%
% In order to switch the output format, e.g. from UVTW to uvw do

m.dispStyle = 'uvw';
round(m)

%%
% or from reciprocal to direct coordinates

n.dispStyle = 'UVTW';
round(n)

%%
% Note, that this does not change the vector but only the display of the
% coefficients. Internally, all vectors are stored with respect to the
% cartesian coordinate system.
%
%% Visualizing ODFs
%
%%
% Let us first define some model ODFs to be plotted later on.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.2*unimodalODF(mod1) ...
  + 0.3*unimodalODF(mod2) ...
  + 0.5*fibreODF(Miller(0,0,1,cs),vector3d(1,0,0),'halfwidth',10*degree)

%odf = 0.2*unimodalODF(mod2)

%%
% and lets switch to the LaboTex colormap
setMTEXpref('defaultColorMap',LaboTeXColorMap);

% Plotting inverse pole figures is analogously to plotting pole figures
% with the only difference that you have to use the command
% <ODF.plotIPDF.html plotIPDF> and you to specify specimen directions and
% not crystal directions.

plotIPDF(odf,[xvector,zvector])

%%
% Imposing antipodal symmetry to the inverse pole figures halfes the
% fundamental region

plotIPDF(odf,[xvector,zvector],'antipodal')

%%
% By default MTEX always plots only the fundamental region with respect to
% the crystal symmetry. In order to plot the complete inverse pole figure
% you have to use the option *complete*.

plotIPDF(odf,[xvector,zvector],'complete','upper')

%%
% This illustrates also more clearly the effect of the antipodal symmetry

plotIPDF(odf,[xvector,zvector],'complete','antipodal','upper')

%%
% Finally, lets set back the default colormap.

setMTEXpref('defaultColorMap',WhiteJetColorMap);

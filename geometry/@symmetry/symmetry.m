classdef symmetry < rotation
%
% symmetry is an abstract class for crystal and specimen symmetries
%
% Derived Classes
%  @crystalSymmetry - 
%  @specimenSymmetry - 
%

  properties
    id = 1;     % point group id, compare to symList    
  end

  properties (Dependent = true)
    lattice     % type of crystal lattice
    pointGroup  % name of the point group
    isLaue      % is it a Laue group
    isProper    % does it contain only proper rotations
  end
  
  properties (Constant = true)
    
    pointGroups = pointGroupList % list of all point groups
    
  end

  % this is an abstract class
  methods (Abstract = true)
    display(s)
    dispLine(s)
  end
  
  methods
    
    function s = symmetry(varargin)
                
      % empty constructor
      if nargin == 0
        s.a = 1;
        s.b = 0;
        s.c = 0;
        s.d = 0;
        s.i = false;
        return; 
      end
      
      if check_option(varargin,'PointId')
        
        s.id = get_option(varargin,'PointId');
        
      elseif check_option(varargin,'LaueId')
      
        % -1 2/m mmm 4/m 4/mmm m-3 m-3m -3 -3m 6/m 6/mmm
        LaueGroups = [2,8,16,27,32,42,45,18,21,35,40];
        s.id = LaueGroups(get_option(varargin,'LaueId'));
              
      elseif check_option(varargin,'SpaceId')
        
        list = spaceGroups;
        ndx = nnz([list{:,1}] < get_option(varargin,'SpaceId'));
        if ndx>31, error('I''m sorry, I know only 230 space groups ...'); end
        s.id = findsymmetry(list(ndx+1,2));
        
      elseif isa(varargin{1},'quaternion')
        
        s.a = varargin{1}.a;
        s.b = varargin{1}.b;
        s.c = varargin{1}.c;
        s.d = varargin{1}.d;
        try s.i = varargin{1}.i;catch, end
        s.id = 0;
                
      else

        s.id = findsymmetry(varargin{1});
        
      end      
                                        
    end
    
    function l = get.lattice(cs)
      if cs.id>0
        l = symmetry.pointGroups(cs.id).lattice;
      else
        l = 'unknown';
      end
    end
    
    function pg = get.pointGroup(cs)
      if cs.id>0
        pg = symmetry.pointGroups(cs.id).Inter;
      else
        pg = 'unknown';
      end
    end
            
    function r = get.isLaue(cs)
      try
        r = cs.id == symmetry.pointGroups(cs.id).LaueId;
      catch % this is required for custom symmetries
        r = any(rotation(cs) == -rotation.id,'all'); 
      end
    end
    
    function r = isRotational(cs)      
      r = cs.id == symmetry.pointGroups(cs.id).properId;
    end
    
    function r = get.isProper(cs)
      r = ~any(cs.i(:));
    end
    
    function out = le(cs1,cs2)
      % check wheter cs1 is a sub group of cs2
      out = all(any(abs(dot_outer(cs1,cs2))>1-1e-6,2));
    end
    
    function out = ge(cs1,cs2)
      % check wheter cs2 is a sub group of cs1
      out = le(cs2,cs1);
    end
        
    function out = lt(cs1,cs2)
      % check wheter cs1 is a true sub group of cs2
      out = le(cs1,cs2) & ~le(cs2,cs1);
    end
    
    function out = gt(cs1,cs2)
      % check wheter cs2 is a true sub group of cs1
      out = lt(cs2,cs1);
    end
    
  end
      
end

% ---------------------------------------------------------------

function list = spaceGroups

list = { 1,    '1';
  2,   '-1';
  5,    '2';
  9,    'm';
  15,   '2/m';
  24,    '222';
  46,    'mm2';
  74,   'mmm';
  80,    '4';
  82,    '-4';
  88,   '4/m';
  98,    '422';
  110,    '4mm';
  122,   '-42m';
  142,    '4/mmm';
  146,    '3';
  148,   '-3';
  155,    '32';
  161,    '3m';
  167,   '-3m';
  173,    '6';
  174,    '-6';
  176,    '6/m';
  182,   '622';
  186,   '6mm';
  190,  '-6m2';
  194, '6/mmm';
  199,    '23';
  206,   'm-3';
  214,   '432';
  220,  '-43m';
  230,  'm-3m'};
end



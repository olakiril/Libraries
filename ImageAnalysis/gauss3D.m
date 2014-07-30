function G3 = gauss3D(sz_X, sz_Y, sz_Z, a, prec)

%   G3 = gauss3D(sz_X, sz_Y, sz_Z, a, prec)
%
%   returns a 3D-Gaussian window
%
%   a       --  proportional to each direction's reciprocal of the standard deviation
%               The width of the window is inversely related to the value of "a"
%                --> a larger "a" produces a more narrow window.
%               Default: a = [2.5 2.5 2.5]
%
%   prec    --  precision may be 'double' (default) or 'single'
%               'single' halves the RAM requirements and improves speed
%
%             ^
%      G1(r)  |            _7?\.
%             |           _'   ",       <--- 1D Gauss window
%             |          _'     ",
%             |          P       4
%             |         7         \     G1(r) = exp( -1/2 * a^2 * (r-r0)/R )
%             |        _'         ",
%             |        [           ]
%             |       7             \
%             |      ]'             "[
%             |     _'               ",
%             |    _'                 ",
%             |  _"                     '_
%            -|------------------------------->
%                            r0               r
%
%   We try to meme the functionality from gausswin(N, a) in 3D and use its
%   formula as basis.
%
%   Define the desired size of the output with sz_X, sz_Y and sz_Z.
%   If only one argument is given, G3 will be a cube.
%
%   Beware that the peak's center is at floor([ Y X Z ]./2) + 1

%   Michael Völker, 2010
%   michael.voelker@mr-bavaria.de

    % ==================================================================
    % input handling
    %
        if ~exist('sz_X', 'var') || isempty(sz_X), error('At least one argument, please'), end
        if ~exist('sz_Y', 'var') || isempty(sz_Y), sz_Y = sz_X          ; end
        if ~exist('sz_Z', 'var') || isempty(sz_Z), sz_Z = sz_Y          ; end
        if ~exist(   'a', 'var') || isempty(  a ),    a = 2.5           ; end
        if ~exist('prec', 'var') || isempty(prec), prec = 'double'      ; end
        if length(sz_X(:)) + length(sz_Y(:)) + length(sz_Z(:)) ~= 3
            error('Only scalar size statements are allowed.')
        end
        sz = [sz_X  sz_Y  sz_Z];
        if any(~isreal(sz)) || any(sz ~= floor(sz)) || any( sz <= 0 )
            error('Only positive integer sizes, please.')
        end
        if ( length(a(:)) ~= 1 && length(a(:)) ~= 3 ) || any(~isreal(a(:))) || any(a(:)<=0)
            error('"a" should be positive and either scalar or a vector with 3 elements.')
        end
        if length(a(:))==1,  a = a([1 1 1]);  end
        if length(prec(:))~=6 || any( prec ~= 'double' & prec ~='single' )
            error('Precision can be either ''double'' or ''single''.')
        end
    %
    % ==================================================================

    centerX = floor(sz_X/2) + 1;
    centerY = floor(sz_Y/2) + 1;
    centerZ = floor(sz_Z/2) + 1;

    % calc. all X,Y,Z with the dimensions that bsxfun() needs
    Y(:,1,1) = (1:sz_Y) - centerY;
    X(1,:,1) = (1:sz_X) - centerX;
    Z(1,1,:) = (1:sz_Z) - centerZ;

    R = [sz_X  sz_Y  sz_Z] ./ 2;    % used to normalize X, Y, Z

    % Do lots of calculations that are usually put inside exp() here,
    % because the individual arrays X,Y,Z are much smaller so speed is
    % higher.
    % (further calculations will use the precision chosen here)
    X = cast( a(1)*X./R(1)./sqrt(2), prec);
    Y = cast( a(2)*Y./R(2)./sqrt(2), prec);
    Z = cast( a(3)*Z./R(3)./sqrt(2), prec);


    % This is unreadable, but very efficient in terms of speed AND even
    % RAM usage. It first calculates -(x^2 + y^2 + z^2)
    % for every x-y-z combination, then it does the exp().
    G3 = exp( bsxfun( @minus, bsxfun(@minus, -X.^2, Y.^2), Z.^2) );


end         % of function

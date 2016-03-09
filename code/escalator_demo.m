% Initial cleanup
clear; close all; clc;

% Load the data:
load escalator_data % contains X (data), m and n (height and width)
X = double(X);

nFrames = size(X,2);
lambda  = 1e-2;

opts = [];
opts.stopCrit       = 4;
opts.printEvery     = 1;
opts.tol            = 1e-4;
opts.maxIts         = 100;
opts.errFcn{1}      = @(f,d,p) norm(p{1}+p{2}-X,'fro')/norm(X,'fro');
largescale      = false;

for inequality_constraints = 0:1

    if inequality_constraints
        % if we already have equality constraint solution,
        % it would make sense to "warm-start":
 % x0 = { LL_0, SS_0 };
        % but it's more fair to start all over:
        x0      = { X, zeros(size(X))   };
        z0      = [];
    else
        x0      = { X, zeros(size(X))   };
        z0      = [];
    end

    obj    = { prox_nuclear(1,largescale), prox_l1(lambda) };
    affine = { 1, 1, -X };

    mu = 1e-4;
    if inequality_constraints
        epsilon  = 0.5;
        dualProx = prox_l1(epsilon);
    else
        dualProx = proj_Rn;
    end

    tic
    % call the TFOCS solver:
    [x,out,optsOut] = tfocs_SCD( obj, affine, dualProx, mu, x0, z0, opts);
    toc

    % save the variables
    LL =x{1};
    SS =x{2};
    if ~inequality_constraints
        z0      = out.dual;
        LL_0    = LL;
        SS_0    = SS;
    end

end % end loop over "inequality_constriants" variable

mat  = @(x) reshape( x, m, n );
figure();
colormap( 'Gray' );
k = 1;
for k = 1:nFrames

    imagesc( [mat(X(:,k)), mat(LL_0(:,k)),  mat(SS_0(:,k)); ...
              mat(X(:,k)), mat(LL(:,k)),    mat(SS(:,k))  ] );

    axis off
    axis image

    drawnow;
    pause(.05);

    if k == round(nFrames/2)
        snapnow; % Take a single still snapshot for publishing the m file to html format
    end
end
function [Xs, ids, fnorms] = run_admm_sdps(XDATA, tol)

% This function runs nuclear norm minimization SDPs using ADMM adding
% information from XDATA by adding 1 constraint on X.
% We stop the iterations when X has become close
% enough to XDATA (within 'tol' in Froebennius norm).
%   INPUT
%       XDATA: data set
%       tol : tolerance (stopping condition)
%   OUTPUT
%       Xs: sequence of solutions to SDP
%       ids: pairs of indices (i,j)
%       fnorms:froebenius norm errors of X's


% Get size
[m,n] = size(XDATA);
N = m * n;

% Initialize optim variables for SDP (block matrices)
W1 = zeros(m,m);
W2= zeros(n,n);
x0 = [W1 XDATA; XDATA' W2];

% Initialize z and u
z0 = eye(m+n);
u0 = eye(m+n);

% ADMM parameter
rho = 1;
maxit =100;

% Objective function under ADMM form
fun = @(x, z)sdp_admm_fun(x, z);

% to store optimal solutions X's
Xs = {};

% to store Froebenius norm erros of X's
fnorms = [];

% Generate random indices (i,j) from [1,m]*[1,m] without repetition
ids = [];
while size(ids,1) ~= N
    ids = unique([ids; ceil(m*rand), ceil(n*rand)], "row");
end
% Shuffle indices
ids = ids(randperm(size(ids,1)),:);

% Nb of constraints = nb of iterations
n_iters = 1;

% While there are still constraints to add
while n_iters <= N
    
    % Select a subset of specified entries to send to the current SDP
    sub_ids = ids(1:n_iters,:);
    [~, ~, x_all, ~, ~, r_all, s_all] = ...
        admm_sdp(fun, sub_ids, XDATA, rho, x0, z0, u0, tol, maxit);
    
    length(x_all)
    % Retrieve optimal X
    X  = x_all{end}(1:m,m+1:end);
    
    % Record X
    Xs{end + 1} = full(X);
    
    % Record Froebenius norm error
    fnorms = [fnorms; norm(full(X) - XDATA, "fro")];
    
    % If X close enough to XDATA , we stop using Froebenius norm
    if norm(full(X) - XDATA, "fro") <= tol
        break
    end
    
    % update counter
    n_iters = n_iters + 1;
end


end
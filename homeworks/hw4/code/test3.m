clear
cvx_quiet false

W = load("hw4data1.mat").W;
[n, ~] = size(W);


cvx_begin sdp
    variable X(n,n) 
    maximize 0.5 * sum(sum(W .* (ones(n,n) - X))) 
    diag(X) == 1;
    X >= 0;
cvx_end

%[V,D] = eig(X);
%rank(X)
V = chol(X);
size(V)
%rank(V)


partition = zeros(n, 1);
r = (1/sqrt(n)) .* ones(n, 1);

for i=1:n
    %disp(size(V(i,:)'))
    if dot(V(i,:), r) >= 0
        partition(i) = 1;
    else
        partition(i) = 0;
    end
end    
partition'
%cvx_optval
%0.870 * cvx_optval

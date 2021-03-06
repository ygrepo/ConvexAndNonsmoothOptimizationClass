%% hw8

clf; close all;

% Problem setup

M = 1000;
density = 2/M;
N = 100;
A = sprandn(M, N, density);
b=randn(M,1);


% M = 100000;
% density = 2/M;
% N = 10000;
% A = sprandn(M, N, density);
% b=randn(M,1);

lambda = 0.2;
rho = 2;

%% Lambda experiment: Does x get sparser?
lambdas = (0:0.25:6)';
%lambdas = logspace(0.001, 2, N);
nnz_lambda = zeros(size(lambdas));

for k = 1:length(lambdas)
    lambda = lambdas(k);
    [x_star, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = lasso_admm(A, b, lambda, rho);
    fprintf('With lambda = %.2f we receive nnz(x) = %d\n', lambda, nnz(x_star));
    nnz_lambda(k) = nnz(x_star);
    %x = lasso_cvx(A, b, l);
    %fprintf('With lambda = %.2f we receive nnz(x) = %d\n', l, N-sum(abs(x)<1e-7));
end %Yes, around l = 5~ we have x = 0.

figure();
plot(lambdas, nnz_lambda, 'k-o');
title('Does larger $\lambda$ result in sparser $x$?')
xlabel('$\lambda$');
ylabel('nnz($x_\lambda$)');

%% rho experiment: what effect does this have on the method?

lambda = 2.0;
rho = 2.^(-8 : 8)';
timings = size(length(rho));
for k=1:length(rho)
    tic;
    lasso_admm(A, b, lambda, rho(k));
    t = toc;
    timings(k) = t;
    fprintf('With rho = %.2f has runtime t=%.3f\n ', rho(k), t);
end %As rho << 1 or rho >> 1, the runtime suffers.
figure();
plot(rho, timings, 'k-o');
title('Does $\rho << 1$ or $\rho >> 1$ result in a runtime penalty?')
xlabel('$\rho$'); ylabel('Runtime');
set(gca, 'xscale', 'log');

%% Sanity check on the convergence of ADMM

lambda = 2;
rho = 1;


[x_star_admm, p_star_admm, f_all, x_all, z_all, u_all, r_norm, s_norm, ...
    eps_pri, eps_dual] = lasso_admm(A, b, lambda, rho);
[x_star_cvx, p_star_cvx] = lasso_cvx(A,b, lambda);
figure, hold on, grid on
p_star_cvx_values = p_star_cvx*ones(K,1);


plot(1:K, p_star_cvx_values,  'k--', 1:K, f_all, 'r-');
title('Objective ADMM method','FontSize', 14);
xlabel('Iterations');
ylabel('Objective value');
saveas(gcf,"lasso_comp",'pdf')

%% Plot objective error for ADMM method
% Objective
figure, hold on, grid on
% ADMM

semilogy(1:K, f_all - p_star_admm, "k-o", 'LineWidth',1,'MarkerSize',3);
semilogy(1:K, f_all - p_star_cvx, "b-^", 'LineWidth',1,'MarkerSize',3);

% Legend, axis and title
title('Objective error for the ADMM method','FontSize', 14);
xlabel('Iterations');
ylabel('Objective value');
legend('ADMM error','CVX error');


%% Plot norms

figure, hold on, grid on

% ||r||2^2 and ||s||2^2s
semilogy(1:K, r_norm, "b-*", 'LineWidth',1,'MarkerSize',3);
semilogy(1:K, s_norm, "c-o", 'LineWidth',1,'MarkerSize',3);


% Legend, axis and title
title('Norms','FontSize', 14);
xlabel('Iterations');
ylabel('Norm');
legend('r norm', 's norm');

%% Plot epsilons

figure, hold on, grid on

semilogy(1:K, eps_pri, "b-*", 'LineWidth',1,'MarkerSize',3);
semilogy(1:K, eps_dual, "c-o", 'LineWidth',1,'MarkerSize',3);


% Legend, axis and title
title('Epsilons','FontSize', 14);
xlabel('Iterations');
ylabel('Epsilons');
legend('$\epsilon$ primal', '$\epsilon$ dual','Interpreter','latex');



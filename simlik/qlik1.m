function lik = qlik1(x,data)
    
    % Q-learning on multi-armed bandit
    %
    % USAGE: [lik, data] = qlik1(x,data,opts)
    %
    % INPUTS:
    %   x - parameters: (may vary based on opts structure)
    %       x(1) - inverse temperature
    %       x(2) - stickiness inverse temperature
    %       x(3) - learning rate
    %
    %
    %   data - structure with the following fields:
    %       .c - [N x 1] choices
    %       .r - [N x 2] rewards [gems, bomb]
    %       .pG - [N x C] gems reward probabilities
    %       .pB - [N x C] bomb reward probabilities
    %       .C - number of choice options
    %       .N - number of trials
    %       .O - number of reward types
    %       .D - probability door returns gems [only for non-simultaneous gems/bomb outcomes]
    %
    %
    % OUTPUTS:
    %   lik - log-likelihood
    %
    %   data - structure with the following fields:
    %   %-------likelihood mode-------%
    %           .v - [N x C] learned values
    %           .rpe - [N x O] reward prediction error for chosen option
    %   %-------simulation mode-------%
    %           .c - [N x 1] choices
    %           .r - [N x 1] rewards
    %
    % Sam Gershman, July 2015
    
    it = x(1);
    k  = x(2);
    lr = x(3);

    C = data.C;
    v = zeros(1,C); % initial values
    u = zeros(1,C);  % stickiness
    lik = 0;
    for n = 1:data.N
        q = it*v + k*u;
        c = data.c(n);
        r = data.r(n,:);
        lik = lik + q(c) - logsumexp(q);
        % compute gems/bomb reward prediction errors
        rpe = sum(r)-v(c);
        % update values
        v(c) = v(c) + lr*rpe;
        % update stickiness
        u = zeros(1,C); u(c) = 1;
        %data.rpe(n,1) = rpe;
    end
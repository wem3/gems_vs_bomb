function lik = qlik4(x,data)
    
    % Q-learning on multi-armed bandit with choice stickiness and separate learning rates for positive
    % and negative prediction errors.
    %
    % USAGE: [lik, data] = q_sim_lik(x,data,opts)
    %
    % INPUTS:
    %   x - parameters: (may vary based on opts structure)
    %       x(1) - inverse temperature
    %       x(2) - stickiness inverse temperature
    %       x(3) - learning rate (for positive gems prediction errors)
    %       x(4) - learning rate (for positive bomb prediction errors)
    %       x(5) - learning rate (for negative gems prediction errors)
    %       x(6) - learning rate (for negative bomb prediction errors)
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
    lr_pos_gems = x(3);
    lr_pos_bomb = x(4);
    lr_neg_gems = x(5);
    lr_neg_bomb = x(6);
    
    %-------simulation mode-------%

    C = data.C;
    vG = zeros(1,C); % initial gems values
    vB = zeros(1,C); % initial bomb values
    u = zeros(1,C);  % stickiness
    lik = 0;
    for n = 1:data.N
        v = vG + vB;
        q = it*v + k*u;
        c = data.c(n);
        r = data.r(n,:);
        lik = lik + q(c) - logsumexp(q,2);
        % compute gems/bomb reward prediction errors
        grpe = r(1)-vG(c);
        brpe = r(2)-vB(c);
        % update values
        if grpe > 0 % pos gems
            vG(c) = vG(c) + lr_pos_gems*grpe;
        else        % neg gems
            vG(c) = vG(c) + lr_neg_gems*grpe;
        end
        if brpe > 0 % pos bomb
            vB(c) = vB(c) + lr_pos_bomb*brpe;
        else        % neg bomb
            vB(c) = vB(c) + lr_neg_bomb*brpe;
        end
        % update stickiness
        u = zeros(1,C); u(c) = 1;
    end
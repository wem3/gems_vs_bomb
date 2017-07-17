function [lik, data] = qlik2(x,data,sim,expt)
    
    % Q-learning on multi-armed bandit with choice stickiness and separate learning rates for positive
    % and negative prediction errors.
    %
    % USAGE: [lik, data] = q_sim_lik(x,data,opts)
    %
    % INPUTS:
    %   x - parameters: (may vary based on opts structure)
    %       x(1) - inverse temperature
    %       x(2) - stickiness inverse temperature
    %       x(3) - learning rate (for gems prediction errors)
    %       x(4) - learning rate (for bomb prediction errors)
    %
    %   data - structure with the following fields:
    %       .c - [N x 1] choices
    %       .r - [N x 2] rewards [gems, bomb]
    %       .gP - [N x C] gems reward probabilities
    %       .bP - [N x C] bomb reward probabilities
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
    lr_gems = x(3);
    lr_bomb = x(4);

    C = data.C;
    vG = zeros(1,C); % initial gems values
    vB = zeros(1,C); % initial bomb values
    u = zeros(1,C);  % stickiness
    lik = 0;
    for n = 1:data.N
        v = vG + vB;
        q = it*v + k*u;
        % simulation mode
        if sim == 1
            p = exp(q - logsumexp(q,2));
            c = fastrandsample(p);
            lik = lik + log(p(c));
            r = [0 0];
            if (strcmp(expt,'b2') || strcmp(expt,'b3'))
                % determine rewards
                if data.gP(n,c) > rand
                    if data.D(c) > rand
                        r(1) = 1;
                    else
                        r(2) = 1;
                    end
                end
            elseif (strcmp(expt,'b4') || strcmp(expt,'b1'))
                if data.gP(n,c) > rand
                    r(1) = 1;
                end
                if data.bP(n,c) > rand
                    r(2) = 1;
                end
            end
            data.c(n,1) = c;
            data.r(n,:) = r;
        % likelihood mode
        else
            c = data.c(n);
            r = data.r(n,:);
            lik = lik + q(c) - logsumexp(q,2);
        end
        % compute gems/bomb reward prediction errors
        grpe = r(1)-vG(c);
        brpe = r(2)-vB(c);
        % update values
        vG(c) = vG(c) + lr_gems*grpe;
        vB(c) = vB(c) + lr_bomb*brpe;
        % update stickiness
        u = zeros(1,C); u(c) = 1;
        data.grpe(n,1) = grpe;
        data.brpe(n,1) = brpe;
    end
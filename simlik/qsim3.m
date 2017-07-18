function [lik, data] = qlik3(x,data,sim,expt)
    
    % Q-learning on multi-armed bandit with choice stickiness and separate learning rates for positive
    % and negative prediction errors.
    %
    % USAGE: [lik, data] = qlik3(x,data,opts)
    %
    % INPUTS:
    %   x - parameters: (may vary based on opts structure)
    %       x(1) - inverse temperature
    %       x(2) - stickiness inverse temperature
    %       x(3) - learning rate (for positive prediction errors)
    %       x(4) - learning rate (for negative prediction errors)
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
    lr_pos = x(3);
    lr_neg = x(4);

    C = data.C;
    v = zeros(1,C); % initial values
    u = zeros(1,C);  % stickiness
    lik = 0;
    for n = 1:data.N
        q = it*v + k*u;
        % simulation mode
        if sim == 1
            p = exp(q - logsumexp(q,2));
            c = fastrandsample(p);
            lik = lik + log(p(c));
            r = [0 0];
            if (strcmp(expt,'b2') || strcmp(expt,'b3'))
                % determine rewards
                if data.pG(n,c) > rand
                    if data.D(c) > rand
                        r(1) = 1;
                    else
                        r(2) = 1;
                    end
                end
            elseif (strcmp(expt,'b4') || strcmp(expt,'b1'))
                if data.pG(n,c) > rand
                    r(1) = 1;
                end
                if data.pB(n,c) > rand
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
        rpe = sum(r)-v(c);
        % update values
        if rpe > 0 % pos
            v(c) = v(c) + lr_pos*rpe;
        else       % neg
            v(c) = v(c) + lr_neg*rpe;
        end
        % update stickiness
        u = zeros(1,C); u(c) = 1;
        data.rpe(n,1) = rpe;
    end
function lik = qlik5(x,data)

   % Q-learning on multi-armed bandit
   %
   % USAGE: [lik, data] = qlik1(x,data,opts)
   %
   % INPUTS:
   %   x - parameters: (may vary based on opts structure)
   %       x(1) - inverse temperature
   %       x(2) - stickiness inverse temperature
   %       x(3) - learning rate
   %       x(4) - weighting parameter indicating preference for gems over bomb
   %
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
   % based on rllik.m - Sam Gershman, July 2015
   %
   % ~wem3~ [20170718]
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   it = x(1); % inverse temperature
   k  = x(2); % stickiness
   lr = x(3); % learning rate
   w  = x(4); % weighting parameter to indicate gems preference

   C = data.C;
   vg = zeros(1,C); % gems values
   vb = zeros(1,C); % bomb values
   u = zeros(1,C);  % stickiness
   lik = 0;
   for n = 1:data.N
       q = it*( w*vg + (1-w)*vb ) + k*u;
       c = data.c(n);
       r = data.r(n,:);
       lik = lik + q(c) - logsumexp(q);
       % compute gems/bomb reward prediction errors
       grpe = r(1)-vg(c);
       brpe = r(2)-vb(c);
       % update values
       vg(c) = vg(c) + lr*grpe;
       vb(c) = vb(c) + lr*brpe;
       % update stickiness
       u = zeros(1,C); u(c) = 1;
       %data.rpe(n,1) = rpe;
   end
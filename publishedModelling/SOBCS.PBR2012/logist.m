function y = logist(mean,tau,gain);
%  Logistic function (parameters: mean, tau, gain, gain is multiplied in)
if nargin < 3 gain = 1; end
if nargin < 2 tau = 0; end
y = 1./(1+exp(-(mean-tau).*gain));

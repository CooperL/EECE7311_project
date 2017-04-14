function [y] = lp_profile(x,fp,fs)
% Function y = bp_profile(x,fp,fs) computes 1-D profile needed in Problem P4.7
%   Input: normalized frequency x in the range -1 <= x <= 1

if (x > 1) | (x < -1)
    error('*** Input x values must be between -1 and +1 inclusive ***')
end
y = 1+(abs(x)-fp)/(fp-fs);
y = max(0,y); y = min(y,1);

end
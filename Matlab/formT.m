function [T] = formT(Nr)
%This function creates the transition matrix T for the markov chain in Fig
%3 in the paper

temp = zeros(Nr+1);

temp(1,2) = 1;
for i = 2:Nr+1
    temp(i,i) = temp(i-1,i-1) + 1/Nr;
    if i < Nr
        temp(i,i+1) = temp(i-1,i) - 1/Nr;
    end
end

T = temp;

end


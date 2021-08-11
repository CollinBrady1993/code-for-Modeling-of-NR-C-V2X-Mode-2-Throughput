function [bler] = mappingSinrBler(sinr,mcs,cbSizeBits)

baseGraphType = getBaseGraphType(cbSizeBits,mcs);

sinr2BlerMap = getSinr2BlerMap();

cbMap = sinr2BlerMap{baseGraphType}{mcs+1};

for i = 1:length(cbMap)
    if cbMap{i}{1} > cbSizeBits
        if i > 1
            cbIt = i - 1;
            break
        else
            cbIt = i;
            break
        end
    end
end

bler = -1*ones(size(sinr));
bler(sinr < cbMap{cbIt}{2}{1}(1)) = 1;
bler(sinr > cbMap{cbIt}{2}{1}(end)) = 0;
if any(bler==-1)%any values havent been asigned
    bler(bler==-1) = interp1(cbMap{cbIt}{2}{1},cbMap{cbIt}{2}{2},sinr(bler==-1));
end

end


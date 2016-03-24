function normvec = GenNormvlength(vector)

length = 0;

for i = 1:size(vector,2)
    length = length + (vector(1,i)^2);
end

normvec = vector./(length^0.5);

    
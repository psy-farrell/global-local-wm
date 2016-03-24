function [letters, prototype] = GenStimuliLetters(prototype)  
% Simon Farrell's code for generating letters according to the Hull (1973)
% SEM solution (see Farrell 2006, JML, for details)

global C
if nargin < 1, prototype = 0; end

%%%% define the coordinates in the MDS solution

centonzero = 2.0486;
%B D G P T V
sensem = [1.21075   0.32396   -0.58672;
          1.46936   0.14582   -0.44602;
          1.50836  -0.27709    0.27380;
          1.08090   0.59597   -0.28908;
          1.45477   0.58961    0.17232;
          1.26384   0.14538   -0.95218] + centonzero;
%use Hull 3-dim coordinates. the last one is for V which
%was not used in our studies but needs to be there for pure S
%lists. the constant that is added rescales coordinates so the
%smallest (out of D and S) is equal to 0

%set up dissimilar items: Hull 3D
%H K M Q R
densem1 = [-1.72575  -0.01141  -0.11040;
           -0.69862   1.34950   1.05504;
           -0.66675   1.32777  -0.97868;
            1.05581  -0.78153   1.08191;
           -0.41118  -2.04858  -0.16205 ] + centonzero;
%L W X Y Z
densem2 = [-0.98481  -0.24620   1.53558;
            0.21815  -1.36789  -1.64326;
           -1.49151  -0.20096  -0.86152;
           -0.46904  -1.89834   0.73003;
           -1.19267   0.72698   0.84231] + centonzero;

maxcoord = max(max([sensem; densem1; densem2]));
sensem = sensem./maxcoord;
densem1 = densem1./maxcoord;
densem2 = densem2./maxcoord;

%%%%%%Create the vectors

if nargin < 1  %if no prototype is handed over, create new origin and maxfromorigin at random
    origin = sign(randn(C.un, 1));
    maxfromorigin = sign(randn(C.un, 1));
    prototype = [origin(1:floor(C.un/2)); maxfromorigin(floor(C.un/2)+1:C.un)]'; %blend of origin (1st half) and maxfromorigin (2nd half)
else  %if a prototype is given, split it into origin and maxfromorigin and fill in the rest at random
    origin = [prototype(1:floor(C.un/2))'; sign(randn(C.un-floor(C.un/2), 1))];
    maxfromorigin = [sign(randn(C.un-floor(C.un/2), 1)); prototype(floor(C.un/2)+1:C.un)'];
end

simpool = zeros(C.un, 6);
dsimpool1 = zeros(C.un, 5);
dsimpool2 = zeros(C.un, 5);

for i=1:6
     simpool(:, i) = getsimvec (sensem(i,:), origin, maxfromorigin, C.un);
end
for i=1:5
     dsimpool1(:, i) = getsimvec (densem1(i,:), origin, maxfromorigin, C.un);
     dsimpool2(:, i) = getsimvec (densem2(i,:), origin, maxfromorigin, C.un);
end

letters(1:6,:) = simpool';
letters(7:11,:) = dsimpool1';
letters(12:16,:) = dsimpool2';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flipvec = getsimvec (coords, origin, maxfromorigin, ndim)

ovec = ones (ndim,1);
for j=1:3    %loop over phonological dimensions
    b=(j-1)*(ndim/3);
    p=coords(j);
    ovec (b+1:b+(ndim/3)) = rand(1,(ndim/3)) > p;
end 
flipvec = ovec.*origin + ~ovec.*maxfromorigin;
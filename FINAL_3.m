% Jonathan DiBacco and Michael Tanja

% The first segment of the code is where all the parameters are stated. 
% The only thing you will have to change is the NperRow and the NperCol
% The 'dx' changes according to the inputs for NperRow/Col


clear all
close all

%%
%parameters and
%mesh properties
prompt1 = 'What resolution of dx would do you want?          : ';
prompt2 = 'What is the length and width of this square plate?: ';
L       = input(prompt2);          % unsure about what this does, but it was in the example
W       = L;                       % unsure about what this does, but it was in the example
dx      = input(prompt1);
qx      = 100000;                  % heat flux bottom
qy      = -65000;                  % heat flux side
NperRow = (L/dx) + 1;              % Nodes per row
NperCol = NperRow;                 % Nodes per column
nNodes  = NperRow * NperCol;
C       = zeros(NperRow, NperCol);
b       = zeros(NperRow,1);
 
k       = 250;                     % conduction coefficient
h       = 250;                     % convection coefficient
Tinf    = 0;                       % fluid temp in celsius

dt      = input('what is the dt?                                   : ');                      % delta t
endtime = input('how long should the simulation run?               : ');                      % setting end time
Tcol    = endtime/dt;              % number of temperature colloms
T       = zeros(nNodes,Tcol);      % initializing Temperature %Tcol
T(:,1)  = 400*ones(1, nNodes);     % setting initial condition to Temperature = 400 at Time = 0

% got rid of ro and cp
a       = 1e-4;                    % thermal diffusivity
Fo      = (a*dt)/(dx*dx);          %Fourier
i = 1;
%%
% setting up the time loop
for t = 1:dt:endtime




% next in line is node set up
%% 
% Center Node/s

for ii = NperRow+2 : ((2*NperRow-1))
    for jj = ii:NperRow:nNodes-(NperRow+1)%NperRow+2 : (NperRow^2) - (NperRow+1) %put this first in order, matlab reads top down
    
    C(jj, jj+NperRow) = -Fo;         % upper
    C(jj, jj-NperRow) = -Fo;         % lower
    C(jj, jj+1)       = -Fo;         % right
    C(jj, jj-1)       = -Fo;         % left
    C(jj, jj)         = ((4*Fo)+1);  % center
    b(jj)             = 0;           % boundary
    end
end

%%
% Convection node/s on the right

for ii = 2*NperRow : NperRow : (NperRow^2) - NperRow              %needs to be more generalized
    
    jj = ii;
    
    C(ii, jj+NperRow) = -Fo;                        % upper
    C(ii, jj-NperRow) = -Fo;                        % lower
                                                    % no right
    C(ii, jj-1)       = -2*Fo;                      % left
    C(ii, jj)         = (((2*Fo*h*dx)/k)+(4*Fo)+1); % center
    b(ii)             = ((2*Fo*h*dx*Tinf)/k);       % boundary
    
end

%% 
% Convection node/s on top
for ii = (nNodes )-(NperRow - 2) : (nNodes -1) %generalized
    
    jj = ii;
                                                        % no top term
    C(ii, jj-NperRow) = -2*Fo;                          % lower
    C(ii, jj+1)       = -Fo;                            % right 
    C(ii, jj-1)       = -Fo;                            % left
    C(ii, jj)         = (4*Fo)+((2*Fo*h*dx)/(k)) + 1;   % center
    b(ii)             = (2*Fo*h*dx*Tinf)/(k);          % boundary
end

%starting corners 1-4
%%
% Corner 1 (this boundary condition should have same initiation
%   for any matrix size)
for ii = (NperCol*NperRow)-(NperRow-1)     %generalized
    
    jj = ii;
                                                                  % no top term 
    C(ii, jj-NperRow) = -2*Fo;                                    % lower
    C(ii, jj+1)       = -2*Fo;                                    % right 
                                                                  % no left term
    C(ii,jj)          = ((4*Fo) + ((2*Fo*h*dx)/k) + 1);           % center
    b(ii)             = (((2*Fo*qy*dx)/k)+((2*Fo*h*dx*Tinf)/k));  % boundary
    
                       %EDIT: change flow of heat on boundary condition
end

%%
% Corner 2 (This shouldn't change either)

for ii = nNodes
    
    jj = ii;
                                                        % no top term
    C(ii, jj-NperRow) = -2*Fo;                          % lower term
                                                        % no right term
    C(ii, jj-1)       = -2*Fo;                          % left
    C(ii, jj)         = ((4*Fo*h*dx)/(k)) + (4*Fo) + 1; % center
    b(ii)             = (4*Fo*h*dx*Tinf)/k;             % boundary
end

%%
% Corner 3 (should stay the same for all meshes)

for ii = 1
    
    jj = ii;
    
    C(ii, jj+NperRow) = -2*Fo;                   % upper
                                                 % no lower
    C(ii, jj+1)       = -2*Fo;                   % right
                                                 % no left term
    C(ii, jj)         = (4*Fo) + 1;              % center
    b(ii)             = (((2*Fo*dx)/k)*(qx+qy)); % boundary
    
               %EDIT: Changed flow of heat on the boundary condition
end

%%
% Corner 4 (should be the same for all matrices)

for ii = NperRow
    
    jj = ii;
    
    C(ii, jj+NperRow) = -2*Fo;                                 % upper
                                                               % no lower term
                                                               % no right term
    C(ii, jj-1)       = -2*Fo;                                 % left term
    C(ii,jj)          = (4*Fo)+((2*Fo*h*dx)/k) + 1;            % center
    b(ii)             = (((2*Fo*qx*dx)+(2*Fo*h*dx*Tinf))/k);  % boundary
end

%corners are finished
%Start heat sources
%%
%heat source left side

for ii = NperRow+1 : NperRow : (nNodes)-(NperRow+1)           %try to generalize for all matrices
    
    jj = ii;
    
    C(ii, jj+NperRow) = -Fo;                % upper
    C(ii, jj-NperRow) = -Fo;                % lower
    C(ii, jj+1)       = -2*Fo;              % right
                                            % no left term
    C(ii, jj)         = ((4*Fo) + 1);       % center
    b(ii)             = (2*Fo*qy*dx)/k;     % boundary
    
             %EDIT: Changed flow of heat on the boundary condition, for qy
end

%%
%heat source bottom

for ii = 2: (NperRow-1)   % generalized
    
    jj = ii;
    
    C(ii, jj+NperRow) = -2*Fo;            % upper
                                          % no lower term
    C(ii, jj+1)       = -Fo;              % right term
    C(ii, jj-1)       = -Fo;              % left term
    C(ii, jj)         =(4*Fo) + 1;        % center
    b(ii)             = (2*Fo*qx*dx)/k;   % boundary
end

%%
% here we are goint to actualy solve for future T

K        = inv(C);
T(:,i+1) = K*T(:,i)+ K*b;
i        = i+1;

end

%%
% creating the mesh plot 

x     = 0: dx :L;    % x-axis grid
y     = 0: dx :W;    % y-axis grid

[X,Y] = meshgrid(x,y);
%Create a loop that converts the vector back into a mesh to plot
%takes the temperature vector and reorganizes into a matrix

nIndex = 1; %this index will count down the temperature
for aa = 1:NperRow %nNodes/NperRow
    for bb = 1:NperRow
        TMesh(aa,bb) = T(nIndex,Tcol);
        nIndex = nIndex +1;
    end
end
%TMesh1 = abs(TMesh);
%recycled some of the example code

contourf(X,Y,TMesh)

colorbar

%contour looks ok,but heat might be flowing in the wring direction
%change the sign for heat flow on the right face of the figure
%^this should affect values for T1, T4, T7
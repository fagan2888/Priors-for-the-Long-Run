% Replcation files for the paper:
% "Priors for the Long-Run", by D. Giannone, G. Primiceri and M. Lenza
% 
% This code replicate the mean squared forecast errors in models with three
% variables (figures 5 )
clear;
clc;

% Loading the data
load y 
y = y(:,1:3);
variables = {'Y','C','I'};
[T,n] = size(y); 

addpath(['./subroutines']) %The folder with subroutines

lags = 5;  % n. of lags on the VAR
hz = 1:40; % Forecasting horizons in quarters
ini = 81;  % The beginning of the recursive estimation (out-of-sample)

%Inizializes the matrix to store the forecasts and the Mean Square Forecast Errrors
Yfcast=zeros(T,length(hz),n); 
MSFE=zeros(length(hz),n);    
MSFELC=zeros(length(hz),n);   

% Defines the matrix with the linear transformations used to elicit the Long Run Prior
%         Y   C   I
Ctr = [
          1   1   1 ;  %Y+C+I
         -1   1   0 ;  %C-Y
         -1   0   1 ]; %I-Y 

transformations = {'Y+C+I','C-Y','I-Y'};


% Define the different models
% There are several specifications you can run
% Just uncomment the text assoiciated to one of the specifications.
% You can run only one specification at a time and the line for the MSFEs will be added to the chart

% Different models are obtained by setting the following options (see setprior.m for details)
% mn:            0 = Minnesota Prior is is OFF
%                1 = Estimate the overall tightness (default)
%               -1 = Dogmatically impose the prior
%               -2 = Sets the overall shrinkage at the mode of the hyperprior (.2)
%               
% HH:            Matrix to set the long run prior, each colums takes combinations of data
%                It should be a full row rank matrix
%
%               
%IndPhi:       Vector specifying the treatment of the PLR for each row of HH
%               0 = Prior is OFF 
%               1 = Estimate the PLR tightness (default)
%              -1 = Dogmatically impose the prior
%              -2 = Sets the overall shrinkage at the mode of the hyperprior (1)
%               (if some raws of HH are not specified, the last index of IndPhi 
%               indicates the prior on the nulls spcae
%                        1: Invariant (default)
%                        0: flat 
%                       -2: Hyperprior Mode (2)
%                       
%SinglePhi:   1 = estimates the same degree of shrinkage for all active rows of HH
%             0 = Separate shrinkage for each active row (default)

% %Flat
%  ModLab = 'Flat';
%  HH = Ctr;
%  IndPhi = [0 0 0];
%  SinglePhi = 0;
%  mn = 0;
%  color='k'; LS=':'; LW=1;

% %Minnesota 
%  ModLab = 'MN';
%  HH = eye(n); %Does not matter
%  IndPhi = [0 0 0];
%  SinglePhi = [];
%  mn = 1;
%  color='b'; LS='-'; LW=1;

%  %Sims and Zha
%  ModLab = 'SZ';
%  HH = eye(n);
%  IndPhi = [1 1 1];
%  SinglePhi = 1;
%  mn = 1;
%  color='g'; LS='--'; LW=2;

% %Diff
%  ModLab = 'Diff';
%  HH = eye(n);
%  IndPhi = [-1 -1 -1];
%  SinglePhi = 0;
%  mn = 0;
%  color='m'; LS='-.'; LW=2;

% %VECM
%  ModLab = 'VECM';
%  HH = Ctr;
%  IndPhi = [-1 0 0];
%  SinglePhi = 0;
%  mn = 0;
%  color= [1,.75,0]; LS=':'; LW=3;

%PLR benchmark
 ModLab = 'PLR';
 HH = Ctr;
 IndPhi = [1 1 1];
 SinglePhi = 0;
 mn = 1;
 color='r'; LS='-'; LW=3;


% generating forecasts recursively
for t=ini:T 
    t
    pause(.5);
    r = bvarPLR(y(1:t,:),lags,'HH',HH,'mn',mn,'IndPhi',IndPhi,'SinglePhi',SinglePhi);
    Yfcast(t,:,:)=r.postmax.forecast(:,:);
end

% computing the MSFE
for h=hz
        
    DYfcast=(squeeze(Yfcast(ini-h+max(hz):end-h,h,:))-y(ini-h+max(hz):end-h,:));%/h;
    DY=(y(ini+max(hz):end,:)-y(ini-h+max(hz):end-h,:));%/h;
    DYfcastDY=DYfcast-DY;
    
    MSFE(h,:)=mean((DYfcastDY).^2);
    
    DYfcastLC=(squeeze(Yfcast(ini-h+max(hz):end-h,h,:))-y(ini-h+max(hz):end-h,:)*0)*Ctr';%/h;
    DYLC=(y(ini+max(hz):end,:)-y(ini-h+max(hz):end-h,:)*0)*Ctr';%/h;
    DYfcastDYLC=DYfcastLC-DYLC;
        
    MSFELC(h,:)=mean((DYfcastDYLC).^2);
        

end
 
%Plotting the MSFE for the variables and their linear combintaions
figure(3);
for ii = 1:n
    subplot(2,3,ii); plot(MSFE(:,ii),'color',color,'LineStyle',LS,'LineWidth',LW); hold on;
    set(gca,'FontSize',12);
    title(variables{ii})
    if ii == 1, ylabel('MSFE','FontSize',12); end
end

for ii = 1:n
    subplot(2,3,ii+3); plot(MSFELC(:,ii),'color',color,'LineStyle',LS,'LineWidth',LW); hold on;
    set(gca,'FontSize',12);
    title(transformations{ii})
    if ii == 1, ylabel('MSFE','FontSize',12); end
    xlabel('Quarters Ahead','FontSize',12);
end

fig3=figure(3);
fig3.Position=[0 300   875   600];
% legend('MN','SZ','DIFF','VECM','PLR')


% Global Nr Monte Carlo simulation 2012
Q_N2O=xlsread('D:\PhD Thesis\Data and calculation\Uncertainties\2012 inventory.xlsx','B1:KUF1');% change the route accordingly 
Q_NOx=xlsread('D:\PhD Thesis\Data and calculation\Uncertainties\2012 inventory.xlsx','B2:KUF2');% change the route accordingly 
Q_NH3=xlsread('D:\PhD Thesis\Data and calculation\Uncertainties\2012 inventory.xlsx','B3:KUF3');% change the route accordingly 
IO=load('D:\PhD Thesis\Data and calculation\Uncertainties\2012.mat');   % change the route accordingly 

Q_N2O(Q_N2O<0)=0;
Q_NOx(Q_NOx<0)=0;
Q_NH3(Q_NH3<0)=0;
T=IO.Z;
Y=IO.Y;
Y(Y<0)=0;
X=sum(T,2)+sum(Y,2);
NMC=5;  % MC simulation times  
NI=163;     % sector number
RI=49;      % region number
n=1;
Nr_intensity_global=zeros(NMC,NI*RI);
Nr_final=zeros(NMC,RI*7+1);

% small inputs have a much larger uncertainty than large inputs 1-50%
T_max=max(max(T));
T_min=min(min(T+1e-10));
b=log(0.5/0.01)/log(T_min/T_max);
a=0.5/(T_min^b);
T_RSD=a*(T+1e-10).^b; 

Y_RSD=0.1; % CV conusmption 10%

% For N2O, China:93%;India:93%;Brazil:93%;USA:42%
% russia:100%;EU:42%;else 100%
Q_RSD_N2O=zeros(size(Q_N2O)); 
EU=[1:28 39 42];
for m=1:NI
   Q_RSD_N2O(1,30*NI+m)=0.93/2; 
end
for m=1:NI
   Q_RSD_N2O(1,34*NI+m)=0.93/2; 
end
for m=1:NI
   Q_RSD_N2O(1,33*NI+m)=0.93/2; 
end
for m=1:NI
   Q_RSD_N2O(1,28*NI+m)=0.42/2; 
end
for m=1:NI
   Q_RSD_N2O(1,36*NI+m)=1/2; 
end
for i=1:size(EU,2)
    for j=1:NI
     Q_RSD_N2O(1,(EU(1,i)-1)*NI+j)=0.42/2;
    end
end
Q_RSD_N2O(Q_RSD_N2O==0)=1/2;

% For NOx, China:56%;India:66%;Brazil:124%;USA:29%
% russia:17%;EU:51%;else 69%
Q_RSD_NOx=zeros(size(Q_NOx)); 
EU=[1:28 39 42];
for m=1:NI
   Q_RSD_NOx(1,30*NI+m)=0.56/2; 
end
for m=1:NI
   Q_RSD_NOx(1,34*NI+m)=0.66/2; 
end
for m=1:NI
   Q_RSD_NOx(1,33*NI+m)=1.24/2; 
end
for m=1:NI
   Q_RSD_NOx(1,28*NI+m)=0.29/2; 
end
for m=1:NI
   Q_RSD_NOx(1,36*NI+m)=0.17/2; 
end
for i=1:size(EU,2)
    for j=1:NI
     Q_RSD_NOx(1,(EU(1,i)-1)*NI+j)=0.51/2;
    end
end
Q_RSD_NOx(Q_RSD_NOx==0)=0.69/2;   

% For NH3, China:294%;India:268%;Brazil:272%;USA:186%
% russia:195%;EU:233%;else 267%
Q_RSD_NH3=zeros(size(Q_NH3)); 
EU=[1:28 39 42];
for m=1:NI
   Q_RSD_NH3(1,30*NI+m)=2.94/2; 
end
for m=1:NI
   Q_RSD_NH3(1,34*NI+m)=2.68/2; 
end
for m=1:NI
   Q_RSD_NH3(1,33*NI+m)=2.72/2; 
end
for m=1:NI
   Q_RSD_NH3(1,28*NI+m)=1.86/2; 
end
for m=1:NI
   Q_RSD_NH3(1,36*NI+m)=1.95/2; 
end
for i=1:size(EU,2)
    for j=1:NI
     Q_RSD_NH3(1,(EU(1,i)-1)*NI+j)=2.33/2;
    end
end
Q_RSD_NH3(Q_RSD_NH3==0)=2.67/2; 

logT_SD=log10(1+T_RSD);
logY_SD=log10(1+Y_RSD);
logQ_SD_N2O=log10(1+Q_RSD_N2O);
logQ_SD_NOx=log10(1+Q_RSD_NOx);
logQ_SD_NH3=log10(1+Q_RSD_NH3); 

for mc=1:NMC
    Tp=10.^(log10(T+1e-10)+logT_SD.*randn(size(T)));
    Yp=10.^(log10(Y+1e-10)+logY_SD.*randn(size(Y)));
    Qp_N2O=10.^(log10(Q_N2O+1e-10)+logQ_SD_N2O.*randn(size(Q_N2O)));
    Qp_NOx=10.^(log10(Q_NOx+1e-10)+logQ_SD_NOx.*randn(size(Q_NOx)));
    Qp_NH3=10.^(log10(Q_NH3+1e-10)+logQ_SD_NH3.*randn(size(Q_NH3)));
    Qp=Qp_N2O+Qp_NOx+Qp_NH3;
    Xp1=sum(Tp,2)+sum(Yp,2);
 if sum(abs(Xp1-X))/sum(X)<=0.05
    Xp=diag(Xp1);
    Nr_intensity_global(n,:)=Qp/(Xp-Tp);
    Nr_final(n,:)=Nr_intensity_global(n,:)*Yp;
    n=n+1;
 end
end

save('Nr_intensity.mat','Nr_intensity_global');   % save the results, this is the default route
save('Nr_final.mat','Nr_final');   % save the results, this is the default route


Nr_intensity_CI951=prctile(Nr_intensity_global,[2.5 97.5]);
Nr_intensity_CI95(1,:)=(mean(Nr_intensity_global)-Nr_intensity_CI951(1,:))./mean(Nr_intensity_global);
Nr_intensity

Nr_final2=zeros(6000,49);
for m=1:6000
for i=1:49
for j=1:7
   Nr_final2(m,i)=Nr_final(m,(i-1)*7+j)+Nr_final2(m,i); 
end
end
end

Nr_final2_CI951=prctile(Nr_final2,[2.5 97.5]);
Nr_final2_CI95(1,:)=(mean(Nr_final2)-Nr_final2_CI951(1,:))./mean(Nr_final2);
Nr_final2_CI95(2,:)=(Nr_final2_CI951(2,:)-mean(Nr_final2))./mean(Nr_final2);

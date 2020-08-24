 %calculation farm land and water
T=load('D:\My study\Peking\My works\Nexus analysis\Eora data\Eora26_2012_bp\Eora26_2012_bp_T.txt');
[~,~,T_lables]=xlsread('D:\My study\Peking\My works\Nexus analysis\Eora data\Eora26_2012_bp\labels_T.xlsx');
FD=load('D:\My study\Peking\My works\Nexus analysis\Eora data\Eora26_2012_bp\Eora26_2012_bp_FD.txt');
[~,~,FD_lables]=xlsread('D:\My study\Peking\My works\Nexus analysis\Eora data\Eora26_2012_bp\labels_FD.xlsx');
x=sum(T,2)+sum(FD,2); %total output
[~,~,country_data]=xlsread('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx',5, 'A2:G192');
x_diag=diag(x);
for i=2:191
    country_water{i-1,1}=country_data{i,6};
    country_land{i-1,1}=country_data{i,7};
end
 country_water=cell2mat(country_water);
 country_land=cell2mat(country_land);
 
 for i=1:190
     water_extraction(1,(i-1)*26+1)=country_water(i,1);
     land_extraction(1,(i-1)*26+1)=country_land(i,1);
 end
 % embodied intensity
 T(:,4107)=0.0001;
 inv_matrix=pinv(x_diag-T);
 ei_water=water_extraction*inv_matrix; %embodied intensity
 ei_land=land_extraction*inv_matrix;

%  % sectoral world average
%  total_water=ei_water*x_diag;
%  total_land=ei_land*x_diag;
%  
%  for i=1:26
%    for j=1:189
%      water_sector(1,i)=total_water(1,(j-1)*26+i);
%      land_sector(1,i)=total_land(1,(j-1)*26+i);
%      x_sector(1,i)=x((j-1)*26+i,1);
%    end 
%  end
%  
%  for i=1:26
%     wei_sector(1,i)=water_sector(1,i)/x_sector(1,i);
%     lei_sector(1,i)=land_sector(1,i)/x_sector(1,i);
%  end
 
 % resources embodied in final demand
 for i=1:4915
   for j=1:1140
       FD_water(i,j)=ei_water(1,i)*FD(i,j);
       FD_land(i,j)=ei_land(1,i)*FD(i,j);
   end
 end
 % xlswrite('D:\My study\Peking\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', FD_lables', 5, 'C1');
%  xlswrite('D:\My study\Peking\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', FD_land, 5, 'C5'); 
 
 % sectoral final demand(differenct countries and different categories)
 FD_water_sector=zeros(26,1140);
  FD_land_sector=zeros(26,1140);
  for i=1:1140
      for j=1:26
          for k=1:189
             FD_water_sector(j,i)=FD_water((k-1)*26+j,i)+FD_water_sector(j,i);
              FD_land_sector(j,i)=FD_land((k-1)*26+j,i)+FD_land_sector(j,i);
          end
      end
  end
  
  % sectoral final demand  
   FD_water_category=zeros(26,6);
   FD_land_category=zeros(26,6);
  for i=1:26
      for j=1:6
          for k=1:190
              FD_water_category(i,j)= FD_water_sector(i,(k-1)*6+j)+FD_water_category(i,j);
              FD_land_category(i,j)= FD_land_sector(i,(k-1)*6+j)+FD_land_category(i,j);
          end
      end
  end
  
  % national final demand 
  FD_national_land_category=sum(FD_land_sector);
  FD_national_water_category=sum(FD_water_sector);
  FD_national_land=zeros(190,6);
  FD_national_water=zeros(190,6);
  for i=1:190
      for j=1:6
         FD_national_land(i,j)=FD_national_land_category(1,(i-1)*6+j);
          FD_national_water(i,j)=FD_national_water_category(1,(i-1)*6+j);
      end
  end
  
  out1=sum(FD_national_water,2);
  out2=sum(FD_national_land,2);
%   xlswrite('D:\My study\Peking\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx',  out1, 4, 'H3'); 
%   xlswrite('D:\My study\Peking\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', out2, 4, 'I3'); 
  
  % resources embodied in international trade (final demand trade)
  FD_trade1_water=zeros(4915,190);
  FD_trade1_land=zeros(4915,190);
  for i=1:4915
      for j=1:190
          for k=1:6
              FD_trade1_water(i,j)=FD_water(i,(j-1)*6+k)+FD_trade1_water(i,j);
              FD_trade1_land(i,j)=FD_land(i,(j-1)*6+k)+FD_trade1_land(i,j);
          end
      end
  end
   FD_trade_water=zeros(190,190);
   FD_trade_land=zeros(190,190);
  for i=1:190
      for j=1:190
          for k=1:26
              FD_trade_water(i,j)=FD_trade1_water((i-1)*26+k,j)+FD_trade_water(i,j);
              FD_trade_land(i,j)=FD_trade1_land((i-1)*26+k,j)+FD_trade_land(i,j);
          end
      end
  end
  xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', FD_trade_water, 15, 'D3');
    xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx',FD_trade_land, 14, 'D3');
  
  % resources embodied in international trade (intermediate inputs trade)
   T_water=zeros(4915,4915);
   T_land=zeros(4915,4915);
 for i=1:4915
   for j=1:4915
       T_water(i,j)=ei_water(1,i)*T(i,j);
       T_land(i,j)=ei_land(1,i)*T(i,j);
   end
 end
 
 Intermediate_trade1_water=zeros(4915,189);
 Intermediate_trade1_land=zeros(4915,189);
  for i=1:4915
      for j=1:189
          for k=1:26
              Intermediate_trade1_water(i,j)=T_water(i,(j-1)*26+k)+Intermediate_trade1_water(i,j);
              Intermediate_trade1_land(i,j)=T_land(i,(j-1)*26+k)+Intermediate_trade1_land(i,j);
          end
      end
  end
  
 Intermediate_trade_water=zeros(189,189);
 Intermediate_trade_land=zeros(189,189);
  for i=1:189
      for j=1:189
          for k=1:26
              Intermediate_trade_water(i,j)=Intermediate_trade1_water((i-1)*26+k,j)+Intermediate_trade_water(i,j);
              Intermediate_trade_land(i,j)=Intermediate_trade1_land((i-1)*26+k,j)+Intermediate_trade_land(i,j);
          end
      end
  end
  Intermediate_trade_water(190,190)=0;
  Intermediate_trade_land(190,190)=0;
  
  %water and land embodied in total trade
  land_embodied_trade=Intermediate_trade_land+FD_trade_land;
  water_embodied_trade=Intermediate_trade_water+FD_trade_water;
  for j=1:190
      Im_land(1,j)=sum(land_embodied_trade(:,j))-land_embodied_trade(j,j);
      Im_water(1,j)=sum(water_embodied_trade(:,j))-water_embodied_trade(j,j);
  end
  for i=1:190
      Ex_land(i,1)=sum(land_embodied_trade(i,:))-land_embodied_trade(i,i);
      Ex_water(i,1)=sum(water_embodied_trade(i,:))-water_embodied_trade(i,i);
  end
  xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', Im_water', 5, 'D4');
    xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', Im_land', 5, 'E4');
      xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', Ex_water, 5, 'F4');
        xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', Ex_land, 5, 'G4');
 %  xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', land_embodied_trade, 5, 'C3'); 
  %  xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', water_embodied_trade, 6, 'C3'); 
  
  % water and land embodied in exports with sector details
  Intermediate_trade1_land(4915,190)=0;
  Intermediate_trade1_water(4915,190)=0;
  trade_sector_land=FD_trade1_land+Intermediate_trade1_land;
  trade_sector_water=FD_trade1_water+Intermediate_trade1_water;
  for i=1:4914
     land_export(i,1)=sum(trade_sector_land(i,:))-trade_sector_land(i,floor((i-1)/26)+1);
     water_export(i,1)=sum(trade_sector_water(i,:))-trade_sector_water(i,floor((i-1)/26)+1);
  end
  xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', land_export, 16, 'D2');
   xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', water_export, 16, 'E2');
   
    % water and land embodied in imports with sector details
    land_import=zeros(26,189);
    water_import=zeros(26,189);
   
    for k=1:189
        for i=1:26
           for j=1:189
               if j==k
                   k
               else
            land_import(i,k)=trade_sector_land((j-1)*26+i,k)+land_import(i,k);
            water_import(i,k)=trade_sector_water((j-1)*26+i,k)+water_import(i,k);
               end
           end
        end
    end
    xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', land_import/1000, 17, 'B3');
   xlswrite('D:\My study\Peking\My works\Nexus analysis\Global Lnad-Water nexus\Data and calculation\Country data.xlsx', water_import, 17, 'B30');
   
   
    
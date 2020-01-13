% Script to read a file of EPIC data (vitals) and make plots for individual patients
% as well as an average over the whole cohort 

vitals_file = 'C:\Users\Chris\Desktop\Chris PhD Research\Updates\U01 Trauma - TrICI\13 patient EPIC files\Copy of triciresearch-vitals';
labs_file = 'C:\Users\Chris\Desktop\Chris PhD Research\Updates\U01 Trauma - TrICI\13 patient EPIC files\Copy of triciresearch-labs';
intakeoutput_file = 'C:\Users\Chris\Desktop\Chris PhD Research\Updates\U01 Trauma - TrICI\13 patient EPIC files\Copy of triciresearch-intakeoutput';
meds_file = 'C:\Users\Chris\Desktop\Chris PhD Research\Updates\U01 Trauma - TrICI\13 patient EPIC files\Copy of triciresearch-performedmeds';

Patient_IDs = {'014','019','020','025','027','028','036','038','044','055','068','075','078'};

for j = 1:length(Patient_IDs)

[~,~,raw] = xlsread(vitals_file,j+3); % Change the number here to look at different patients
% 4=Pt 014; 5=Pt 019; 6=Pat 020; 7=Pat 025; 8=Pat 027; 9=Pat 028; 
% 10=Pat 036; 11=Pat 038; 12=Pat 044; 13=Pat 055; 14=Pat 068; 15=Pat 075;
% 16=Pat 078
raw(1,:) = [];

AllData = struct();

ABP = nan(length(raw),3);
BP = nan(length(raw),3);
NIBP = nan(length(raw),3);
Heart_Rate = nan(length(raw),2);
MAP = nan(length(raw),2);
NBP_mean = nan(length(raw),2);
O2_Flow = nan(length(raw),2);
ETCO2 = nan(length(raw),2);
FIO2 = nan(length(raw),2);
SPO2 = nan(length(raw),2);
PEEP_CPAP = nan(length(raw),2);
Pulse = nan(length(raw),2);
Resp = nan(length(raw),2);
Temp = nan(length(raw),2);
Ve = nan(length(raw),2);
Vt = nan(length(raw),2);
Height = nan(length(raw),2);
Weight = nan(length(raw),2);

for i = 1:length(raw)
    if strcmp(raw{i,6},'ABP') || strcmp(raw{i,6},'Arterial line BP (ABP)')
        split = strsplit(raw{i,7},'/');
        ABP(i,1) = str2double(split{1,1});
        ABP(i,2) = str2double(split{1,2});
        ABP(i,3) = raw{i,9};
        
    elseif strcmp(raw{i,6},'BP')
        split = strsplit(raw{i,7},'/');
        BP(i,1) = str2double(split{1,1});
        BP(i,2) = str2double(split{1,2});
        BP(i,3) = raw{i,9};
        
    elseif strcmp(raw{i,6},'NIBP')
        split = strsplit(raw{i,7},'/');
        NIBP(i,1) = str2double(split{1,1});
        NIBP(i,2) = str2double(split{1,2});
        NIBP(i,3) = raw{i,9};    
        
    elseif strcmp(raw{i,6},'HR (ECG)')
        Heart_Rate(i,1) = str2double(raw{i,7});
        Heart_Rate(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'MAP') || strcmp(raw{i,6},'MAP (mmHg)') || strcmp(raw{i,6},'Arterial line MAP (mmHG)')
        MAP(i,1) = str2double(raw{i,7});
        MAP(i,2) = raw{i,9};  
        
    elseif strcmp(raw{i,6},'NBP m') || strcmp(raw{i,6},'Non-invasive BP mean (mmHG)')
        NBP_mean(i,1) = str2double(raw{i,7});
        NBP_mean(i,2) = raw{i,9};
    
    elseif strcmp(raw{i,6},'O2 Flow (L/min)')
        O2_Flow(i,1) = str2double(raw{i,7});
        O2_Flow(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'ETCO2')
        ETCO2(i,1) = str2double(raw{i,7});
        ETCO2(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'FiO2 (%)')
        FIO2(i,1) = str2double(raw{i,7});
        FIO2(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'SpO2')
        SPO2(i,1) = str2double(raw{i,7});
        SPO2(i,2) = raw{i,9};  
        
    elseif strcmp(raw{i,6},'PEEP/CPAP')
        PEEP_CPAP(i,1) = str2double(raw{i,7});
        PEEP_CPAP(i,2) = raw{i,9};       
        
    elseif strcmp(raw{i,6},'Pulse')
        Pulse(i,1) = str2double(raw{i,7});
        Pulse(i,2) = raw{i,9};     
        
    elseif strcmp(raw{i,6},'Temp')
        Temp(i,1) = str2double(raw{i,7});
        Temp(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'Resp') || strcmp(raw{i,6},'Resp Rate (Set)') || strcmp(raw{i,6},'RR (ventilator)')
        Resp(i,1) = str2double(raw{i,7});
        Resp(i,2) = raw{i,9};    
        
    elseif strcmp(raw{i,6},'Ve')
        Ve(i,1) = str2double(raw{i,7});
        Ve(i,2) = raw{i,9}; 
        
    elseif strcmp(raw{i,6},'Vt (expiratory observed)')
        Vt(i,1) = str2double(raw{i,7});
        Vt(i,2) = raw{i,9};    
    
    elseif strcmp(raw{i,6},'Height')
        Height(i,1) = str2double(raw{i,7});
        Height(i,2) = raw{i,9};
        
    elseif strcmp(raw{i,6},'Weight')
        Weight(i,1) = str2double(raw{i,7});
        Weight(i,2) = raw{i,9};    
        
    end
end

% Plot up stuff (uncomment stuff to show the plot)
ABP(~any(~isnan(ABP),2),:) = [];
ABP = sortrows(ABP,3);
AllData.ABP = ABP;
%figure
%plot(ABP(:,3),ABP(:,1),'-b')
%hold on
%plot(ABP(:,3),ABP(:,2),'-r')
%xlabel('Time after admission (hr)')
%ylabel('Arterial BP')
%legend('Systolic BP','Diastolic BP')
%title(strcat('ABP (Pt #',Patient_IDs{j},')')) 

BP(~any(~isnan(BP),2),:) = [];
BP = sortrows(BP,3);
AllData.BP = BP;
%figure
%plot(BP(:,3),BP(:,1),'-b')
%hold on
%plot(BP(:,3),BP(:,2),'-r')
%xlabel('Time after admission (hr)')
%ylabel('BP')
%legend('Systolic BP','Diastolic BP')
%title(strcat('BP (Pt #',Patient_IDs{j},')')) 

NIBP(~any(~isnan(NIBP),2),:) = [];
NIBP = sortrows(NIBP,3);
AllData.NIBP = NIBP;
%figure
%plot(NIBP(:,3),NIBP(:,1),'ob')
%hold on
%plot(NIBP(:,3),NIBP(:,2),'or')
%xlabel('Time after admission (hr)')
%ylabel('NIBP')
%legend('Systolic BP','Diastolic BP')
%title(strcat('NIBP (Pt #',Patient_IDs{j},')')) 

Heart_Rate(~any(~isnan(Heart_Rate),2),:) = [];
AllData.Heart_Rate = Heart_Rate;
figure
plot(Heart_Rate(:,2),Heart_Rate(:,1),'o')
xlabel('Time after admission (hr)')
ylabel('Heart Rate')
title(strcat('Heart Rate (Pt #',Patient_IDs{j},')')) 

MAP(~any(~isnan(MAP),2),:) = [];
AllData.MAP = MAP;
%figure
%plot(MAP(:,2),MAP(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('MAP')
%title(strcat('MAP (Pt #',Patient_IDs{j},')')) 

NBP_mean(~any(~isnan(NBP_mean),2),:) = [];
AllData.NBP_mean = NBP_mean;
%figure
%plot(NBP_mean(:,2),NBP_mean(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('NBP Mean')

O2_Flow(~any(~isnan(O2_Flow),2),:) = [];
AllData.O2_Flow = O2_Flow;
%figure
%plot(O2_Flow(:,2),O2_Flow(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('O2 Flow')

ETCO2(~any(~isnan(ETCO2),2),:) = [];
AllData.ETCO2 = ETCO2;
%figure
%plot(ETCO2(:,2),ETCO2(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('ETCO2')

FIO2(~any(~isnan(FIO2),2),:) = [];
AllData.FIO2 = FIO2;
%figure
%plot(FIO2(:,2),FIO2(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('FIO2')

SPO2(~any(~isnan(SPO2),2),:) = [];
AllData.SPO2 = SPO2;
%figure
%plot(SPO2(:,2),SPO2(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('SPO2')

PEEP_CPAP(~any(~isnan(PEEP_CPAP),2),:) = [];
AllData.PEEP_CPAP = PEEP_CPAP;
%figure
%plot(PEEP_CPAP(:,2),PEEP_CPAP(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('PEEP/CPAP')

Pulse(~any(~isnan(Pulse),2),:) = [];
AllData.Pulse = Pulse;
%figure
%plot(Pulse(:,2),Pulse(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Pulse')

Temp(~any(~isnan(Temp),2),:) = [];
AllData.Temp = Temp;
%figure
%plot(Temp(:,2),Temp(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Temp')

Resp(~any(~isnan(Resp),2),:) = [];
AllData.Resp = Resp;
%figure
%plot(Resp(:,2),Resp(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Resp Rate')

Ve(~any(~isnan(Ve),2),:) = [];
AllData.Ve = Ve;
%figure
%plot(Ve(:,2),Ve(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Ve')

Vt(~any(~isnan(Vt),2),:) = [];
AllData.Vt = Vt;
%figure
%plot(Vt(:,2),Vt(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Vt')

Height(~any(~isnan(Height),2),:) = [];
AllData.Height = Height;
%figure
%plot(Height(:,2),Height(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Height')

Weight(~any(~isnan(Weight),2),:) = [];
AllData.Weight = Weight;
%figure
%plot(Weight(:,2),Weight(:,1),'o')
%xlabel('Time after admission (hr)')
%ylabel('Weight')

end
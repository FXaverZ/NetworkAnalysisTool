clear;
% load database settings (aus EDLEM Datenbank):
load([pwd,filesep,'EDLEM_Datenbank.mat']);

max_num_timepoints = [];
rad_data = cell(1,3);
allo_mo = [];
for i=1:numel(setti.seasons)
	rad_data{i}=load([pwd,filesep,'Gene',files.sep,setti.seasons{i},...
		files.sep,'Solar',files.sep,'Radiation.mat']);
	Content = rad_data{i}.Content;
	max_num_timepoints(end+1) = Content.max_num_Datapoints; %#ok<SAGROW>
	mo = Content.allo_mo.(setti.seasons{i});
	for j = 1:numel(mo)
		allo_mo(1,end+1) = mo(j); %#ok<SAGROW>
		allo_mo(2,end) = i;
	end
end
max_num_timepoints = max(max_num_timepoints);
[~, IX] = sort(allo_mo(1,:));

% Aufbau des Arrays für geneigte Flächen (fix montiert, 'radiation_data_fix'):
% 1. Dimension: Monat innerhalb einer Jahreszeit (je 4 Monate)
% 2. Dimension: Orientierung z.B. [-15°, 0°, 15°] (0° = Süd; -90° = Ost)
% 3. Dimension: Neigung [15°, 30°, 45°, 60°, 90°] (0°  = waagrecht,
%                                                        90° = senkrecht,
%                                                        trac = Tracker)
% 4. Dimension: Datenart [Zeit, Temperatur in °C, Direkt in W/m^2, Diffus in W/m^2]
% 5. Dimension: Werte 

radiation_data_fix = zeros(0,3,5,4,max_num_timepoints);
for i=1:size(allo_mo,2)
	idx_rad = allo_mo(2,IX(i));
	idx_mon = find(rad_data{idx_rad}.Content.allo_mo.(setti.seasons{idx_rad}) == allo_mo(1,IX(i)));
	radiation_data_fix(end+1,:,:,:,:) = rad_data{idx_rad}.radiation_data_fix(idx_mon,:,:,:,:); %#ok<SAGROW>
end

figure; surf(squeeze(radiation_data_fix(1:12,1,1,3,:)));

T = round(0:1:24*60)/(24*60);
radiation_data_fix_new = zeros(size(radiation_data_fix,1),3,5,4,numel(T));
% Ausgabemeshgrid
[~,~,Tmg] = meshgrid(Content.inclina, Content.orienta, T);
for i=1:size(radiation_data_fix,1)
	t = squeeze(radiation_data_fix(i,1,1,1,:));
	t = t(t>0);
	
	% Daten auslesen:
	data_1 = squeeze(radiation_data_fix(i,:,:,2,t>0));
	data_2 = squeeze(radiation_data_fix(i,:,:,3,t>0));
	data_3 = squeeze(radiation_data_fix(i,:,:,4,t>0));
% 	plot(squeeze(data_2(1,1,:)));
	% Meshgrid erzeugen, mit den Basisvektoren:
	Ti = round((t(1):1/(24*60):t(end))*24*60)/(24*60);
	[x,y,t] = meshgrid(Content.inclina, Content.orienta, t);
	[X,Y,Tm] = meshgrid(Content.inclina, Content.orienta, Ti);
	
	data_1_int = interp3(x,y,t,data_1,X,Y,Tm,'linear');
	data_2_int = interp3(x,y,t,data_2,X,Y,Tm,'spline');
	data_3_int = interp3(x,y,t,data_3,X,Y,Tm,'spline');
	
	% negative Werte zu Null setzen (Überschwingen der Interpolation)
	data_1_int(data_1_int < 0) = 0;
	data_2_int(data_2_int < 0) = 0;
	data_3_int(data_3_int < 0) = 0;
% 	plot(squeeze(data_2_int(1,1,:)));
	
	radiation_data_fix_new(i,:,:,1,:) = Tmg;
	radiation_data_fix_new(i,:,:,2,find(Ti(1)==T):find(Ti(end)==T)) = data_1_int;
	radiation_data_fix_new(i,:,:,3,find(Ti(1)==T):find(Ti(end)==T)) = data_2_int;
	radiation_data_fix_new(i,:,:,4,find(Ti(1)==T):find(Ti(end)==T)) = data_3_int;
end

radiation_data_fix = radiation_data_fix_new;
figure; surf(squeeze(radiation_data_fix(1:12,1,1,4,1:15:end)));

radiation_data_fix_new = zeros(365,3,5,4,numel(T));
for i=1:numel(T)
	% Daten auslesen:
	data_1 = squeeze(radiation_data_fix(:,:,:,2,i));
	data_ext = zeros(14,3,5);
	data_ext(3:14,:,:) = data_1;
	data_ext(2,:,:) = data_1(12,:,:);
	data_ext(1,:,:) = data_1(11,:,:);
	data_ext(15,:,:) = data_1(1,:,:);
	data_ext(16,:,:) = data_1(2,:,:);
	data_1 = data_ext;
	data_2 = squeeze(radiation_data_fix(:,:,:,3,i));
	data_ext = zeros(14,3,5);
	data_ext(3:14,:,:) = data_2;
	data_ext(2,:,:) = data_2(12,:,:);
	data_ext(1,:,:) = data_2(11,:,:);
	data_ext(15,:,:) = data_2(1,:,:);
	data_ext(16,:,:) = data_2(2,:,:);
	data_2 = data_ext;
	data_3 = squeeze(radiation_data_fix(:,:,:,4,i));
	data_ext = zeros(14,3,5);
	data_ext(3:14,:,:) = data_3;
	data_ext(2,:,:) = data_3(12,:,:);
	data_ext(1,:,:) = data_3(11,:,:);
	data_ext(15,:,:) = data_3(1,:,:);
	data_ext(16,:,:) = data_3(2,:,:);
	data_3 = data_ext;
% 	plot(squeeze(data_2(:,1,1)));
	
	Ti = datenum('01.11.2012','dd.mm.yyyy'):1:datenum('28.02.2014','dd.mm.yyyy');
	t = Ti([14, 44, 75, 105, 134, 165, 195, 226, 256, 287, 318, 348, 379, 409, 440, 470]);
	Ti = datenum('01.01.2013','dd.mm.yyyy'):1:datenum('31.12.2013','dd.mm.yyyy');
	[y,t,x] = meshgrid(Content.orienta, t, Content.inclina);
	[Y,Tm,X] = meshgrid(Content.orienta, Ti, Content.inclina);
	
	data_1_int = interp3(y,t,x,data_1,Y,Tm,X,'linear');
	data_2_int = interp3(y,t,x,data_2,Y,Tm,X,'spline');
	data_3_int = interp3(y,t,x,data_3,Y,Tm,X,'spline');
	data_2_int(data_2_int < 0) = 0;
	data_3_int(data_3_int < 0) = 0;
% 	plot(squeeze(data_2_int(:,1,1)));
	
	radiation_data_fix_new(:,:,:,1,i)=T(i);
	radiation_data_fix_new(:,:,:,2,i)=data_1_int;
	radiation_data_fix_new(:,:,:,3,i)=data_2_int;
	radiation_data_fix_new(:,:,:,4,i)=data_3_int;
end

figure; radiation_data_fix = radiation_data_fix_new;
clear radiation_data_fix_new;
surf(squeeze(radiation_data_fix(1:2:end,1,1,3,1:30:end)));

save([pwd,filesep,'Gene',files.sep,'Solar',files.sep,'Radiation.mat'], 'radiation_data_fix', 'Content');

clear all
close all
%% GEOMETRY PARAMETERS
asmb = 17;    %assembly size
core = 3;     %core size
moderator = 1; %surrounding moderator "core"
zlayer = 32;  %number of layers in z-axial

tstep = 1;    %number of time steps printed in this file
timestep = 0.25;

showintermediate = 0; %plot results while reading
showplot = 1;         %plot results after reading

%% Axial Location
AxialLocation = zeros(zlayer,1); % top and down water/reflector 4 layers each
for i = 1:zlayer
    AxialLocation(i) = (i-4) * 5.355;
end

%% OPEN TXT FILE
fid = fopen('TDW2b.txt','r'); %change the txt file name if needed
if fid < 0 
    disp('failed to open the file to read');
end

datafilename = 'TDW2b_Data.dat'; % write to this file
wid = fopen(datafilename,'w');
if wid < 0 
    disp('failed to open the file to write');
end
%% READ THE FIRST PART: The Normalized Pin Power in Core
NormPinPower = zeros(asmb*core, asmb*core);

tline = fgetl(fid);
while ischar(tline) && contains(tline, "ID") == 0
    disp(tline) %screen print line just read from input
    tline = fgetl(fid);
end

disp(tline)

for i = 1:core
    for j = 1:core
        tline = fgetl(fid);
        while contains(tline, "ID") == 1
            disp(tline)
            tline = fgetl(fid);
        end
        a = 1;
        while ischar(tline) && tline ~= ""
            disp(tline)
            t = split(tline);
            v = str2double(t(end-asmb+1:end));
            NormPinPower(asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j) = v';
            if showintermediate
                figure(1)
                surface(NormPinPower, 'EdgeColor','none'); 
                xlim([1, asmb*core+1]);
                ylim([1, asmb*core+1]);
                colorbar
                pause(0.001);
            end
            a = a + 1;
            tline = fgetl(fid);
        end
    end
end

if showplot
    figure(2)
    colormap jet
    surface(NormPinPower, 'EdgeColor','none')
    title('NormPinPower');
    xlim([1, asmb*core+1]);
    ylim([1, asmb*core+1]);
    colorbar
    pause(1);
end

%% READ THE SECOND PART: The Normalized Pin Power Per Layer
NormPinPowerLayer = zeros(asmb*core, asmb*core, zlayer);
AsmbPowerCoreLayer = zeros(core, core, zlayer);

for z = 1:zlayer
    tline = fgetl(fid);
    while ischar(tline) && contains(tline, "ID") == 0
        disp(tline)
        tline = fgetl(fid);
    end
    
    for i = 1:core
        for j = 1:core
            tline = fgetl(fid);
            while tline == "" || contains(tline, "ID") == 1 || contains(tline, "Layer") == 1
                disp(tline)
                tline = fgetl(fid);
            end
            a = 1;
            while ischar(tline) && tline ~= ""
                disp(tline)
                t = split(tline);
                v = str2double(t(end-asmb+1:end));
                NormPinPowerLayer(asmb*(i-1)+a, asmb*(j-1)+1 : asmb*j, z) = v';
                a = a + 1;
                tline = fgetl(fid);
            end
        end
    end
    
    %tline = fgetl(fid);
    while tline == "" || contains(tline, "*") == 1
        disp(tline)
        tline = fgetl(fid);
    end
    for i = 1:core
        disp(tline)
        t = split(tline);
        v = str2double(t(end-core+1:end));
        AsmbPowerCoreLayer(i, :, z) = v';
        tline = fgetl(fid);
    end
end

if showplot
    figure(4)
    colormap jet
    diff = double(squeeze(NormPinPowerLayer));
%     diff(diff==0)=nan;
    h = slice(diff, 1:size(diff,2), 1:size(diff,1), 1:size(diff,3));
    set(h, 'EdgeColor','none', 'FaceColor','interp')
    title('NormPinPowerLayer')
    colorbar
    alpha(.1)
    pause(1);
    
    figure(5)
    colormap jet
%   isosurface(AsmbPowerCoreLayer,'EdgeColor','none'); 
    diff = double(squeeze(AsmbPowerCoreLayer));
%     diff(diff==0)=nan;
    h = slice(diff, 1:size(diff,2), 1:size(diff,1), 1:size(diff,3));
    set(h, 'EdgeColor','none', 'FaceColor','interp')
    title('AsmbPowerCoreLayer')
    alpha(.1)
    colorbar
    pause(1);
end

%% READ THE THIRD PART: The Normalized Assembly Power for Core
NormAssmPowerCore = zeros(core, core);

while tline == "" || contains(tline, "*") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = 1:core
    disp(tline)
    t = split(tline);
    v = str2double(t(end-core+1:end));
    NormAssmPowerCore(i, :) = v';
    tline = fgetl(fid);
end
if showplot
    figure(6)
    colormap jet
    surface(NormAssmPowerCore, 'EdgeColor','none'); 
    title('NormAssmPowerCore')
    colorbar
    pause(1);
end

%% READ THE FOURTH PART: The Axial Power Distribution for Assembly
AxialPowerAssm = zeros(core*core, zlayer);

while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = zlayer:-1:1
    disp(tline)
    t = split(tline);
    v = str2double(t(end-core*core+1:end));
    AxialPowerAssm(:, i) = v';
    tline = fgetl(fid);
end
if showplot
    figure(7)
    colormap jet
    surface(AxialPowerAssm', 'EdgeColor','none');
    title('AxialPowerAssm')
    colorbar
    pause(1);
end

%% READ THE FIFTH PART: The Axial Power Distribution for Core
AxialPowerCore = zeros(zlayer, 2);

while tline == "" || contains(tline, "*") == 1 || contains(tline, "Assembly") == 1
    disp(tline)
    tline = fgetl(fid);
end
for i = zlayer:-1:1
    disp(tline)
    t = split(tline);
    v = str2double(t(end));
    AxialPowerCore(i, 1) = i;
    AxialPowerCore(i, 2) = v;
    tline = fgetl(fid);
end
if showplot
    figure(8)
    plot(AxialPowerCore(:,1), AxialPowerCore(:,2),'r', 'LineWidth',1.2)
    xlabel('axial layer')
    ylabel('Axial Power Distribution')
    view(90,-90)
    pause(1);
end

disp("finish reading")

%% Organizing data according to template
% Assembly fission rate ==> AsmbPowerCoreLayer
fprintf(wid, '%s\t\n', 'Assembly fission rate');
for i = 1:tstep
    time = (i-1) * timestep;
    fprintf(wid, '\t%s\t%f','Time [s]', time);
end
fprintf(wid, '\n%s\t','Axial location [cm]');
for i = 1:tstep
    fprintf(wid, '%s\t%s\t%s\t','Row\Column', '1','2');
end
fprintf(wid,'\n');
for z = zlayer:-1:1 
    for j = 1 : core-moderator
        fprintf(wid, '%f\t', AxialLocation(z));
        for t = 1:tstep
            fprintf(wid, '%s\t', int2str(j));
            for i = 1 : core-moderator
                fprintf(wid, '%f\t', AsmbPowerCoreLayer(j,i,z));
            end
        end
        fprintf(wid,'\n');
    end
end
% pin fission rate ==> NormPinPowerLayer
fprintf(wid, '%s\t\n', 'pin fission rate');
for t = 1:tstep
    time = (t-1) * timestep;
    fprintf(wid, '\t%s\t%f','Time [s]', time);
    
    fprintf(wid, '\n%s\t%s\t','Axial location [cm]', 'Row\Column');
    for j = 1:core-moderator
        for k = 1: asmb
            fprintf(wid, '%s\t', int2str((j-1)*asmb+k));
        end
    end
    fprintf(wid, '\n');
    for z = zlayer:-1:1 
        for j = 1 : (core-moderator)*asmb
            fprintf(wid, '%f\t%s\t', AxialLocation(z), int2str(j));
            for k = 1 : (core-moderator)*asmb
                fprintf(wid, '%f\t', NormPinPowerLayer(j,k,z));
            end
            fprintf(wid,'\n');
        end
    end
end

disp("finish writing")
%% CLOSE READ/WRITE FILE
fclose(fid);
fclose(wid);
disp("finish closing files")

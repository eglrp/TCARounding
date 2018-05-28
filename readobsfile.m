function[obsdata]=readobsfile
% ��ȡ�۲��ļ����û����ջ���
NAVfilepath = '.\cut01680.16o';
fid      = fopen(NAVfilepath);
while ~feof(fid)   %feof��δ��������0ֵ
    line = fgetl(fid);
    if strfind(line,'END OF HEADER'),break;end %% �����ļ�ͷ
end


obsdata = NaN; 
epochnum = 0;
% ��ȡ����ʱ��
while ~feof(fid)    
line = fgetl(fid);
epochnum = epochnum +1;
dataline = sscanf(line(2:end),'%f');
timeutc = dataline(1:6);
gpst = cal2gps(timeutc);
gpst(2)=gpst(2)-14; %����ʱ
shu = dataline(8);  %��ʱ��������Ŀ
gpsobs = 0;         %�����ļ���ÿ����Ԫ�е������ܸ���
%% ����������Ŀ��ȡ��Ϣ
for a=1:shu
% �����������
    line = fgetl(fid);
    linechang=length(line);
     if linechang<193
        line(linechang+1:193)=0;
     end
    
    c2 = str2double(line(5:17));
    l2 = str2double(line(20:33));
    c7 = str2double(line(53:65));
    l7 = str2double(line(68:81));
    c6 = str2double(line(101:113));
    l6 = str2double(line(117:129));

    cada = line(1);
    if (cada=='C')
        if(isnan(c2)||isnan(l2)||isnan(c7)||isnan(l7)||isnan(c6)||isnan(l6))
            continue;
        end
    end
    
   
%% ��ȡ�۲�����
    if line(1)=='C'
        gpsobs=gpsobs+1;
        obsdata.epoch(epochnum).gps(gpsobs).bdst =gpst;
        obsdata.epoch(epochnum).gps(gpsobs).gpst =(gpst(1)*604800+gpst(2));% �û����ջ����ջ��źŽ���ʱ��tu
        obsdata.epoch(epochnum).gps(gpsobs).prn = str2double(line(2:3));   % �û����յ�����prn��
        obsdata.epoch(epochnum).gps(gpsobs).C2I = str2double(line(5:17));  % �û����յ�����α����C1L
        obsdata.epoch(epochnum).gps(gpsobs).L2I = str2double(line(20:33)); % �û����ܵ������ز���λL1C
               
        obsdata.epoch(epochnum).gps(gpsobs).C7I = str2double(line(53:65));
        obsdata.epoch(epochnum).gps(gpsobs).L7I = str2double(line(68:81));
        %obsdata.gps(obsnum).S2W = str2double(line(91:97));
        obsdata.epoch(epochnum).gps(gpsobs).C6I = str2double(line(101:113));
        obsdata.epoch(epochnum).gps(gpsobs).L6I = str2double(line(117:129));
        %obsdata.gps(obsnum).S2X = str2double(line(139:145));
        %obsdata.gps(obsnum).C5Q = str2double(line(149:161));
        %obsdata.gps(obsnum).L5Q = str2double(line(165:177));
        %obsdata.gps(obsnum).S5Q = str2double(line(187:193));
        
        
        %if (obsdata.epoch(epochnum).gps(gpsobs).prn == 13)
        %    gpsobs=gpsobs-1;
        %end
    elseif line(1)=='R'
        
    elseif line(1)=='C'
        
    elseif line(1)=='E'
        
    elseif line(1)=='L'
        
    end
obsdata.epoch(epochnum).gpsobs= gpsobs;
end
end
fclose(fid); 
              
end
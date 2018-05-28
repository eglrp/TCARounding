function[navdata]=readnavfile
% ��ȡ����[navdata]=readnavfile�ļ�
navfilepath = '.\cuta1680.16p';
fid      = fopen(navfilepath);%�򿪵����ļ���1680.14p'
navnum = 0; %�����ļ��е������ܸ���
navdata = NaN; %�����ļ���ȡ������Ϊ��
% ����ͷ�ļ�
while ~feof(fid)                                                           %feof��δ��������0ֵ
    line = fgetl(fid);
    if strcmp(line(61:73),'END OF HEADER'),break;end %% �����ļ�ͷ
end
% ���ж�ȡ��������
while ~feof(fid) %�ж��Ƿ�����ļ�βʱ
    line = fgetl(fid);
    if line(1) == 'C' %�ж��Ƿ������ǵĳ�ʼ��
         navnum = navnum+1;
% ��ȡ�������ݵ�һ��
         dataline = sscanf(line(2:end),'%e'); %����һ�а����ַ�����ȡ
         navdata.gps(navnum).prn = dataline(1); %��ȡ�������
         utctime = dataline(2:7); %��ȡ����ʱ��
         gpst = cal2gps(utctime); %������GPSʱ��ת����GPS�ܺ����ڵ���
         gpst(2)=gpst(2)-14;   %����ʱ
         navdata.gps(navnum).bdst=gpst;
         navdata.gps(navnum).gpst = (gpst(1)*604800+gpst(2)); %���Ƿ����ź�ʱ��ת����UTCʱ�� (����ʱ��)
         navdata.gps(navnum).af0 = dataline(8); %ƫ��svClkBias=af0
         navdata.gps(navnum).af1 = dataline(9); %Ư��svClkDrf=af1
         navdata.gps(navnum).af2 = dataline(10); %Ư���ٶ�svDrfRate=af2
 % ��ȡ�������ݵڶ���
         line = fgetl(fid);
         dataline = sscanf(line,'%e'); %�����а����ַ�����ȡ
         navdata.gps(navnum).idoe = dataline(1); %���ݡ���������ʱ��
         navdata.gps(navnum).Crs = dataline(2); %Crs
         navdata.gps(navnum).deltn =dataline(3); %deltn
         navdata.gps(navnum).Mo = dataline(4);%Mo
% ��ȡ�������ݵ�����
         line = fgetl(fid);
         dataline = sscanf(line,'%e'); %�����а����ַ�����ȡ
         navdata.gps(navnum).Cuc = dataline(1); %Cuc
         navdata.gps(navnum).es = dataline(2); %es
         navdata.gps(navnum).Cus =dataline(3); %Cus
         navdata.gps(navnum).sqrtas = dataline(4); %sqrtas
% ��ȡ�������ݵ�����
         line = fgetl(fid);
         dataline = sscanf(line,'%e'); %�����а����ַ�����ȡ
         navdata.gps(navnum).toe = dataline(1); %�����ο�ʱ��toe
         navdata.gps(navnum).Cic = dataline(2); %Cic
         navdata.gps(navnum).OMGAo =dataline(3); %OMGAo
         navdata.gps(navnum).Cis = dataline(4); %Cis
% ��ȡ�������ݵ�����
         line = fgetl(fid);
         dataline = sscanf(line,'%e'); %�����а����ַ�����ȡ
         navdata.gps(navnum).io = dataline(1); %io
         navdata.gps(navnum).Crc = dataline(2); %Crc
         navdata.gps(navnum).w =dataline(3); %w
         navdata.gps(navnum).dtOMGA = dataline(4); %dtOMGA
% ��ȡ�������ݵ�����
         line = fgetl(fid);
         dataline = sscanf(line,'%e'); %�����а����ַ�����ȡ
         navdata.gps(navnum).dti = dataline(1); %dti
         navdata.gps(navnum).L2 = dataline(2); %L2�ϵ���
         navdata.gps(navnum).GPSWeek =dataline(3); %GPS����
         navdata.gps(navnum).L2P = dataline(4); %L2P���ݱ�־
% ��ȡ�������ݵ����� 
         line = fgetl(fid);
         dataline = sscanf(line,'%e');
         navdata.gps(navnum).SVaccuracy = dataline(1);%���Ǿ���
         navdata.gps(navnum).SVhealth= dataline(2);%���ǽ���״̬
         navdata.gps(navnum).TGD = dataline(3); %TGD
         navdata.gps(navnum).IODC= dataline(4);%IODC�ӵ���������
% ��ȡ�������ݵڰ���
         line = fgetl(fid);
         dataline = sscanf(line,'%e');
         navdata.gps(navnum).Ttime = dataline(1);%���ķ���ʱ��
         if(navdata.gps(navnum).SVhealth==1)
            navnum=navnum-1;
        end
    end
end
fclose(fid); 
end
function[BASEprn,EWLb,basenum,xbs,ybs,zbs,rb,Base]=BASESateposAndC1c(navdata,basedata,x0,S,m)
% �������ǵ����꼰���ջ�α��

a1=m;
basenum=0;
match = 0;%�ж������Ƿ�ƥ��

for a2=1:basedata.epoch(a1).gpsobs
    for a3=1:length(navdata.gps)
        if(basedata.epoch(a1).gps(a2).prn==navdata.gps(a3).prn)
            tk = (basedata.epoch(a1).gps(a2).bdst(1)-navdata.gps(a3).bdst(1))*604800 + ...
                basedata.epoch(a1).gps(a2).bdst(2)-navdata.gps(a3).toe - basedata.epoch(a1).gps(a2).C2I/299792458;
            if(tk > 302400)
                tk = tk - 604800;
            elseif (tk<-302400)
                tk = tk + 604800;
            end
            if abs(basedata.epoch(a1).gps(a2).gpst-navdata.gps(a3).gpst)<7200,break;end
        end
        
        %% ��ƥ�䵼���ļ�
        if(a3 == length(navdata.gps)),match = 1;end
    end
    if(match==1)
        match=0;
        continue;
    end
    
    num = navdata.gps(a3).prn;
    toe=navdata.gps(a3).toe;
    t=basedata.epoch(a1).gps(a2).gpst-basedata.epoch(a1).gps(a2).C2I/299792458;
    as=(navdata.gps(a3).sqrtas)^2;
    es=navdata.gps(a3).es;
    io=navdata.gps(a3).io;
    OMGAo=navdata.gps(a3).OMGAo;
    w=navdata.gps(a3).w;
    Mo=navdata.gps(a3).Mo;
    deltn=navdata.gps(a3).deltn;
    dti=navdata.gps(a3).dti;
    dtOMGA=navdata.gps(a3).dtOMGA;
    Cuc=navdata.gps(a3).Cuc;
    Cus=navdata.gps(a3).Cus;
    Crc=navdata.gps(a3).Crc;
    Crs=navdata.gps(a3).Crs;
    Cic=navdata.gps(a3). Cic;
    Cis=navdata.gps(a3).Cis;
    dtOMGAe = 7.2921150e-5;%������ת���ٶ�
    GM=3.986004418e+14;
    
    %  1.����黯ʱ��tk
    
    %  2.�������ǵ�ƽ�����ٶ�
    no=sqrt(GM/(as^3));
    n=no+deltn;
    
    %  3.�����źŷ���ʱ��ƽ����Mk
    Mk=Mo+n*tk;
    while(Mk<0||Mk>2*pi)
        if(Mk<0)
            Mk=Mk+2*pi;
        else
            Mk=Mk-2*pi;
        end
    end
    
    %  4.�����źŷ���ʱ�̵�ƫ����E
    Ek=Mk;
    while (1)
        E0=Ek;
        Ek = Mk + es * sin(E0);
        if(abs(Ek-E0)<1e-12)
            break;
        end
    end
    
    %  5.�����źŷ���ʱ�̵�������vk
    cosvk=((cos(Ek)-es)/(1-es*cos(Ek)));
    sinvk=(sqrt(1-es^2))*sin(Ek)/(1-es*cos(Ek));
    vk=atan2(sinvk,cosvk);
    
    %  6.�����źŷ���ʱ�̵�������Ǿ�Faik
    Faik=vk+w;
    
    %  7.�����źŷ���ʱ�̵��㶯У����Deltuk,Deltrk,Deltik
    Deltuk=Cus*sin(2*Faik)+Cuc*cos(2*Faik);
    Deltrk=Crs*sin(2*Faik)+Crc*cos(2*Faik);
    Deltik=Cis*sin(2*Faik)+Cic*cos(2*Faik);
    
    %  8.�����㶯У�����������Ǿ�uk������ʸ������rk��ik
    uk=Faik+Deltuk;
    rk=as*(1-es*cos(Ek))+Deltrk;
    ik=io+dti*tk+Deltik;
    
    %   9.�����źŷ���ʱ�������ڹ��ƽ���λ�ã�xk1,yk1��
    xk1=rk*cos(uk);
    yk1=rk*sin(uk);
    
    % 10.�����źŷ���ʱ�̵�������ྭOMGAk
    OMGAk=OMGAo+(dtOMGA-dtOMGAe)*tk-dtOMGAe*toe;
    
    % 11.����������WGS-84���ĵع�ֱ������ϵ��Xt,Yt,Zt���е����꣨xk,yk,zk��
    X=xk1*cos(OMGAk)-yk1*cos(ik)*sin(OMGAk);
    Y=xk1*sin(OMGAk)+yk1*cos(ik)*cos(OMGAk);
    Z=yk1*sin(ik);
    
    % �ж�������GEO���ǻ���MEO/IGSO����
    if num<6
       n1 = 5/180*pi;  %geo��ת�ǶȻ���
            pos = [cos(dtOMGAe*tk)  sin(dtOMGAe*tk)  0;....
                -sin(dtOMGAe*tk) cos(dtOMGAe*tk)  0;
                0   0  1 ]*[1 0 0;0 cos(-n1)  sin(-n1);0 -sin(-n1) cos(-n1)] ...
                *[cos(-dtOMGAe*tk)  sin(-dtOMGAe*tk)  0;....
                -sin(-dtOMGAe*tk) cos(-dtOMGAe*tk)  0;0   0  1 ]*[X;Y;Z];
            X=pos(1);
            Y=pos(2);
            Z=pos(3);
    end
    
    % �ӷ���ʱ��ת��������ʱ������ϵ
    dw = dtOMGAe*(basedata.epoch(a1).gps(a2).C2I/299792458);%����ʱ��ת���ĽǶ�
    cw = cos(dw);sw = sin(dw);
    anglepos=[cw sw 0;-sw cw 0;0 0 1]*[X;Y;Z];
    
    
    
    
    % ����߶Ƚ� thet
    D = anglepos - x0;
    E = S * D;
    theta=asin(E(3)/sqrt(E(1)^2+E(2)^2+E(3)^2));
    
    if theta>(pi/18)
        basenum = basenum+1;
        
        % ����FCub(��u)���ڸ��Ե㴦�����ǵľ������վ�����Ǿ���Ru�����ǽǶ�theta
        Rtheta(basenum) =theta;
        xbs(basenum)=X;        %�����û����ջ�����õ�����������(xus,yus,zus)
        ybs(basenum)=Y;
        zbs(basenum)=Z;
        BASEprn(basenum) = num;
        rb(basenum)=sqrt((xbs(basenum)-x0(1))^2+(ybs(basenum)-x0(2))^2+(zbs(basenum)-x0(3))^2);
        
        c = 2.99792458e8;%����
        f1=1561.098e6;
        f2=1207.14e6;
        f3=1268.52e6;
        %% ��ͬƵ���µ�α�ࡢ�ز��۲����ͽ���RTK�ļ�����
        lamda = c/f1; %������1
        % α�ࡢ�ز��۲���
        EWLb.FCb1(basenum)=basedata.epoch(a1).gps(a2).L2I*lamda;
        EWLb.pcb1(basenum) = basedata.epoch(a1).gps(a2).C2I;
        % RTK�ļ�����
        Base.FCb1(basenum)=basedata.epoch(a1).gps(a2).L2I*lamda-rb(basenum);
        Base.pcb1(basenum) = basedata.epoch(a1).gps(a2).C2I-rb(basenum);
        
        % α�ࡢ�ز��۲���
        lamda = c/f2; %������2
        EWLb.FCb2(basenum)=basedata.epoch(a1).gps(a2).L7I*lamda;
        EWLb.pcb2(basenum) = basedata.epoch(a1).gps(a2).C7I;
        % RTK�ļ�����
        Base.FCb2(basenum)=basedata.epoch(a1).gps(a2).L7I*lamda-rb(basenum);
        Base.pcb2(basenum) = basedata.epoch(a1).gps(a2).C7I-rb(basenum);
        
        % α�ࡢ�ز��۲���
        lamda = c/f3; %������3
        EWLb.FCb3(basenum)=basedata.epoch(a1).gps(a2).L6I*lamda;
        EWLb.pcb3(basenum) = basedata.epoch(a1).gps(a2).C6I;
        % RTK�ļ�����
        Base.FCb3(basenum)=basedata.epoch(a1).gps(a2).L6I*lamda-rb(basenum);
        Base.pcb3(basenum) = basedata.epoch(a1).gps(a2).C6I-rb(basenum);
        
        
    end
    
    
    
end
end





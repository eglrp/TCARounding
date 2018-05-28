function[N,d,Qxn,Qn,NEWL,NWL1,N1,N2,N3,DOP]=DD(satnum,Ix,Iy,Iz,maxnum,fw,pw,EWL,FC,pc)
% ILS for AR and Solution for differenet combinations ambiguities

% *ʹ�õ�Casading Rounding AR �����У����ڽ����Ĺ۲ⷽ����Ĭ��ʹ�õ���-N������
%  ��֮ǰ�����Ĺ۲ⷽ���еĲ�ͬ�������õ�ģ���Ⱦ��Ǻ���ʵ��ģ�����෴*
% *ʽ�е��ز���λ�۲���������Ϊ��λ��*
dnum=0;
c = 2.99792458e8;%����
f1=1561.098e6;
f2=1207.14e6;
f3=1268.52e6;
lamda1 = c/f1;
lamda2 = c/f2;
lamda3 = c/f3;
% lamda = c/f1;        %������
for id=1:(satnum-1)
    dnum=dnum+1;
    if(dnum==maxnum),dnum=dnum+1;end
    G(id,1)=-(Ix(dnum)-Ix(maxnum));
    G(id,2)=-(Iy(dnum)-Iy(maxnum));
    G(id,3)=-(Iz(dnum)-Iz(maxnum));
    %��Ƶ��α�ࡢ�ز�˫�������
    H1(id,1)=pc(dnum)-pc(maxnum);
    H2(id,1)=FC(dnum)-FC(maxnum);
    
    %% ˫�����Ƶ��α�ࡢ�ز��۲�����1����α�࣬2�����ز�
    H11(id,1)=EWL.pc1(dnum)-EWL.pc1(maxnum);
    H21(id,1)=EWL.FC1(dnum)-EWL.FC1(maxnum);
    
    H12(id,1)=EWL.pc2(dnum)-EWL.pc2(maxnum);
    H22(id,1)=EWL.FC2(dnum)-EWL.FC2(maxnum);
    
    H13(id,1)=EWL.pc3(dnum)-EWL.pc3(maxnum);
    H23(id,1)=EWL.FC3(dnum)-EWL.FC3(maxnum);
    
    
    %%  ��ⳬ������ϵ�ģ���ȣ�ΪCascading rounding�����ĵ�һ��
    % *ʽ��HEWLΪ���(0,-1,1)���ز���λ�۲���??(0,-1,1)*
    lamdaEWL = c/(-f2+f3);
    HEWL(id,1) = (-H22(id,1)*f2+H23(id,1)*f3)/(-f2+f3);
    NEWL(id,1) = round((H13(id,1)- HEWL(id,1))/lamdaEWL);
    
    %%  ��������ϵ�ģ���ȣ�ΪCascading rounding�����ĵڶ���
    %  WL1��WL2�ֱ�Ϊ���(1,-1,0)��(1,0,-1)
    %  ʽ��HWL1��HWL2Ϊ���(1,-1,0)��(1,0,-1)���ز���λ�۲���??(1,-1,0)��??(1,0��-1)
    lamdaWL1 = c/(f1-f2);
    HWL1(id,1) = (H21(id,1)*f1-H22(id,1)*f2)/(f1-f2);
    NWL1(id,1) = round((lamdaEWL*NEWL(id,1)+HEWL(id,1)- HWL1(id,1))/lamdaWL1);
    
    lamdaWL2 = c/(f1-f3);
    HWL2(id,1) = (H21(id,1)*f1-H23(id,1)*f3)/(f1-f3);
    NWL2(id,1) = round((lamdaEWL*NEWL(id,1)+HEWL(id,1)- HWL2(id,1))/lamdaWL2);
    
    %%  ���ԭʼ��ģ���ȣ�ΪCascading rounding�����ĵ�����
    %  N1��N2��N3�ֱ�Ϊ����Ƶ���ϵ����ʼ��ģ����
    N1(id,1) = round((lamdaWL1*NWL1(id,1)+HWL1(id,1)- H21(id,1))/lamda1);
    N2(id,1) = N1(id,1)-NWL1(id,1);
    N3(id,1) = N1(id,1)-NWL2(id,1);
    for j=1:satnum-1
        if(id==j)
            Q1(id,j) = 2*(pw(id)+pw(maxnum));%α���Ȩ
            Q2(id,j) = 2*(fw(id)+fw(maxnum));%�ز���λ
        else
            Q1(id,j) = 2*pw(maxnum);%α���Ȩ
            Q2(id,j) = 2*fw(maxnum);%�ز���λ
        end
    end
end

%% ��ʹ�� Casading Rounding AR �����õ���ģ���Ƚ���ȡ���õ���ʵ��ģ����
N1 = -N1;
N2 = -N2;
N3 = -N3;


B=eye(satnum-1);
b=B*lamda1;
G1=zeros(satnum-1);
Q=[Q1,G1;G1,Q2];
C=inv(Q);
A=[G,G1;G,b];
H=[H11;H21];
X=(A'*A)\A'*H;
d = X(1:3);
N = X(4:satnum-1+3);
Qx = inv(A'*C*A);
Qn = Qx(4:satnum-1+3,4:satnum-1+3);   %ģ����N��Э�������
Qxn = Qx(1:3,4:satnum-1+3);           %����������ģ����N֮������ϵ����


DOP = (G'*G)';


end
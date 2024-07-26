function [ voltage, PW]  = bfs1(station_load)
Pg=zeros(33,1);
Qg=zeros(33,1);

m=[    1	0         0  	  0
    2	100+station_load       60 	  0
    3	90        40      0  	
    4	120       80	  0  
    5	60        30	  0  
    6	60        20      0 
    7	200       100	  0
    8	200       100	  0 
    9	60        20      0	
    10	60        20 	  0
    11	45        30 	  0
    12	60        35      0 
    13	60        35      0 
    14	120       80      0 
    15	60        10      0 
    16	60        20      0 
    17	60        20      0 
    18	90        40      0 
    19	90        40      0 
    20	90        40      0 
    21	90        40      0
    22	90        40      0 
    23	90        50      0
    24	420       200	  0
    25	420       200	  0
    26	60        25      0  
    27	60        25      0 
    28	60        20      0
    29	120       70      0
    30	200       600	  0
    31	150       70      0  
    32	210       100	  0
    33	60        40      0];

l=[       1    1      2     0.0922    0.0470   
          2    2      3     0.4930    0.2511    
          3    3      4     0.3660    0.1864  
          4    4      5     0.3811    0.1941    
          4    5      6     0.8190    0.7070    
          6    6      7     0.1872    0.6188   
          7    7      8     0.7114    0.2351 
          8    8      9     1.0300    0.7400   
          9    9      10    1.0440    0.7400   
         10    10     11    0.1966    0.0650   
         11    11     12    0.3744    0.1238   
         12    12     13    1.4680    1.1550   
         13    13     14    0.5416    0.7129   
         14    14     15    0.5910    0.5260    
         15    15     16    0.7463    0.5450   
         16    16     17    1.2890    1.7210   
         17    17     18    0.7320    0.5740  
         18     2     19    0.2640    0.2565    
         19    19     20    1.5042    1.3554  
         20    20     21    0.4095    0.4784   
         21    21     22    0.7089    0.9373    
         22     3     23    0.4512    0.3083    
         23    23     24    0.8980    0.7091  
         24    24     25    0.8960    0.7011   
         25     6     26    0.2030    0.1034   
         26    26     27    0.2842    0.1447    
         27    27     28    1.0590    0.9337    
         28    28     29    0.8042    0.7006   
         29    29     30    0.5075    0.2585  
         30    30     31    0.9744    0.9630   
         31    31     32    0.3105    0.3619   
         32    32     33    0.3410    0.5302];

br=length(l);
no=length(m);
f=0;
d=0;
MVAb=100;
KVb=12.66;
Zb=(KVb^2)/MVAb;
% Per unit Values
for i=1:br
    R(i,1)=(l(i,4))/Zb;
    X(i,1)=(l(i,5))/Zb;
end
for i=1:no
    P(i,1)=((m(i,2)-Pg(i))/(1000*MVAb));
    Pp(i,1)=m(i,2);
    Q(i,1)=((m(i,3)-Qg(i))/(1000*MVAb));
    Qq(i,1)=m(i,3);
end
Rpp = sum(Pp);
Qpp = sum(Qq);

Apparent_P = sqrt(Rpp^2 + Qpp^2);
PF = Rpp/Apparent_P;

R;
X;
P;
Q;
C=zeros(br,no);
for i=1:br
    a=l(i,2);
    b=l(i,3);
    for j=1:no
        if a==j
            C(i,j)=-1;
        end
        if b==j
            C(i,j)=1;
        end
    end
end
C;
e=1;
for i=1:no
    d=0;
    for j=1:br
        if C(j,i)==-1
            d=1;
        end
    end
    if d==0
        endnode(e,1)=i;
        e=e+1;
    end
end
endnode;
h=length(endnode);
for j=1:h
    e=2;
    
    f=endnode(j,1);
   % while (f~=1)
   for s=1:no
     if (f~=1)
       k=1;  
       for i=1:br
           if ((C(i,f)==1)&&(k==1))
                f=i;
                k=2;
           end
       end
       k=1;
       for i=1:no
           if ((C(f,i)==-1)&&(k==1));
                f=i;
                g(j,e)=i;
                e=e+1;
                k=3;
           end            
       end
     end
   end
end
for i=1:h
    g(i,1)=endnode(i,1);
end
g;
w=length(g(1,:));
for i=1:h
    j=1;
    for k=1:no 
        for t=1:w
            if g(i,t)==k
                g(i,t)=g(i,j);
                g(i,j)=k;
                j=j+1;
             end
         end
    end
end
g;
for k=1:br
    e=1;
    for i=1:h
        for j=1:w-1
            if (g(i,j)==k) 
                if g(i,j+1)~=0
                    adjb(k,e)=g(i,j+1);            
                    e=e+1;
                else
                    adjb(k,1)=0;
                end
             end
        end
    end
end
adjb;
for i=1:br-1
    for j=h:-1:1
        for k=j:-1:2
            if adjb(i,j)==adjb(i,k-1)
                adjb(i,j)=0;
            end
        end
    end
end
adjb;
x=length(adjb(:,1));
ab=length(adjb(1,:));
for i=1:x
    for j=1:ab
        if adjb(i,j)==0 && j~=ab
            if adjb(i,j+1)~=0
                adjb(i,j)=adjb(i,j+1);
                adjb(i,j+1)=0;
            end
        end
        if adjb(i,j)~=0
            adjb(i,j)=adjb(i,j)-1;
        end
    end
end
adjb;
for i=1:x-1
    for j=1:ab
        adjcb(i,j)=adjb(i+1,j);
    end
end
b=length(adjcb);

% voltage current program

for i=1:no
    vb(i,1)=1;
end
for s=1:10
for i=1:no
    nlc(i,1)=conj(complex(P(i,1),Q(i,1)))/(vb(i,1));
end
nlc;
for i=1:br
    Ibr(i,1)=nlc(i+1,1);
end
Ibr;
xy=length(adjcb(1,:));
for i=br-1:-1:1
    for k=1:xy
        if adjcb(i,k)~=0
            u=adjcb(i,k);
            %Ibr(i,1)=nlc(i+1,1)+Ibr(k,1);
            Ibr(i,1)=Ibr(i,1)+Ibr(u,1);
        end
    end      
end
Ibr;
for i=2:no
      g=0;
      for a=1:b 
          if xy>1
            if adjcb(a,2)==i-1 
                u=adjcb(a,1);
                vb(i,1)=((vb(u,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
                g=1;
            end
            if adjcb(a,3)==i-1 
                u=adjcb(a,1);
                vb(i,1)=((vb(u,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
                g=1;
            end
          end
        end
        if g==0
            vb(i,1)=((vb(i-1,1))-((Ibr(i-1,1))*(complex((R(i-1,1)),X(i-1,1)))));
        end
end
s=s+1;
end
nlc;
Ibr;
vb;
vbp=[abs(vb) angle(vb)*180/pi];


for i=1:no
vbp(i,1)=abs(vb(i));
vbp(i,2)=angle(vb(i))*(180/pi);
end


for i=1:no
    va(i,2:3)=vbp(i,1:2);
end
for i=1:no
    va(i,1)=i;
end
va;


Ibrp=[abs(Ibr) angle(Ibr)*180/pi];
PL(1,1)=0;
QL(1,1)=0;

% losses
for f=1:br
    Pl(f,1)=(Ibrp(f,1)^2)*R(f,1);
    Ql(f,1)=X(f,1)*(Ibrp(f,1)^2);
    PL(1,1)=PL(1,1)+Pl(f,1);
    QL(1,1)=QL(1,1)+Ql(f,1);
end

Plosskw=(Pl)*100000;
Qlosskw=(Ql)*100000;
PL=(PL)*100000;
QL=(QL)*100000;


voltage = vbp(:,1);
%angle = vbp(:,2)*(pi/180);

% hold on
Ibrp = Ibrp*100000;
Ibrp(:,1);
Plosskw;
Qlosskw;
PW = sum(Plosskw);
QW = sum(Qlosskw);

%
Plosskw(33,1)=PL;
Qlosskw(33,1)=QL;
Power_Factor = (PW  - QW) / PW;

VD=sum((1-voltage).^2)*100;
Fit=PL+VD;

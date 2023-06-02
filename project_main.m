function [a,b,c]=project_main(x)

%% Creating a datastructure from the netlist

DC=0;
V_source_array=[];
I_source_array=[];
R_array=[];
C_array=[];
L_array=[];
VCVS_array=[];
VCCS_array=[];
CCCS_array=[];
CCVS_array=[];
branch_current_array=[];
node_voltage_array=[];
power_array=[];
number_of_branches=0;
number_of_nodes=0;
node_zero=0;

while 1
    name=x(number_of_branches+1,:);
    name=strtrim(name);
    if name=="END"
        break;
    end
    number_of_branches=number_of_branches+1;
    if name(1,1)=='V'
        
        name=split(name);
        name=string(name');
        if name(1,4)=="DC"
            DC=1;
        else
            freq=str2double(name(1,7));
        end
        V_source_array=[V_source_array; name];
        
    elseif name(1,1) =='I'
        name=split(name);
        name=string(name');
        if name(1,4)=="DC"
            DC=1;
        else
            freq=str2double(name(1,7));
        end
        I_source_array=[I_source_array; name];
        
    elseif name(1,1)=='R'
        name=split(name);
        name=string(name');
        R_array=[R_array; name];
        
    elseif name(1,1)=='C'
        name=split(name);
        name=string(name');
        C_array=[C_array; name];
        
    elseif name(1,1)=='L'
        name=split(name);
        name=string(name');
        L_array=[L_array; name];
        
    elseif name(1,1)=='E'
        name=split(name);
        name=string(name');
        VCVS_array=[VCVS_array; name];
        
    elseif name(1,1)=='F'
        name=split(name);
        name=string(name');
        CCCS_array=[CCCS_array; name];
        
    elseif name(1,1)=='G'
        name=split(name);
        name=string(name');
        VCCS_array=[VCCS_array; name];
        
    elseif name(1,1)=='H'
        name=split(name);
        name=string(name');
        CCVS_array=[CCVS_array; name];
    end
    
    if(number_of_nodes<str2double(name(1,2)))
        number_of_nodes=str2double(name(1,2));
    end
    if(number_of_nodes<str2double(name(1,3)))
        number_of_nodes=str2double(name(1,3));
    end
end

branch_current_array=zeros(number_of_branches,1);
power_array=zeros(number_of_branches,1);



%% Finding the sizes of arrays


size_V_source_array=size(V_source_array);
size_I_source_array=size(I_source_array);
size_VCCS_array=size(VCCS_array);
size_VCVS_array=size(VCVS_array);
size_CCVS_array=size(CCVS_array);
size_CCCS_array=size(CCCS_array);
size_L_array=size(L_array);
size_C_array=size(C_array);
size_R_array=size(R_array);
total_length=size_V_source_array(1,1)+size_VCVS_array(1,1)+size_CCVS_array(1,1);

%% to keep track of voltageSources
if (size_V_source_array)
    tracker=[];
end
%% (A B; C D)*X= S
S=zeros(number_of_nodes+total_length,1);
A=zeros(number_of_nodes, number_of_nodes);
B=zeros(number_of_nodes,total_length);
C=zeros(total_length,number_of_nodes);
D=zeros(total_length,total_length);


%% Stamping(for modified nodal analysis)

%for resistors 
for i=1:size_R_array(1,1)
    pos_node=str2double(R_array(i,2));
    neg_node=str2double(R_array(i,3));
    res_mag=str2double(R_array(i,4));
    if(pos_node==0)
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/res_mag);
    elseif(neg_node==0)
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/res_mag);
    else
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/res_mag);
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/res_mag);
        A(pos_node,neg_node)=A(pos_node,neg_node)-(1/res_mag);
        A(neg_node,pos_node)=A(neg_node,pos_node)-(1/res_mag);
    end
end


%for VCCS
size_VCCS_array=size(VCCS_array);
for i=1:size_VCCS_array(1,1)
    pos_node=str2double(VCCS_array(i,2));
    neg_node=str2double(VCCS_array(i,3));
    pos_source_node=str2double(VCCS_array(i,4));
    neg_source_node=str2double(VCCS_array(i,5));
    amp_G=str2double(VCCS_array(i,6));
    if(neg_node~=0)
        if(pos_source_node==0)
            A(neg_node,neg_source_node)=A(neg_node,neg_source_node)+amp_G;
        elseif(neg_source_node==0)
            A(neg_node,pos_source_node)=A(neg_node,pos_source_node)-amp_G;
        else
            A(neg_node,neg_source_node)=A(neg_node,neg_source_node)+amp_G;
            A(neg_node,pos_source_node)=A(neg_node,pos_source_node)-amp_G;
        end
    end
    if(pos_node~=0)
        if(pos_source_node==0)
            A(pos_node,neg_source_node)=A(pos_node,neg_source_node)-amp_G;
        elseif(neg_source_node==0)
            A(pos_node,pos_source_node)=A(pos_node,pos_source_node)+amp_G;
        else
            A(pos_node,neg_source_node)=A(pos_node,neg_source_node)-amp_G;
            A(pos_node,pos_source_node)=A(pos_node,pos_source_node)+amp_G;
        end
    
    end
end


%for current source

size_I_source_array=size(I_source_array);
for i=1:size_I_source_array
    pos_node=str2double(I_source_array(i,2));
    neg_node=str2double(I_source_array(i,3));
    if(DC)
        cur_mag=str2double(I_source_array(i,5));
    else
        mag=str2double(I_source_array(i,5));
        cur_mag=mag*cos(str2double(I_source_array(i,6)))+mag*sin(str2double(I_source_array(i,6)))*1j;
    end
    if(pos_node==0)
        S(neg_node,1)=S(neg_node,1)+cur_mag;
    elseif(neg_node==0)
        S(pos_node,1)=S(pos_node,1)-cur_mag;
    else
        S(neg_node,1)=S(neg_node,1)+cur_mag;
        S(pos_node,1)=S(pos_node,1)-cur_mag;
    end
end

B_new=1;
C_new=1;

%for Vsource
for i=1:size_V_source_array(1,1)
    pos_node=str2double(V_source_array(i,2));
    neg_node=str2double(V_source_array(i,3));
    if(DC)
        volt_mag=str2double(V_source_array(i,5));
    else
        mag=str2double(V_source_array(i,5));
        volt_mag=mag*cos(str2double(V_source_array(i,6)))+mag*sin(str2double(V_source_array(i,6)))*1j;
    end
    if(pos_node==0)
        B(neg_node,i)=B(neg_node,i)-1;
        C(i,neg_node)=C(i,neg_node)-1;
    elseif(neg_node==0)
        B(pos_node,i)=B(pos_node,i)+1;
        C(i,pos_node)=C(i,pos_node)+1;
    else
        B(neg_node,i)=B(neg_node,i)-1;
        C(i,neg_node)=C(i,neg_node)-1;
        B(pos_node,i)=B(pos_node,i)+1;
        C(i,pos_node)=C(i,pos_node)+1;
    end
    S(i+number_of_nodes,1)=volt_mag;
    tracker=[tracker V_source_array(i,1)];
end

B_new=B_new+size_V_source_array(1,1);
C_new=C_new+size_V_source_array(1,1);

%for CCCS

for i=1:size_CCCS_array(1,1)

    for j=1:size_V_source_array(1,1)
        if tracker(1,j)==CCCS_array(i,4)
            break;
        end
    end
    pos_node=str2double(CCCS_array(i,2));
    neg_node=str2double(CCCS_array(i,3));
    amp_F=str2double(CCCS_array(i,5));
    if(pos_node==0)
        B(neg_node,j)=B(neg_node,j)-amp_F;
    elseif(neg_node==0)
        B(pos_node,j)=B(pos_node,j)+amp_F;
    else
       B(neg_node,j)=B(neg_node,j)-amp_F;
       B(pos_node,j)=B(pos_node,j)+amp_F;
    end

end

%for VCVS

for i=1:size_VCVS_array(1,1)
    pos_node=str2double(VCVS_array(i,2));
    neg_node=str2double(VCVS_array(i,3));
    pos_source_node=str2double(VCVS_array(i,4));
    neg_source_node=str2double(VCVS_array(i,5));
    amp_E=str2double(VCVS_array(i,6));
    if(neg_node~=0)
        B(neg_node,B_new)=B(neg_node,B_new)-1;
        C(C_new,neg_node)=C(C_new,neg_node)-1;
    end
    if(pos_node~=0)
        B(pos_node,B_new)=B(pos_node,B_new)+1;
        C(C_new,pos_node)=C(C_new,pos_node)+1;
    end
    if(neg_source_node~=0)
        C(C_new,neg_source_node)=C(C_new,neg_source_node)+amp_E;
    end
    if(pos_source_node~=0)
        C(C_new,pos_source_node)=C(C_new,pos_source_node)-amp_E;
    end
    B_new=B_new+1;
    C_new=C_new+1;
end


%For CCVS

for i=1:size_CCVS_array(1,1)
    for j=1:size_V_source_array(1,1)
        if tracker(1,j)==CCVS_array(i,4)
            break;
        end
    end
    pos_node=str2double(CCVS_array(i,2));
    neg_node=str2double(CCVS_array(i,3));
    amp_H=str2double(CCVS_array(i,5));
    if(neg_node~=0)
        B(neg_node,B_new)=B(neg_node,B_new)-1;
        C(C_new,neg_node)=C(C_new,neg_node)-1;
    end
    if(pos_node~=0)
        B(pos_node,B_new)=B(pos_node,B_new)+1;
        C(C_new,pos_node)=C(C_new,pos_node)+1;
    end
    D(C_new,j)=D(C_new,j)-amp_H;
    B_new=B_new+1;
    C_new=C_new+1;
end



%for capacitors 


for i=1:size_C_array(1,1)
    pos_node=str2double(C_array(i,2));
    neg_node=str2double(C_array(i,3));
    if(DC)
        C_mag=inf;
    else
        C_mag=1/(2j*pi*freq*str2double(C_array(i,4)));
    end
    if(pos_node==0)
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/C_mag);
    elseif(neg_node==0)
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/C_mag);
    else
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/C_mag);
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/C_mag);
        A(pos_node,neg_node)=A(pos_node,neg_node)-(1/C_mag);
        A(neg_node,pos_node)=A(neg_node,pos_node)-(1/C_mag);
    end
end



%for inductors 
for i=1:size_L_array(1,1)
    pos_node=str2double(L_array(i,2));
    neg_node=str2double(L_array(i,3));
    if(DC)
        L_mag=0;
    else
        L_mag=(2j*pi*freq*str2double(L_array(i,4)));
    end
    if(pos_node==0)
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/L_mag);
    elseif(neg_node==0)
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/L_mag);
    else
        A(pos_node,pos_node)=A(pos_node,pos_node)+(1/L_mag);
        A(neg_node,neg_node)=A(neg_node,neg_node)+(1/L_mag);
        A(pos_node,neg_node)=A(pos_node,neg_node)-(1/L_mag);
        A(neg_node,pos_node)=A(neg_node,pos_node)-(1/L_mag);
    end
end

%% Solving the matrix to find the node voltages
M=[A B;C D];
S;
x=M\S;

node_voltage_array=x(1:number_of_nodes,:);


%% Solving for branch_Currents


volt_count=0;

%for Vsource 
for i=1:size_V_source_array(1,1)
    volt_count=volt_count+1;
    branch_current_array(i,1)=x(number_of_nodes+volt_count,1);
end  

%Solving for Isource
I_count=0;
for i=1:size_I_source_array(1,1)
    if(DC)
        I_count=I_count+1;
        branch_current_array(i+volt_count,1)=I_source_array(i,5);
    else
        I_count=I_count+1;
        temp=str2double(I_source_array(i,5));
        temp=temp*cos(str2double(I_source_array(i,6)))+temp*sin(str2double(I_source_array(1,6)))*1j;
        branch_current_array(i+volt_count,1)=temp;
    end
end
I_count=I_count+volt_count;

%for cccs 
F_count=0;
for i=1:size_CCCS_array(1,1)
    for j=1:size_V_source_array(1,1)
        if tracker(1,j)==CCCS_array(i,4)
            break;
        end
    end
    F_count=F_count+1;
    branch_current_array(i+I_count,1)=str2double(CCCS_array(i,5))*branch_current_array(j,1);
end
F_count=F_count+I_count;

%for vcvs
E_count=0;
for i=1:size_VCVS_array(1,1)
    E_count=E_count+1;
    branch_current_array(i+F_count,1)=x(number_of_nodes+volt_count+E_count,1);
end   
new_E_count=E_count+F_count;

%for CCVS 
H_count=0;
for i=1:size_CCVS_array(1,1)

    H_count=H_count+1;
    branch_current_array(i+new_E_count,1)=x(number_of_nodes+volt_count+E_count+H_count,1);

end
new_H_count=H_count+new_E_count;


%for VCCS
G_count=0;
for i=1:size_VCCS_array(1,1)
    G_count=G_count+1;
    if(str2double(VCCS_array(i,4))==0)
        a=0;
        b=node_voltage_array(str2double(VCCS_array(i,5)));
    elseif(str2double(VCCS_array(i,5))==0)
        b=0;
        a=node_voltage_array(str2double(VCCS_array(i,4)));
    else
        a=node_voltage_array(str2double(VCCS_array(i,4)));
        b=node_voltage_array(str2double(VCCS_array(i,5)));
    end
    temp=a-b;
    branch_current_array(i+new_H_count,1)=temp*str2double(I_source_array(i,6));
end
G_count=G_count+new_H_count;

%for R
R_count=0;
for i=1:size_R_array(1,1)
    R_count=R_count+1;
    if(str2double(R_array(i,2))==0)
        a=0;
        b=node_voltage_array(str2double(R_array(i,3)));
    elseif(str2double(R_array(i,3))==0)
        b=0;
        a=node_voltage_array(str2double(R_array(i,2)));
    else
        b=node_voltage_array(str2double(R_array(i,3)));
        a=node_voltage_array(str2double(R_array(i,2)));
    end
    temp=a-b;
    branch_current_array(i+G_count,1)=temp/str2double(R_array(i,4)); 
end
R_count=R_count+G_count;

%for C

C_count=0;
for i=1:size_C_array(1,1)

    if(DC)
        C_mag=inf;
    else
        C_mag=1/(2j*pi*freq*str2double(C_array(i,4)));
    end
    C_count=C_count+1;
    if(str2double(C_array(i,2))==0)
        a=0;
        b=node_voltage_array(str2double(C_array(i,3)));
    elseif(str2double(C_array(i,3))==0)
        b=0;
        a=node_voltage_array(str2double(C_array(i,2)));
    else
       a=node_voltage_array(str2double(C_array(i,2))); 
       b=node_voltage_array(str2double(C_array(i,3)));
    end
    temp=a-b;
    branch_current_array(i+R_count,1)=temp/C_mag;
end
C_count=C_count+R_count;


%for L
for i=1:size_L_array(1,1)
   
    if(DC)
        L_mag=0;
    else
        L_mag=2j*pi*freq*str2double(L_array(i,4));
    end
    if(str2double(L_array(i,2))==0)
        a=0;
        b=node_voltage_array(str2double(L_array(i,3)));
    elseif(str2double(L_array(i,3))==0)
        b=0;
        a=node_voltage_array(str2double(L_array(i,2)));
    else
        a=node_voltage_array(str2double(L_array(i,2)));
        b=node_voltage_array(str2double(L_array(i,3)));    
    end
    temp=a-b;
    branch_current_array(i+C_count,1)=temp/L_mag;
end



branch_current_string="Current through,"+newline;
power_string="Power Dissipated by, "+newline;


%% Power disspated

new_l=0;
%for Vsources
for i=1:size_V_source_array(1,1)
    if(DC)
        power_array=str2double(V_source_array(i,5))*conj(branch_current_array(new_l+i,1));
        branch_current_string=branch_current_string+V_source_array(i,1)+": "+branch_current_array(i,1)+" A"+newline;
        power_string=power_string+V_source_array(i,1)+": "+branch_current_array(i,1)+" VA"+newline;
    else
        mag=str2double(V_source_array(i,5));
        volt_mag=mag*cos(str2double(V_source_array(i,6)))+mag*sin(str2double(V_source_array(i,6)))*1j;
        power_array(i,1)=0.5*volt_mag*conj(branch_current_array(new_l+i,1));
        branch_current_string=branch_current_string+V_source_array(i,1)+": "+branch_current_array(i,1)+" A"+newline;
        power_string=power_string+V_source_array(i,1)+": "+branch_current_array(i,1)+" VA"+newline;
    end
    new_l=new_l+1;
end

%for Isources
for i=1:size_I_source_array(1,1)
    pos_node=str2double(I_source_array(i,2));
    neg_node=str2double(I_source_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
    
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+I_source_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+I_source_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end    
new_l=new_l+size_I_source_array(1,1);

for i=1:size_CCCS_array(1,1)
    pos_node=str2double(CCCS_array(i,2));
    neg_node=str2double(CCCS_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
    
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+CCCS_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+CCCS_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_CCCS_array(1,1);

for i=1:size_VCVS_array(1,1)
    pos_node=str2double(VCVS_array(i,2));
    neg_node=str2double(VCVS_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
 
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+VCVS_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+VCVS_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_VCVS_array(1,1);

for i=1:size_CCVS_array(1,1)
    pos_node=str2double(CCVS_array(i,2));
    neg_node=str2double(CCVS_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
 
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+CCVS_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+CCVS_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_CCVS_array(1,1);

for i=1:size_VCCS_array(1,1)
    pos_node=str2double(VCCS_array(i,2));
    neg_node=str2double(VCCS_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
   
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+VCCS_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+VCCS_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_VCCS_array(1,1);


%for R,L,C
for i=1:size_R_array(1,1)
    pos_node=str2double(R_array(i,2));
    neg_node=str2double(R_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
   
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+R_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+R_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_R_array(1,1);

for i=1:size_C_array(1,1)
    pos_node=str2double(C_array(i,2));
    neg_node=str2double(C_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
   
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+C_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+C_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_C_array(1,1);

for i=1:size_L_array(1,1)
    pos_node=str2double(L_array(i,2));
    neg_node=str2double(L_array(i,3));
    if(pos_node==0)
        a=0;
        b=node_voltage_array(neg_node);
    elseif(neg_node)==0
        b=0;
        a=node_voltage_array(pos_node);
    else
        a=node_voltage_array(pos_node);
        b=node_voltage_array(neg_node);    
    end
    
    voltage=a-b;
    if(DC)
        power_array(new_l+i,1)=voltage*conj(branch_current_array(new_l+i,1));
    else
        power_array(new_l+i,1)=0.5*voltage*conj(branch_current_array(new_l+i,1));
    end
    branch_current_string=branch_current_string+L_array(i,1)+": "+branch_current_array(new_l+i,1)+" A"+newline;
    power_string=power_string+L_array(i,1)+": "+power_array(new_l+i,1)+" VA"+newline;
end  
new_l=new_l+size_L_array(1,1);


node_voltage_string="V0= 0V"+newline;
for i=1:number_of_nodes
    node_voltage_string=node_voltage_string+"V"+i+"= "+node_voltage_array(i,1)+newline;
end


%% sending info to GUI
a=node_voltage_string;
b=branch_current_string;
c=power_string;



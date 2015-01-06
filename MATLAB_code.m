clear all;
clc;
defect = 'Input the value of k for K-plex problem ';
l=input(defect)-1;
Nmat=xlsread('Project9.xlsx');
Adjmat=zeros(Nmat(1,1));

%Convert the input into Adjcency matrix
for j=1:length(Nmat)-1
    
    Adjmat(Nmat(j+1,1),Nmat(j+1,2))=1;
end

for j=1:Nmat(1,1)
    for k=1:Nmat(1,1)
        Adjmat(j,k)=Adjmat(k,j);
    end
end
%Start CPU time
stime=cputime;
%Degree of each vertex
deg=sum(Adjmat);

for i=1:length(Adjmat)
    inddeg(i,1) = i;
    inddeg(i,2)= deg(i);
end

%Greedy algorithm to find intial solution
flag=1;
sortdeg=flipud(sortrows(inddeg,2));
i=1;
current=zeros(length(Adjmat),2);
current(1,1)=sortdeg(1,1);

NNbrc=zeros(length(Adjmat),1);
oldNNbrc=zeros(length(Adjmat),1);
sortdeg(1,:)=[];

while flag~=0
        NNbr=0;
    for j=1:i
        if (Adjmat(current(j,1),sortdeg(1,1))==0)
            NNbr=NNbr+1;
            NNbrc(j)=NNbrc(j)+1;
        end
    end
    if NNbr<=l && max(NNbrc)<=l
        i=i+1;
        current(i,1)=sortdeg(1,1);
        for k=1:i
            if k==i
                current(k,2)=NNbr;
            else
                current(k,2)=NNbrc(k);
            end
            oldNNbrc(k)=current(k,2);
        end
    end
    sortdeg(1,:)=[];
    if length(sortdeg)==0
        flag=0;
    end
    NNbrc=oldNNbrc;
end
%Tabu of size 10
Tabulist=zeros(10,1);
t=1;
%removing saturated or lowest degree vertex and adding other vertices to
%increase the size of the vertex
for z=1:100
    satrows=find(current(current(:,1)>0,2)==l);
    if length(satrows)~=0
        satver=current(satrows,1);
        satverdeg=inddeg(satver,:);
        remver = datasample(satrows,1);
    else
        currentdeg=inddeg(current(current(:,1)>0,1),2);
        remrows=find(currentdeg==min(currentdeg));
        remver = datasample(remrows,1);
    end
    %Updating tabulist 
    Tabulist(t)=current(remver,1);
    updcurrent= removerows(current,'ind',remver);
    %Updating the nonneighbors in K-plex set after removal of a vertex
    for i=1:nnz(updcurrent(:,1))
        
        if Adjmat(updcurrent(i,1),current(remver,1))==0
            
            updcurrent(i,2)=updcurrent(i,2)-1;
        end
        
    end
    NNbrc=updcurrent(:,2);
    oldNNbrc=updcurrent(:,2);
    tabuver=Tabulist(Tabulist>0);
    unconrows=union(updcurrent(updcurrent(:,1)>0,1),tabuver);
    flag=1;
    candlist=removerows(inddeg,'ind',unconrows);
    cansortdeg=flipud(sortrows(candlist,2));
    p=0;
    i=nnz(updcurrent(:,1));
    while flag~=0
        
        NNbr=0;
        %Checking the eligibility of a candidate vertex
        for j=1:i
            if (Adjmat(updcurrent(j,1),cansortdeg(1,1))==0)
                NNbr=NNbr+1;
                NNbrc(j)=NNbrc(j)+1;
            end
        end
                if NNbr<=l && max(NNbrc)<=l
            i=i+1;
            updcurrent(i,1)=cansortdeg(1,1);
            %Updating the nonneighbors after the addition of a vertex
            for k=1:i
                if k==i
                    updcurrent(k,2)=NNbr;
                else
                    updcurrent(k,2)=NNbrc(k);
                end
                oldNNbrc(k)=updcurrent(k,2);
            end
            
        end
        cansortdeg(1,:)=[];
        if length(cansortdeg)==0
            flag=0;
        end
        
        NNbrc=oldNNbrc;
        
    end
    t=t+1;
    if t==11
        t=1;
    end
    %Jumping to the better solution
    if nnz(updcurrent(:,1))>=nnz(current(:,1))
        bestsol=updcurrent(updcurrent(:,1)>0,1);
        len=nnz(updcurrent(:,1));
        current=updcurrent;
    else
        %Storing the best solution found in neighbourhood
        bestsol=current(current(:,1)>0,1);
        len=nnz(current(:,1));
    end
end
bestsol
len
time=cputime-stime
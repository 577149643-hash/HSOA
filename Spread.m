function [count,newISO,CR,ParaSetting]=Spread(CR,newISO,ParaSetting,radius)

newISO(1,:)=CR.GobalBestInd;
count=0;
sumA2=0;
sumA1=0;
A2=10; 
flag=0;

%mutation------------------------------------------------------------------------------------------------
for i=round(size(newISO,1)/2):size(newISO,1)
    radius3=radius(round(rand()*(size(radius,2)-1)+1))*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2);
    index2=1;
    Indiv3=newISO(1,:);
     for  index2 =1:ParaSetting.D
            Indiv4=Indiv3;
             if rand()<0.8
                 Indiv4(1,index2)=rand()*(2*radius3)+ (-radius3)+Indiv4(1,index2);
             else
                 Indiv4(1,index2)=rand()*(ParaSetting.UpperLimit(index2)- ParaSetting.LowerLimit(index2))+ ParaSetting.LowerLimit(index2);  
             end
             Indiv4 = Evaluation(ParaSetting,Indiv4(1,1:ParaSetting.D));    
             count=count+1;
             if Indiv4(1,ParaSetting.D+1)<Indiv3(1,ParaSetting.D+1)
                newISO(1,:)=Indiv4;
                Indiv3=Indiv4 ;
             end
     end
end

for i=1:round(size(newISO,1)/2)
         radius1=A2*exppdf(10*rand(),1);
		 Indiv=newISO(1,:);
         index=1;
     while  index <= ParaSetting.D
         Indiv2=Indiv;
         Indiv2(1,index)=rand()*(2*radius1)+ (-radius1)+Indiv2(1,index);
		 Indiv2 = Evaluation(ParaSetting,Indiv2(1,1:ParaSetting.D)); 
         count=count+1;
		 if Indiv2(1,ParaSetting.D+1)<Indiv(1,ParaSetting.D+1)
            radius1=abs(Indiv(1,index)-Indiv2(1,index));
            flag=1;
            Indiv=Indiv2 ;
            newISO(1,:)=Indiv2;
         else
              if flag==0 && sumA2< 3
                 sumA2=sumA2+1;
                 radius1=A2*exppdf(10*rand(),1);
              end
              
              if flag==1 && sumA1<8
                  sumA1=sumA1+1;
                  radius1=radius1/2;
              end
              
              if sumA1>=8 || sumA2>=3
                  sumA2=0;
                  sumA1=0;
                  index=index+1;
                  radius1=A2*exppdf(10*rand(),1); 
              end
         end
     end
end

%-----------------------------------------------------------------
    if newISO(1,ParaSetting.D+1) < CR.GobalBestInd(1,ParaSetting.D+1)
            CR.GobalBestInd=newISO(1,:);  
    end
	 
end
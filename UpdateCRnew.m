function [CR]=UpdateCRnew(ParaSetting,CR,Population)
	CR.YoyPoint(2,ParaSetting.Gen)=ParaSetting.Gen;                 
	Tail=CR.YoyPoint(2,ParaSetting.Gen);
	 
	if ParaSetting.Gen==1                                                   
	   CR.YoyPoint(1,ParaSetting.Gen)=1;
	else
	   CR.YoyPoint(1,ParaSetting.Gen)=CR.YoyPoint(1,ParaSetting.Gen-1);
	end
	 
	[NewBestFit,index]=min(Population(:,end));
	BestInd=Population(index,:);
	CR.YoyFit(2,ParaSetting.Gen)=NewBestFit;
	if ParaSetting.Gen>1
	   CR.YoyFit(2,ParaSetting.Gen)= 0.8*NewBestFit+0.8*CR.YoyFit(2,ParaSetting.Gen-1);
	else
	   CR.YoyFit(2,ParaSetting.Gen)= 0.8*NewBestFit;
	end
	wmax=0.9;wmin=0.4;Max_iteration=50;
	if mod(Tail,CR.T)==0
	   Head=CR.YoyPoint(1,ParaSetting.Gen);

       CRValue=wmax-(wmax-wmin)*(ParaSetting.Gen/Max_iteration)^2;
	   % CRValue=(CR.YoyFit(2,Tail)-CR.YoyFit(2,Head))/abs(CR.YoyFit(2,Head));      
	   CR.YoyPoint(3,ParaSetting.Gen)=CRValue;
	   CR.YoyPoint(1,ParaSetting.Gen)=Tail; 
	end
	
	if NewBestFit<CR.GobalBestInd(1,end)
	   CR.GobalBestInd=BestInd;
    end


    
end
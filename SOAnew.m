%%-------------------------------------------------------------------------------------
function [BestIndividual,BestFit,curve]=SOAnew(SearchAgents_no,Max_iteration,lb,ub,dim,fobj)
%% Experiment setting
ParaSetting.EvaluateType = fobj;
ParaSetting.Gen =0;
ParaSetting.D =dim;
%% JudgeStopCondition       
ParaSetting.StopType    = 'EvaluationFunctionCountThreshold';
ParaSetting.EvaluationFunctionCountThreshold = 10000*ParaSetting.D;
%% School parameter setting
ParaSetting.SchoolSize   =SearchAgents_no;
ParaSetting.SchoolNum    = 35;
ParaSetting.MaxSchoolNum = 35;
ParaSetting.MinSchoolNum = 5;
ParaSetting.SarNumUpLim  =11;
ParaSetting.UpperLimit=ub.*ones( 1,dim);
ParaSetting.LowerLimit=lb.*ones( 1,dim);
ParaSetting.NightRatio= 0.3;
ParaSetting.Gen=0;
ParaSetting.EvaluationCount=0;
newISO=[];
radius=[5,10,15,20,25,30];
InitSchoolNum=ParaSetting.MaxSchoolNum;

% Initialization
[CR,AR,ISO,Population,ParaSetting]=InitSchoolnew(ParaSetting);
 while (ParaSetting.Gen<Max_iteration) 
     ParaSetting.Gen=ParaSetting.Gen+1;
     if ParaSetting.EvaluationCount<=ParaSetting.EvaluationFunctionCountThreshold*(1-ParaSetting.NightRatio)  %in day  
         % Update the maximum number of school 
         [Population,ParaSetting]=UpdateMaxSchNum(Population,InitSchoolNum,ParaSetting);
         % defense by using transformation and migration
         [AR]=UpdateAR(ParaSetting,AR,Population);
         [ParaSetting,AR] = Migration(AR,ParaSetting);
         radius1=radius(round(rand()*(size(radius,2)-1)+1))*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2);
         [ParaSetting,Population]=Transformationnew(Population,ParaSetting,AR,radius1); 
         
         CR=UpdateCRnew(ParaSetting,CR,Population);


         [count1,ISO,CR,Population,ParaSetting,AR]=ReproductionAndElimination(CR,Population,ParaSetting,AR,ISO,radius1);
         ParaSetting.EvaluationCount = ParaSetting.EvaluationCount+size(Population,1)+count1;
     else                             %in the night
         [count,newISO,CR,ParaSetting]=Spread(CR,newISO,ParaSetting,radius);        %spread
         ParaSetting.EvaluationCount=ParaSetting.EvaluationCount+count;
     end
     curve(ParaSetting.Gen)=CR.GobalBestInd(1,ParaSetting.D+1);
     % disp(['SOA Iter:',num2str(ParaSetting.Gen),' Fit:',num2str(curve(ParaSetting.Gen))]);
end

%Output the best sardine as the best solution
BestFit=CR.GobalBestInd(1,ParaSetting.D+1);
BestIndividual=CR.GobalBestInd(1,1:ParaSetting.D);

end

%%-------------------------------------------------------------------------------------
function [Stop] = JudgeStopCondition(ParaSetting,Fitness,EvaluationFunctionCount)
	DefaultStopCondition = (EvaluationFunctionCount >= ParaSetting.EvaluationFunctionCountThreshold);
	Stop = 0;
    switch ParaSetting.StopType
        case 'EvaluationFunctionCountThreshold'
            if ( DefaultStopCondition == 1 )
                Stop = 1;
            end
        otherwise
            disp('Invalid StopType @ JudgeStopCondition(ParaSetting,Fitness,EvaluationFunctionCount )');
    end
end
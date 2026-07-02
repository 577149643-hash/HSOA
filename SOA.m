%%-------------------------------------------------------------------------------------
function [BestIndividual,BestFit,curve]=SOA(SearchAgents_no,Max_iteration,lb,ub,dim,fobj)
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
[CR,AR,ISO,Population,ParaSetting]=InitSchool(ParaSetting);
 while (ParaSetting.Gen<Max_iteration) 
     ParaSetting.Gen=ParaSetting.Gen+1;
     
     if ParaSetting.EvaluationCount<=ParaSetting.EvaluationFunctionCountThreshold*(1-ParaSetting.NightRatio)  %in day  
         % Update the maximum number of school 
         [Population,ParaSetting]=UpdateMaxSchNum(Population,InitSchoolNum,ParaSetting);
         % defense by using transformation and migration
         [AR]=UpdateAR(ParaSetting,AR,Population);
         [ParaSetting,AR] = Migration(AR,ParaSetting);
         radius1=radius(round(rand()*(size(radius,2)-1)+1))*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2);
         [ParaSetting,Population]=Transformation(Population,ParaSetting,AR,radius1); 
         % reproduction and elimination
         CR=UpdateCR(ParaSetting,CR,Population);
         [count1,ISO,CR,Population,ParaSetting,AR]=ReproductionAndElimination(CR,Population,ParaSetting,AR,ISO,radius1);
         ParaSetting.EvaluationCount = ParaSetting.EvaluationCount+size(Population,1)+count1;
     else                             %in the night
         [count,newISO,CR,ParaSetting]=Spread(CR,newISO,ParaSetting,radius);        %spread
         ParaSetting.EvaluationCount=ParaSetting.EvaluationCount+count;
     end
     curve(ParaSetting.Gen)=CR.GobalBestInd(1,ParaSetting.D+1);
%      disp(['SOA Iter:',num2str(ParaSetting.Gen),' Fit:',num2str(curve(ParaSetting.Gen))]);
end

%Output the best sardine as the best solution
BestFit=CR.GobalBestInd(1,ParaSetting.D+1);
BestIndividual=CR.GobalBestInd(1,1:ParaSetting.D);

end

%%-------------------------------------------------------------------------------------
function [CR,AR,ISO,Population,ParaSetting]=InitSchool(ParaSetting)
for i=1:ParaSetting.SchoolNum*ParaSetting.SchoolSize
        Population(i,:) = rand(1,ParaSetting.D).*(ParaSetting.UpperLimit- ParaSetting.LowerLimit)+ ParaSetting.LowerLimit; 
end
    [Population] = Evaluation(ParaSetting,Population);
    ParaSetting.SchoolInfor=ones(ParaSetting.SchoolNum,ParaSetting.D+2);
    ParaSetting.SchoolInfor(1:ParaSetting.SchoolNum,ParaSetting.D+1)= ParaSetting.SchoolInfor(1:ParaSetting.SchoolNum,ParaSetting.D+1)*5;
    
    for i=1:ParaSetting.SchoolNum
    ParaSetting.SchoolInfor(i,1:ParaSetting.D) = rand(1,ParaSetting.D).*(ParaSetting.UpperLimit- ParaSetting.LowerLimit)+ ParaSetting.LowerLimit; 
    end
    CR.T       =10;
    CR.YoyPoint=zeros(4,500);                   
    CR.YoyFit=zeros(1,500);    
    CR.GobalBestInd=Population(1,:);            
    CR.SchoolNumArr=zeros(1,500); 
    AR.LevyArr=repmat({zeros(ParaSetting.SchoolSize,ParaSetting.D+1)},1,ParaSetting.MaxSchoolNum);
    AR.PointArrt=zeros(3,500,ParaSetting.SchoolNum);              
    Momsize=ceil(ParaSetting.EvaluationFunctionCountThreshold/(ParaSetting.SchoolSize*ParaSetting.MinSchoolNum));
    AR.MomFit=zeros(10,Momsize,ParaSetting.SchoolNum);  
    AR.OffCenter=zeros(2,Momsize,ParaSetting.SchoolNum); 
    AR.LevyPoint=zeros(1,ParaSetting.MaxSchoolNum);
    AR.threshold = 1 ;
    ISO=Population(1:ParaSetting.SarNumUpLim,:);     
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
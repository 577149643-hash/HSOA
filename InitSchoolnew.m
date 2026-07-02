function [CR,AR,ISO,Population,ParaSetting]=InitSchoolnew(ParaSetting)

    Population=initializationNew(ParaSetting.SchoolNum*ParaSetting.SchoolSize,ParaSetting.D,ParaSetting.UpperLimit,ParaSetting.LowerLimit);
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
function [Population,ParaSetting]=UpdateMaxSchNum(Population,InitSchoolNum,ParaSetting)
    gena=ParaSetting.EvaluationFunctionCountThreshold;

    if ParaSetting.EvaluationCount >=gena*0.2 && ParaSetting.EvaluationCount < gena*0.3
       ParaSetting.MaxSchoolNum=round((10-InitSchoolNum)*ParaSetting.EvaluationCount/gena*0.1+(3*InitSchoolNum-20));
       if ParaSetting.MaxSchoolNum < ParaSetting.MinSchoolNum
           ParaSetting.MaxSchoolNum=ParaSetting.MinSchoolNum;
       end
       if ParaSetting.SchoolNum > ParaSetting.MaxSchoolNum
           Population=Population(1:ParaSetting.MaxSchoolNum*ParaSetting.SchoolSize,:);
           ParaSetting.SchoolNum=ParaSetting.MaxSchoolNum;
       end
    elseif ParaSetting.EvaluationCount >= gena*0.3 && ParaSetting.EvaluationCount < gena*0.4
         ParaSetting.MaxSchoolNum=7;
       if ParaSetting.MaxSchoolNum < ParaSetting.MinSchoolNum
           ParaSetting.MaxSchoolNum=ParaSetting.MinSchoolNum;
       end
       if ParaSetting.SchoolNum > ParaSetting.MaxSchoolNum
           Population=Population(1:ParaSetting.MaxSchoolNum*ParaSetting.SchoolSize,:);
           ParaSetting.SchoolNum=ParaSetting.MaxSchoolNum;
       end
    end
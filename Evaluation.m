function [PopulationFitness] = Evaluation(ParaSetting,Population)
for i=1:size(Population,1)
    kdxub=find(Population(i,:)>ParaSetting.UpperLimit);
    kdxlb=find(Population(i,:)<ParaSetting.LowerLimit);
    Population(i,kdxub) = ParaSetting.UpperLimit(kdxub) ;
    Population(i,kdxlb) = ParaSetting.LowerLimit(kdxlb);
    Fitness(i)=ParaSetting.EvaluateType(Population(i,:));
end
Fitness=Fitness';
PopulationFitness = [Population,Fitness];
end
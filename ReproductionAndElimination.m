function [count1,ISO,CR,Population,ParaSetting,AR]=ReproductionAndElimination(CR,Population,ParaSetting,AR,ISO,radius1)	
count1=0;
if mod(ParaSetting.Gen,CR.T)==0
	    % reproduction for schools
        tcr=-0.1;
		if  CR.YoyPoint(3,ParaSetting.Gen) <=tcr
			if ParaSetting.SchoolNum < ParaSetting.MaxSchoolNum
			   min=Population(1,ParaSetting.D+1);
			   max=Population(1,ParaSetting.D+1);
			   minIndex=1;
			   maxIndex=1;
			   for i=1:ParaSetting.SchoolNum
				   if Population((i-1)*ParaSetting.SchoolSize+1,ParaSetting.D+1)<min
					   min=Population((i-1)*ParaSetting.SchoolSize+1,ParaSetting.D+1);
					   minIndex=i;
				   end
				   if Population((i-1)*ParaSetting.SchoolSize+1,ParaSetting.D+1)>max
					   max=Population((i-1)*ParaSetting.SchoolSize+1,ParaSetting.D+1);
					   maxIndex=i;
				   end
			   end
			   maxDistance=ParaSetting.SchoolInfor(maxIndex,1:ParaSetting.D)-ParaSetting.SchoolInfor(minIndex,1:ParaSetting.D);
			   ParaSetting.SchoolInfor(end+1,1:ParaSetting.D)=ParaSetting.SchoolInfor(minIndex,1:ParaSetting.D)-rand()*maxDistance;
% 			   radius=5; 
			   ParaSetting.SchoolInfor(ParaSetting.SchoolNum,ParaSetting.D+1)=radius1; 
			   ParaSetting.SchoolInfor(ParaSetting.SchoolNum,ParaSetting.D+2)=1;
			   ParaSetting.SchoolNum=ParaSetting.SchoolNum+1;                          
			   CR.SchoolNumArr(1,ParaSetting.Gen)=ParaSetting.SchoolNum;        
			   Population(1+size(Population,1):size(Population,1)+ParaSetting.SchoolSize,1:ParaSetting.D) = Oval(ParaSetting,ParaSetting.SchoolNum,radius1);  %reproduce new school
			   Population(size(Population,1)-ParaSetting.SchoolSize+1:size(Population,1),:) = Evaluation(ParaSetting,Population(size(Population,1)-ParaSetting.SchoolSize+1:size(Population,1),1:ParaSetting.D));
			   Population(size(Population,1)-ParaSetting.SchoolSize+1:size(Population,1),:)=sortrows(Population(size(Population,1)-ParaSetting.SchoolSize+1:size(Population,1),:),ParaSetting.D+1);
			   AR.LevyPoint(ParaSetting.SchoolNum) =  AR.LevyPoint(ParaSetting.SchoolNum-1) ;
			   AR.MomPointArr(:,:,ParaSetting.SchoolNum) = AR.MomPointArr(:,:,ParaSetting.SchoolNum-1);
			   AR.MomFit(:,:,ParaSetting.SchoolNum)=AR.MomFit(:,:,ParaSetting.SchoolNum-1);
			   AR.LevyPoint(ParaSetting.SchoolNum)=AR.LevyPoint(ParaSetting.SchoolNum-1);
			end

		% elimination for schools
		elseif ParaSetting.SchoolNum > ParaSetting.MinSchoolNum
			   worstSchoolFit=Population(1,ParaSetting.D+1);
               worstSchoolIndex=1;
			   for i=1:ParaSetting.SchoolNum
				   if Population(1+(i-1)*ParaSetting.SchoolSize,ParaSetting.D+1) >=worstSchoolFit
					  worstSchoolFit=Population(1+(i-1)*ParaSetting.SchoolSize,ParaSetting.D+1);
					  worstSchoolIndex=i;
				   end
			   end
			   Population(1+(worstSchoolIndex-1)*ParaSetting.SchoolSize:worstSchoolIndex*ParaSetting.SchoolSize,:)=[];
			   ParaSetting.SchoolInfor(worstSchoolIndex,:)=[];
			   ParaSetting.SchoolNum=ParaSetting.SchoolNum-1;
			   AR.MomPointArr(:,:,worstSchoolIndex)=[]; 
			   AR.LevyArr{worstSchoolIndex}=[];
			   AR.MomFit(:,:,worstSchoolIndex)=[];
			   AR.LevyPoint(worstSchoolIndex)=[];
		end
	end
 %------------------------------------------------------------------
    % eliminate for single survived sardine set
	sizeISO=size(ISO,1);
	if mod(ParaSetting.Gen,CR.T)==0
		for i=1:ParaSetting.SchoolNum
	    	 ISO(sizeISO+i,:)=Population(1+(i-1)*ParaSetting.SchoolSize,:);
		end
		ISO=sortrows(ISO,ParaSetting.D+1);
		if size(ISO,1)>ParaSetting.SarNumUpLim
		   ISO=ISO(1:ParaSetting.SarNumUpLim,:);            
		end
		if ISO(1,ParaSetting.D+1) < CR.GobalBestInd(1,ParaSetting.D+1)
		   CR.GobalBestInd=ISO(1,:);
		end
		return;
    end
%-------------------------------------------------------------------
if size(ISO,1)>1
    for i=1:size(ISO,1)
        Indiv=ISO(i,:);

         for index=1:ParaSetting.D
             Indiv2=Indiv;
             if rand()<0.2
                Indiv2(1,index)=rand()*(2*radius1)+ (-radius1)+Indiv(1,index);
             else
                Indiv2(1,index)=rand()*(ParaSetting.UpperLimit(index)- ParaSetting.LowerLimit(index))+ ParaSetting.LowerLimit(index);  
             end
             Indiv2 = Evaluation(ParaSetting,Indiv2(1,1:ParaSetting.D));   
             if Indiv2(1,ParaSetting.D+1)<ISO(i,ParaSetting.D+1)
                ISO(i,:)=Indiv2;
                Indiv=Indiv2 ;
             end
         end % for
    end
    count1=count1+size(ISO,1);
%-----------------------------------------------------------------
	ISO=sortrows(ISO,ParaSetting.D+1);
	if ISO(1,ParaSetting.D+1) < CR.GobalBestInd(1,ParaSetting.D+1)
		CR.GobalBestInd=ISO(1,:);
    end
end

%------------------------------------------------------------------
	% The centers of all schools are close to the present best optimal solution ;
    c1=rand();
% 	Population=Population(:,1:ParaSetting.D);
	CurBestSol=CR.GobalBestInd;
    offerset=(-radius1+rand()*(2*radius1));
	for i=1:ParaSetting.SchoolNum
		 for j=1:ParaSetting.D
			 RemoveDistance(i,j)=c1*(CurBestSol(j)-ParaSetting.SchoolInfor(i,j));
			 ParaSetting.SchoolInfor(i,j)=ParaSetting.SchoolInfor(i,j)+RemoveDistance(i,j)+offerset; 
		 end
    end
 end
%%-------------------------------------------------------------------------------------
function [particalCoordinate] = Oval(ParaSetting,k,radius1)
% step1 Generate HyperSphere
theta1 = linspace(0, 2*pi, ParaSetting.SchoolSize) ;
if ParaSetting.D >= 2
    if  rem(ParaSetting.D,2) == 0
        particalCore = zeros(ParaSetting.SchoolSize,ParaSetting.D);
        for i = 1 : ParaSetting.D / 2
            theta = theta1 +  rand() * 2* pi ;
            particalCore_2 = [cos(theta').* radius1,sin(theta').* radius1] ;
            particalCore(:,2*i-1:2*i)= particalCore_2 ;
        end      
        center = repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
        particalCoordinate = particalCore + center ;       
    else
        particalCore = zeros(ParaSetting.SchoolSize,ParaSetting.D+1);
        for i = 1 : (ParaSetting.D/2+1)
            theta = theta1 +  rand() * 2* pi ;
            particalCore_2 = [cos(theta') .* radius1,sin(theta') .* radius1] ;
            particalCore(:,2*i-1:2*i)= particalCore_2 ;
        end
        particalCore(:,end) = [] ;
        center =repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
        particalCoordinate = particalCore + center ;
    end   
else
    exit
    disp('The dimension is at least 2!');
end
% step2  Limit variable range

for i=1:size(particalCoordinate,1)
    kdxub=find(particalCoordinate(i,:)>ParaSetting.UpperLimit);
    kdxlb=find(particalCoordinate(i,:)<ParaSetting.LowerLimit);
	particalCoordinate(i,kdxub) = ParaSetting.UpperLimit(kdxub) ; 
	particalCoordinate(i,kdxlb) = ParaSetting.LowerLimit(kdxlb);
end


% particalCoordinate(find(particalCoordinate>ParaSetting.UpperLimit)) = ParaSetting.UpperLimit ;
% particalCoordinate(find(particalCoordinate<ParaSetting.LowerLimit)) = ParaSetting.LowerLimit ;
end
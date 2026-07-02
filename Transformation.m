%%-------------------------------------------------------------------------------------
function [ParaSetting,Population]=Transformation(Population,ParaSetting,AR,radius1)
	radius=[5,10,15,20,25,30]*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2); 
    m = ParaSetting.Gen ; 
	if m >2
	   for k = 1 : ParaSetting.SchoolNum   
		  if  AR.MomPointArr(3,m-1,k) < sum(AR.MomPointArr(3,1:m-2,k))/m  
			  if  ParaSetting.SchoolInfor(k,end) == 1                        
				  ParaSetting.SchoolInfor(k,end) = round(2+rand()) ;                     
			  else 
				  ParaSetting.SchoolInfor(k,end) = 1 ; 
			  end
		  end
		end
	end

	for k = 1 : ParaSetting.SchoolNum
        index=mod(k,size(radius,6)); 
        if index~=0
            radius1=radius(index)*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2);  
        else
            radius1=radius(size(radius,2))*exp(-5*(ParaSetting.EvaluationCount/ParaSetting.EvaluationFunctionCountThreshold)^2);  
        end 
		if ParaSetting.SchoolInfor(k,end)==1 
			[particalCoordinate] = Oval(ParaSetting,k,radius1) ;
		elseif ParaSetting.SchoolInfor(k,end)==2   
			[particalCoordinate] = CresentShape(ParaSetting,k,radius1);

		else 
			[particalCoordinate] = Elongated(ParaSetting,k,radius1) ;

		end
		Population(ParaSetting.SchoolSize*(k-1)+1:ParaSetting.SchoolSize*k,1:end-1) = particalCoordinate ;
	end
	
	[Population] = Evaluation(ParaSetting,Population(:,1:end-1)) ;
    for k = 1 : ParaSetting.SchoolNum
		TransMat = sortrows(Population(ParaSetting.SchoolSize*(k-1)+1:ParaSetting.SchoolSize*k ,:),ParaSetting.D+1) ;
		Population(ParaSetting.SchoolSize*(k-1)+1:ParaSetting.SchoolSize*k,:) = TransMat ;
	end

	if m > 2
	   for k = 1 : ParaSetting.SchoolNum
		   if Population(ParaSetting.SchoolSize*(k-1)+1,end) > AR.MomFit(1,m-1,k)
			  ParaSetting.SchoolInfor(k,1:ParaSetting.D) = Population(ParaSetting.SchoolSize*(k-1)+1,1:end-1) ;
		   end
	   end
	end
	
end 
   
%%-------------------------------------------------------------------------------------
function [particalCoordinate] = CresentShape(ParaSetting,k,radius1)
	if ParaSetting.D >= 2 
	    if  rem(ParaSetting.D,2) == 0 
		   particalCore = zeros(ParaSetting.SchoolSize,ParaSetting.D/2) ;
		   for i = 1 : ParaSetting.D/2             
			    [particalCore_2] = CresentShape2D(ParaSetting,radius1) ;   
				particalCore(:,i*2-1:i*2) = particalCore_2;               
		   end
		   center =repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
		   particalCoordinate = particalCore + center ;
				 
	    else   
		    particalCore = zeros(ParaSetting.SchoolSize,(ParaSetting.D+1)/2) ;
			for i = 1 : (ParaSetting.D/2+1)                
				[particalCore_2] = CresentShape2D(ParaSetting,radius1) ;
				particalCore(:,i*2-1:i*2) = particalCore_2;
			end              
			particalCore(:,end) = [] ;
		    center =repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
			particalCoordinate = particalCore + center ;
		end
	else   
		 disp('The dimension is at least 2!');
		 exit
    end
    
    for i=1:size(particalCoordinate,1)
        kdxub=find(particalCoordinate(i,:)>ParaSetting.UpperLimit);
        kdxlb=find(particalCoordinate(i,:)<ParaSetting.LowerLimit);
        particalCoordinate(i,kdxub) = ParaSetting.UpperLimit(kdxub) ;
        particalCoordinate(i,kdxlb) = ParaSetting.LowerLimit(kdxlb);
    end
% 	particalCoordinate(find(particalCoordinate>ParaSetting.UpperLimit)) = ParaSetting.UpperLimit ;
% 	particalCoordinate(find(particalCoordinate<ParaSetting.LowerLimit)) = ParaSetting.LowerLimit ;
	
end

%%-------------------------------------------------------------------------------------
function [particalCore] = CresentShape2D(ParaSetting,radius1)
% step1 Set parameters
a = 1; % Quadratic function coefficient
% step2 Generate 2D crescent
X = linspace(-radius1/2,radius1/2,ParaSetting.SchoolSize) ;
Y  = a .* (X.^2)  ;
particalCore = [X',Y'] ;
% step3  add randomness
detaSita = rand * 2* pi ;
xx = particalCore(:,1) ;
yy = particalCore(:,2) ;
particalCore(:,1) =  xx * cos(detaSita) - yy * sin(detaSita) ;
particalCore(:,2) =  xx * sin(detaSita) + yy * cos(detaSita) ;
end

%%-------------------------------------------------------------------------------------
function [particalCoordinate] = Elongated(ParaSetting,k,radius1)
	if ParaSetting.D >= 2 
	   if  rem(ParaSetting.D,2) == 0   
			particalCore = zeros(ParaSetting.SchoolSize,ParaSetting.D/2) ;
			for i = 1 : ParaSetting.D/2             
				[particalCore_2] = Elongated2D(ParaSetting,radius1) ;   
				 particalCore(:,i*2-1:i*2) = particalCore_2;               
			end
			center =repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
			particalCoordinate = particalCore + center ;
		else  
			particalCore = zeros(ParaSetting.SchoolSize,(ParaSetting.D+1)/2) ;
			for i = 1 : (ParaSetting.D/2+1)                
				[particalCore_2] = Elongated2D(ParaSetting,radius1) ;
				 particalCore(:,i*2-1:i*2) = particalCore_2;
			end
			particalCore(:,end) = [] ;
			center =repmat(ParaSetting.SchoolInfor(k,1:ParaSetting.D),ParaSetting.SchoolSize,1);
			particalCoordinate = particalCore + center ;
		end
	else   
		 disp('The dimension is at least 2!');
		 exit
    end
    
    
    for i=1:size(particalCoordinate,1)
    kdxub=find(particalCoordinate(i,:)>ParaSetting.UpperLimit);
    kdxlb=find(particalCoordinate(i,:)<ParaSetting.LowerLimit);
	particalCoordinate(i,kdxub) = ParaSetting.UpperLimit(kdxub) ; 
	particalCoordinate(i,kdxlb) = ParaSetting.LowerLimit(kdxlb);
    end
% 
%     kdxub=find(particalCoordinate>ParaSetting.UpperLimit);
%     kdxlb=find(particalCoordinate<ParaSetting.LowerLimit);
% 	particalCoordinate(kdxub) = ParaSetting.UpperLimit(kdxub) ; 
% 	particalCoordinate(kdxlb) = ParaSetting.LowerLimit(kdxlb);
	
end

%%-------------------------------------------------------------------------------------
function [particalCore] = Elongated2D(ParaSetting,radius1)
% step1 Set parameters	
	WidthNum = 4;
    TempSchoolSize = ParaSetting.SchoolSize;
 % step2 Generate 2D Banded  
	if rem(TempSchoolSize,WidthNum) == 0
	       ii = 1 : (TempSchoolSize/4) ;
           x =  -radius1/2 + ii * radius1 / (TempSchoolSize/4);
           x=x(:);
           y1 = ones(TempSchoolSize/4,1)*(-radius1/10);
           y1=y1(:);
           y2 = ones(TempSchoolSize/4,1)*(-radius1/20);
           y2=y2(:);
           y3 = ones(TempSchoolSize/4,1)*(radius1/10);
           y3=y3(:);
           y4 = ones(TempSchoolSize/4,1)*(radius1/20);
           y4=y4(:);
           y = [y1;y2;y3;y4];
           x=repmat(x,4,1);
           particalCore=[x,y];
	else 
		remainder = rem(TempSchoolSize,WidthNum); 
        TempSchoolSize = TempSchoolSize + (WidthNum - remainder);
         ii = 1 : (TempSchoolSize/4);
           x =  -radius1/2 + ii * radius1 / (TempSchoolSize/4);
           x=x(:);
           y1 = ones(TempSchoolSize/4,1)*(-radius1/10);
           y1=y1(:);
           y2 = ones(TempSchoolSize/4,1)*(-radius1/20);
           y2=y2(:);
           y3 = ones(TempSchoolSize/4,1)*(radius1/10);
           y3=y3(:);
           y4 = ones(TempSchoolSize/4,1)*(radius1/20);
           y4=y4(:);
           y = [y1;y2;y3;y4];
           x=repmat(x,4,1);
           particalCore=[x,y];	
           delNum = WidthNum - remainder ;
          particalCore([1:4:delNum*4],:)=[];		
	 end
% step3  add randomness
detaSita = rand * 2* pi ;
xx = particalCore(:,1) ;
yy = particalCore(:,2) ;
particalCore(:,1) =  xx * cos(detaSita) - yy * sin(detaSita) ;
particalCore(:,2) =  xx * sin(detaSita) + yy * cos(detaSita) ;
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
	particalCoordinate(i,kdxub) = ParaSetting.UpperLimit(kdxub); 
	particalCoordinate(i,kdxlb) = ParaSetting.LowerLimit(kdxlb);
end
% particalCoordinate(find(particalCoordinate>ParaSetting.UpperLimit)) = ParaSetting.UpperLimit ; %#ok<*FNDSB>%²éÕÒ´óÓÚParaSetting.LowerLimitµÄÔªËØ
% particalCoordinate(find(particalCoordinate<ParaSetting.LowerLimit)) = ParaSetting.LowerLimit ;
end
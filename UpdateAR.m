%%-------------------------------------------------------------------------------------
function [AR]=UpdateAR(ParaSetting,AR,Population)
	m = ParaSetting.Gen ; 
	for k = 1 : ParaSetting.SchoolNum
		AR.MomPointArr(1,m,k) = m-1 ;
		AR.MomPointArr(2,m,k) = m ;
	end

	if m > 2  
	   for k = 1 : ParaSetting.SchoolNum     
		   [MomValue]=ARComputer(ParaSetting,AR,k) ;
		   AR.MomPointArr(3,m-1,k) = MomValue ;
	   end
	end

	if m >1
		 for k = 1 : ParaSetting.SchoolNum
			 AR.MomFit(:,m-1,k) = Population(ParaSetting.SchoolSize*(k-1)+1,end) ;
         end
    end
end

%%-------------------------------------------------------------------------------------
function [MomValue]=ARComputer(ParaSetting,AR,k)
	m = ParaSetting.Gen ; 
	if m > 2 
        a = AR.MomFit(1,m-1,k) ;
        b = AR.MomFit(1,m-2,k) ;
        if  a >0 && b >0
            if a / b < AR.threshold
                MomValue = 1 ; 
            else 
                MomValue = 0 ;
            end
       elseif a <0 && b <0
              if (-b) / (-a) < AR.threshold
                    MomValue = 1 ;
                else 
                    MomValue = 0 ;
              end
        elseif a<b
                 MomValue = 1 ;
        else
                 MomValue = 0 ;
        end
	end
end
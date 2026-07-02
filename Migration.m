
function [ParaSetting,AR] = Migration(AR,ParaSetting)      %SOA中所拥有的
	m = ParaSetting.Gen ;   
	T1=10;
	if m > T1  
		for k = 1: ParaSetting.SchoolNum
            A = AR.MomPointArr(3,m-T1+1:m,k) ;
			if m - AR.LevyPoint(k) > T1
				if sum(A)/T1 <= 1/T1    
					Nstep = 15 ;
					[ParaSetting]=LevyFlight(Nstep,k,ParaSetting) ;
					AR.LevyPoint(k) = m ;
				end
			end
		end
	end
end

%%-------------------------------------------------------------------------------------
function [ParaSetting]=LevyFlight(Nstep,k,ParaSetting)
	for i=1:Nstep
		[ROW,COLUM] = size(ParaSetting.SchoolInfor(k,1:ParaSetting.D)) ;
		beta =1.5 ;
		alpha = 2 ;
		sigma_u = (gamma(1+beta)*sin(pi*beta/2)/(beta*gamma((1+beta)/2)*2^((beta-1)/2)))^(1/beta) ;
		sigma_v = 1 ;
		u = normrnd(0,sigma_u,ROW,COLUM) ;
		v = normrnd(0,sigma_v,ROW,COLUM) ;
		step = u./(abs(v) .^ (1/beta)) ;
		ParaSetting.SchoolInfor(k,1:ParaSetting.D) = ParaSetting.SchoolInfor(k,1:ParaSetting.D)+alpha .* step ;
		ParaSetting.SchoolInfor(find(ParaSetting.SchoolInfor(k,1:ParaSetting.D)>ParaSetting.UpperLimit)) = ParaSetting.UpperLimit(find(ParaSetting.SchoolInfor(k,1:ParaSetting.D)>ParaSetting.UpperLimit)) ;
		ParaSetting.SchoolInfor(find(ParaSetting.SchoolInfor(k,1:ParaSetting.D)<ParaSetting.LowerLimit)) = ParaSetting.LowerLimit(find(ParaSetting.SchoolInfor(k,1:ParaSetting.D)<ParaSetting.LowerLimit)) ;
	end
end
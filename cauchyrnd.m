function r= cauchyrnd(varargin)

	a=	0.0;
	b=	1.0;
	n=	1;
	
	
	% Check the arguments
	if(nargin >= 1)
		a=	varargin{1};
		if(nargin >= 2)
			b=			varargin{2};
			b(b <= 0)=	NaN;	% Make NaN of out of range values.
			if(nargin >= 3),	n=	[varargin{3:end}];		end
		end
	end
	
	
	% Generate
	r=	cauchyinv(rand(n), a, b);
end

function x= cauchyinv(p, varargin)


	% Default values
	a=	0.0;
	b=	1.0;
	
	
	% Check the arguments
	if(nargin >= 2)
		a=	varargin{1};
		if(nargin == 3)
			b=			varargin{2};
			b(b <= 0)=	NaN;	% Make NaN of out of range values.
		end
	end
	if((nargin < 1) || (nargin > 3))
		error('At least one argument, at most three!');
	end
	
	p(p < 0 | 1 < p)=	NaN;
	
	
	% Calculate
	x=			a + b.*tan(pi*(p-0.5));
	
	% Extreme values. 
	if(numel(p) == 1), 	p= repmat(p, size(x));		end
	x(p == 0)=	-Inf;
	x(p == 1)=	Inf;
end



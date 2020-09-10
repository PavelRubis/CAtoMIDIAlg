function [period] = traceElement(n, row, column, iterations)
% n is the matrix order, row and column are the initial row and column,
% iterations is the maximum number of steps to trace
%
% returns the period, i. e. number of steps
% until the return to the initial position

C=(1:n)';
[X,Y]=meshgrid(C,C-1);
M=X+n*Y;

newF_v=zeros(n,n);
newF_v(:,1:3:n)=1;
newF_v(:,2:3:n)=0;
newF_v(:,3:3:n)=-1;

newF_g=zeros(n,n);
newF_g(1:3:n,:)=1;
newF_g(2:3:n,:)=0;
newF_g(3:3:n,:)=-1;

f_v=newF_v(row,column);
f_g=newF_g(row,column);

trace = zeros(iterations + 1,2);
trace(1,:) = [row, column];

l = true;

oldF_v=newF_v;
oldF_g=newF_g;

period =0;
newM=M;
for t = 2:(iterations + 1)
    
    if(l)
        curFlag=f_v;
    else
        curFlag=f_g;
    end
        
        switch curFlag

         case -1

             if (l)
              trace(t, 1) = trace(t - 1, 1) + 1; % down ~ row + 1
              trace(t, 2) = trace(t - 1, 2);
             else
              trace(t, 2) = trace(t - 1, 2) - 1; % left ~ column - 1
              trace(t, 1) = trace(t - 1, 1);             
             end

            case 0
            
              trace(t, 1) = trace(t - 1, 1);
              trace(t, 2) = trace(t - 1, 2);
                 
            case 1
            
            if (l)
              trace(t, 1) = trace(t - 1, 1) - 1; % up ~ row - 1
              trace(t, 2) = trace(t - 1, 2);
            else
              trace(t, 2) = trace(t - 1, 2) + 1; % right ~ column + 1
              trace(t, 1) = trace(t - 1, 1);
            end
        
        end
        
        if(l)
            if(t~=2)
                [newF_g,newM] = Schema101(M,newF_g);
                M=newM;
            end
            
            if(mod(trace(t, 2),n)==0 || trace(t, 2)==n)
                ind2=n;
            else
                ind2=mod(trace(t, 2),n);
            end
            
            if(mod(trace(t, 1),n)==0 || trace(t, 1)==n)
                ind1=n;
            else
                ind1=mod(trace(t, 1),n);
            end
            
            f_g=newF_g(ind1,ind2);
            
        else
            
            [newF_v,newM] = Schema101(M,newF_v);
            M=newM;
            
            if(mod(trace(t, 2),n)==0 || trace(t, 2)==n)
                ind2=n;
            else
                ind2=mod(trace(t, 2),n);
            end
            
            if(mod(trace(t, 1),n)==0 || trace(t, 1)==n)
                ind1=n;
            else
                ind1=mod(trace(t, 1),n);
            end
            
            f_v=newF_v(ind1,ind2);
                
        end
          
    l=~l; 
    
    if all(mod(trace(t, :) - [row, column], n) == 0)  && t~=2
        trace = trace(1:t,:);
        period = t - 1;
        if mod(period,6)==0
            period=period/6;
            break;
        end
    end 
    
    if t==(iterations + 1)
        period=0;
    end
    
  end

end
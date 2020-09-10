function [newFlags, newM] = Schema101(M, flags)

newFlags=flags;
n=sqrt(numel(M));
newM=zeros(n,n);

% period_= -1.1;
% while(1)
%     if(period_== -1.1)
%         period_=0;
%     end
%     if(isequal(oldM,M)&& period_~=0 && ((mod(period_,6))==0))
%         break;
%     end
for i=1:n
    for j=1:n
        
        f_up=0;
        f_dn=0;
        f_rt=0;
        f_lt=0;
        s_up=0;
        s_dn=0;
        s_rt=0;
        s_lt=0;
        switch i
            case 1
                f_up = flags(n,j);
                s_up = M(n,j);
                
                f_dn = flags(i+1,j);
                s_dn = M(i+1,j);
            case n
                f_up = flags(i-1,j);
                s_up = M(i-1,j);
                
                f_dn = flags(1,j);
                s_dn = M(1,j);
            otherwise
                f_up = flags(i-1,j);
                s_up = M(i-1,j);
                
                f_dn = flags(i+1,j);
                s_dn = M(i+1,j);
        end
        
        switch j
            case 1
                f_lt = flags(i,n);
                s_lt = M(i,n);
                
                f_rt = flags(i,j+1);
                s_rt = M(i,j+1);
            case n
                f_lt = flags(i,j-1);
                s_lt = M(i,j-1);
                
                f_rt = flags(i,1);
                s_rt = M(i,1);
            otherwise
                f_lt = flags(i,j-1);
                s_lt = M(i,j-1);
                
                f_rt = flags(i,j+1);
                s_rt = M(i,j+1);
        end
        
        %условия сдвигов
        switch flags(i,j)
                
            case -1
                if(f_up==-1 && f_dn==-1)
                    newM(i,j)=s_up;
                else
                    newM(i,j)=s_rt;
                end
                
            case 0
                newM(i,j)=M(i,j);
            
            case 1
                if(f_up==1 && f_dn==1)
                    newM(i,j)=s_dn;
                else
                    newM(i,j)=s_lt;
                end
                
        end
        %конец условий сдвигов
        
        %условия изменения флагов перемещения и сдвигов
            switch flags(i,j)
        
               case -1
                   newFlags(i,j)=1;

               case 0
                   newFlags(i,j)=-1;
        
               case 1
                   newFlags(i,j)=0;
        
            end
        %конец условий изменения флагов перемещения
        
    end
      
end

M=newM;
% period_=period_+1;
% 
% end
% period=(period_)/6;
end
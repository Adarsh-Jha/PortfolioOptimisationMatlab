function [f_nodes,d2,m2,s2,z2,last_z]=get_stock_data(lag,d_agg,n_agg,m_agg,s_agg,z_agg)

[unode1,IX]=sort(n_agg);
[nodes2,pos] = unique(unode1);
counts=diff([pos;length(n_agg)+1]);
ind = counts==lag;
pos = pos(ind);%nodes2 with complete history
f_nodes = nodes2(ind);%nodes2 with complete history
N = length(f_nodes);
    
    d2 = zeros(lag,size(d_agg,2),N);
    m2 = zeros(lag,size(m_agg,2),N);
    s2 = zeros(lag,size(s_agg,2),N);
    z2 = zeros(lag,size(z_agg,2),N);
    
    for k = 1:N
        ind = IX(pos(k):(pos(k)+ lag -1));
        d2(:,:,k) = d_agg(ind,:);
        m2(:,:,k) = m_agg(ind,:);
        s2(:,:,k) = s_agg(ind,:);
        z2(:,:,k) = z_agg(ind,:);
        
    
        last_z(k)=z2(end,2,k);
     
    end

    

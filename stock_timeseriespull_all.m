function [stock_data,stock_name,mean_data,std_data,z_data]=stock_timeseriespull_all(begin_date,end_date,folder1,folder2)
    
date_vec=begin_date:1:end_date;

ndata=[];
ddata=[];
mdata=[];
sdata=[];
zdata=[];
cd(folder1)
for iter=1:length(date_vec)
iter;
date_format=year(date_vec(iter))*10000+month(date_vec(iter))*100+day(date_vec(iter));
strdate=['stocks_',num2str(date_format),'.mat'];

load(strdate);
ndata=[ndata;stock_name'];
ddata=[ddata;stock_data];
mdata=[mdata;mean_data];
sdata=[sdata;std_data];
zdata=[zdata;z_data];
end
cd(folder2)

stock_data=ddata;
stock_name=ndata;
mean_data=mdata;
std_data=sdata;
z_data=zdata;


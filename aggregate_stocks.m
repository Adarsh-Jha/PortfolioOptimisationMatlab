clear all;
load allstocks.mat

%Load file directories
folder1=[pwd,'\stock_data'];
folder2=pwd;

begin_date=stock_matrix(1,1,1);
end_date=stock_matrix(end,1,1);
date_vec=begin_date:1:end_date;

%Loop over date range
for iter=1:1:length(date_vec)

date_format=year(date_vec(iter))*10000+month(date_vec(iter))*100+day(date_vec(iter));
strdate=['stocks_',num2str(date_format),'.mat']


f=find(stock_matrix(:,1,1)==date_vec(iter));
clear stock_data; clear mean_data; clear std_data; clear z_data;
for i=1:length(stock_name)

stock_data(i,:)=stock_matrix(f,:,i);
mean_data(i,:)=mean_matrix(f,:,i);
std_data(i,:)=std_matrix(f,:,i);
z_data(i,:)=z_matrix(f,:,i);

end



cd(folder1)
save(strdate, 'stock_name', 'stock_data','mean_data','std_data','z_data')
cd(folder2)
end

delete allstocks.mat
clear all;

%Load file directories
folder1=[pwd,'\stock_data'];
folder2=pwd;
folder3=[pwd,'\stock_data_base'];

%Pull S&P stock symbols
[x,stocks,z]=xlsread('s&p500.xlsx');

%Find lag
lag=30;

begin_date=datenum('1/1/2008');
end_date=floor(now)-1;
datevector=[begin_date:1:end_date]';

cd(folder3)
counter=1;
for i=1:length(stocks)

stock=char(stocks(i));
stock_file=[stock,'.csv'];

if exist(stock_file)>0
[s1,s2,s3]=xlsread(stock_file);

stock_name(counter)=stocks(i);
stock_matrix(:,:,counter)=nan(length(datevector),6);
stock_matrix(:,1,counter)=datevector;
mean_matrix(:,:,counter)=nan(length(datevector),6);
mean_matrix(:,1,counter)=datevector;
std_matrix(:,:,counter)=nan(length(datevector),6);
std_matrix(:,1,counter)=datevector;
z_matrix(:,:,counter)=nan(length(datevector),6);
z_matrix(:,1,counter)=datevector;

stock_data_temp=[datenum(s2(2:end,1)),s1];
for j=1:length(datevector)
stock_f=find(stock_data_temp(:,1)==datevector(j));


if ~isempty(stock_f) && size(stock_data_temp,1)>stock_f+lag
stock_f=stock_f(1);
stock_matrix(j,2:6,counter)=stock_data_temp(stock_f,2:end);
mean_matrix(j,2:6,counter)=nanmean(stock_data_temp(stock_f+1:stock_f+lag,2:end));
std_matrix(j,2:6,counter)=std(stock_data_temp(stock_f+1:stock_f+lag,2:end));  
z_matrix(j,2:6,counter)=(stock_matrix(j,2:6,counter)-mean_matrix(j,2:6,counter))./std_matrix(j,2:6,counter);    
end
    
end



counter=counter+1;
end

i;
end
cd(folder2)

save('allstocks.mat', 'stock_name', 'stock_matrix', 'mean_matrix','std_matrix','z_matrix')


% 
% cd(folder1)
% save(strdate, 'stocks', 'stock_data','mean_data','std_data','z_data','dte')
% cd(folder2)


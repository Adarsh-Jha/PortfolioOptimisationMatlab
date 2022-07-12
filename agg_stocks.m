function [stock_data,mean_data,std_data,z_data]=agg_stocks(dte,ticker,lag)


stocks_temp=char(ticker);
stock_file=[stocks_temp,'.csv'];


s1=[]; s2=[]; s3=[];
[s1,s2,s3]=xlsread(stock_file);


dtes=datenum(s2(2:end,1));
f=find(dtes==dte);

stock_data=s1(f,:);
mean_data=mean(s1(f+1:f+lag,:));
std_data=std(s1(f+1:f+lag,:));
z_data=(stock_data-mean_data)./std_data;


end


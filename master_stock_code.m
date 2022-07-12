%Author: Moeti Ncube

clear all; close all; format long g;

%Indicator to run section 1
ind=1;


if ind==1
%% Section 1: Only need to be run once per day
%Pull 10 years of daily stock prices, up to yesterday, from the S&P 500 stock list in
%s&p500.xlsx file.
pull_stocks;
%Resaves stock data with addition statistics:
% mean_data: 30 day historical average ohlc prices
% std_data: 30 day historical std ohlc prices
% z-data: z score movement from historical price levels
%(currently resaves data from 2008 up to yesterday's
%date)
resave_stock_data
%Reformats files into a format that is allows for cross-sectional
%backtesting
aggregate_stocks

%Pull S&P500 data as baseline indicator
sp_price='^GSPC';
getyahoo10(sp_price,pwd);

%%
end
sp_price='^GSPC';

%% Section 2: This section performes the optimization

%File directory labels
folder_base=pwd;
folder_stock_data_base=[pwd,'\stock_data_base'];
folder_stock_data=[pwd,'\stock_data'];

%Number of days in optimized period
hist_lag=90; 

%Out of sample date
begin_date=floor(now)-1;
end_date=floor(now)-1;

%Risk tolerance parameter for mv criterion
mw_alpha=.01;
%Transaction costs (Based on tiered pricing structure from IB)
trans_cost=0.0035;
%Bid alpha: how many alpha standard deviations off the open price
bid_alpha=.25;

%Strategy overview: 

%The Algorithm take each stock, within the s&p 500, and submits the following limit orders: 
% 1) Bid Limit order: mean-alpha std deviations
% 2) Off Limit order: mean+alpha std deviations
% The historical performance of each bidding strategy over
% the past 'hist_lag' period is treated as individual strategy within a
% portfolio basket of strategies.

%The algorithm assigns a weighting, between 0 and 1, to each individual strategy, 
%so that the Mean-Variance criteria over the entire portfolio basket of
%strategies is optimized. 

%This code applies a unique approach to this
%optimization (see optimization section), using ideas from dynamic programming, 
%to quickly compute the optimization of a large portfolio matrix

%The optimal allocation, determine over the previous hist_lag period, is
%then applied the next day 'out of sample'. 

%This procedure is iteratively backtested from the 'begin_date' to the
%'end_date'; the daily % return performance is computed and stored.

%Variables:
%port_hist: The historical performance of the optimal collection of stocks

%port_matrix: The optimized basket of stocks
%column1: The stock location
%column2: Long=1, Short=-1;
%column3: weight of row, sum of column3 equals 1
%column4: return of row out of sample.

datevector=datenum(begin_date):1:datenum(end_date);
d_agg=[]; n_agg=[]; m_agg=[]; s_agg=[]; z_agg=[];
for iter=1:length(datevector)

%Create dataset matrices for daily backtests, 
if iter==1
[d_temp,n_temp,m_temp,s_temp,z_temp]=stock_timeseriespull_all(datevector(iter)-hist_lag,datevector(iter)-2,folder_stock_data,folder_base);
d_hist=[d_agg;d_temp]; n_hist=[n_agg;n_temp]; m_hist=[m_agg;m_temp]; s_hist=[s_agg;s_temp]; z_hist=[z_agg;z_temp];
else
[d_temp,n_temp,m_temp,s_temp,z_temp]=stock_timeseriespull_all(datevector(iter)-2,datevector(iter)-2,folder_stock_data,folder_base);
f=length(find(d_hist(:,1)==d_hist(1,1)))+1;
d_hist=[d_hist(f:end,:);d_temp]; n_hist=[n_hist(f:end,:);n_temp]; m_hist=[m_hist(f:end,:);m_temp]; s_hist=[s_hist(f:end,:);s_temp]; z_hist=[z_hist(f:end,:);z_temp];
end

[d_fcst_1,n_fcst_1,m_fcst_1,s_fcst_1,z_fcst_1]=stock_timeseriespull_all(datevector(iter)-1,datevector(iter)-1,folder_stock_data,folder_base);
[d_fcst_2,n_fcst_2,m_fcst_2,s_fcst_2,z_fcst_2]=stock_timeseriespull_all(datevector(iter),datevector(iter),folder_stock_data,folder_base);
d_agg=[d_hist;d_fcst_1;d_fcst_2]; n_agg=[n_hist;n_fcst_1;n_fcst_2]; m_agg=[m_hist;m_fcst_1;m_fcst_2]; s_agg=[s_hist;s_fcst_1;s_fcst_2]; z_agg=[z_hist;z_fcst_1;z_fcst_2];

d_length=hist_lag+1;
[stock_list,d_final,m_final,s_final,z_final,last_z]=get_stock_data(d_length,d_agg,n_agg,m_agg,s_agg,z_agg);


%% Optimization section
port_hist=zeros(1,hist_lag); wght_node=[0:.01:1]'; 
weight_vector=[]; return_vector=[]; row_iter=1; 
clear return_long; clear long_values; clear return_short; clear short_values; 
clear z_vector; clear ls_vector; clear stock_vector;
for i=1:length(stock_list)

%OHLC history, hist mean and std. dev histories.
open_hist=d_final(:,2,i);
high_hist=d_final(:,3,i);
low_hist=d_final(:,4,i);
close_hist=d_final(:,5,i);
mu_hist=m_final(:,2,i);
std_hist=s_final(:,2,i);

% Long bidding: bid 'alpha std. deviations' below the open price
% If Low of day is less than submitted bid, we assume our order would have
% cleared in market. Exit position at the close of the day.
bid=mu_hist-bid_alpha*std_hist;
return_long=(low_hist<bid).*((close_hist'-bid'-2*trans_cost)./bid')';
return_long(isnan(return_long))=0;

off=mu_hist+bid_alpha*std_hist;
return_short=(high_hist>off).*((off'-close_hist'-2*trans_cost)./off')';
return_short(isnan(return_short))=0;

stock_hist_long=return_long(1:end-1)';
clear mv_temp;
for j=1:length(wght_node)
port_hist_temp=wght_node(j)*port_hist+(1-wght_node(j))*stock_hist_long;
mv_temp(j)=var(port_hist_temp)-mw_alpha*mean(port_hist_temp);
end
[temp_1,temp_2]=min(mv_temp);
port_hist=wght_node(temp_2)*port_hist+(1-wght_node(temp_2))*stock_hist_long;

weight_vector=wght_node(temp_2)*weight_vector;
weight_vector(row_iter)=(1-wght_node(temp_2));
return_vector(row_iter)=return_long(end);
ls_vector(row_iter)=1;
stock_vector(row_iter)=i;

row_iter=row_iter+1;

stock_hist_short=return_short(1:end-1)';
clear mv_temp;
for j=1:length(wght_node)
port_hist_temp=wght_node(j)*port_hist+(1-wght_node(j))*stock_hist_short;
mv_temp(j)=var(port_hist_temp)-mw_alpha*mean(port_hist_temp);
end
[temp_1,temp_2]=min(mv_temp);
port_hist=wght_node(temp_2)*port_hist+(1-wght_node(temp_2))*stock_hist_short;

weight_vector=wght_node(temp_2)*weight_vector;
weight_vector(row_iter)=(1-wght_node(temp_2));
return_vector(row_iter)=return_short(end);
ls_vector(row_iter)=-1;
stock_vector(row_iter)=i;

row_iter=row_iter+1;


end

port_matrix_temp=[stock_vector',ls_vector',weight_vector',return_vector'];
port_matrix=port_matrix_temp(port_matrix_temp(:,3)>0,:);

end

date_one=datevector(iter)-hist_lag;
date_two=datevector(iter)-1;

hist_dtes=date_one:1:date_two;
%Pull S&P500 data as baseline indicator, compute cumulative return over the
%historical lag period.
stock_file=[sp_price,'.csv'];
[s1,s2,s3]=xlsread(stock_file);
s500_data=[datenum(s2(2:end,1)),s1];
f=find(s500_data(:,1)>=date_one & s500_data(:,1)<=date_two);
s500_data_2=s500_data(f,:);
close_cumret=(s500_data_2(:,end-1)-s500_data_2(end,end-1))./s500_data_2(end,end-1);
clear adj_cumret;
for i=1:hist_lag
[m1,m2]=min(abs(s500_data_2(:,1)-hist_dtes(i)));
adj_cumret(i)=close_cumret(m2);
end

%Plots the cumulative return performance
hold on
title('Cumulative Portfolio Return over historical period compared to S&P 500 performance')
plot(hist_dtes,cumsum(port_hist),'b')
plot(hist_dtes,adj_cumret,'r')
legend('Mean-Variance Optimized Cumulative Return','S&P 500 Cumulative Return')
datetick('x','yyyymm','keeplimits')

xlabel('Dates')
ylabel('Cumulative Percentages')

a=[cellstr(num2str(get(gca,'ytick')'*100))];
pct = char(ones(size(a,1),1)*'%'); 
new_yticks = [char(a),pct];
set(gca,'yticklabel',new_yticks); 
%%

%One day out of sample portfolio return
oos_date=year(datevector(iter))*10000+month(datevector(iter))*100+day(datevector(iter));
oos_ret=sum(port_matrix(:,end-1).*port_matrix(:,end));
oos_return=[oos_date,oos_ret]
clear all;
stock_dir=[pwd,'\stock_data_base'];



[x,y,z]=xlsread('s&p500.xlsx');


for i=1:length(y)

stocks_temp{i}=char(y(i));


try
getyahoo10(stocks_temp{i}, stock_dir);
catch
stocks_temp{i}=[];
end

i;
end
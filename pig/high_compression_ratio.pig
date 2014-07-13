-- register 
REGISTER DuckPigUdf.jar;

-- set 
set mapred.min.split.size 1048576;
set pig.maxCombinedSplitSize 1048576;

-- define 
DEFINE duck_storage duck.java.pig.udf.storage();

-- clean up 
rmf $output_data_path;

-- load data
raw_events = LOAD '$input_data_path' USING duck_storage;

group_all = GROUP raw_events ALL;
count_all = FOREACH group_all GENERATE COUNT_STAR(raw_events) AS total_count;

group_events = GROUP raw_events BY (money) PARALLEL 10;

count_events = FOREACH  group_events{
                m_count = COUNT_STAR(raw_events);
                GENERATE flatten(raw_events) AS (*), m_count AS m_count;
};

total_events = CROSS count_all, count_events;

result  = FOREACH total_events {
			rate = (double)count_events::m_count/count_all::total_count;
			GENERATE money, rate;
};

-- store
STORE result INTO '$output_data_path' USING PigStorage('\u0001');


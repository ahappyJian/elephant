-- register 
REGISTER DuckPigUdf.jar;

-- define 
DEFINE duck_storage duck.java.pig.udf.storage();

-- clean up 
rmf $output_data_path;

-- load data
raw_events = LOAD '$input_data_path' USING duck_storage;

trim_events = FOREACH raw_events {
        rand_seed = (int)(RANDOM()*100); -- this field is to handle large numbers of small files
        GENERATE
        rand_seed AS rand_seed,
		name AS name,
		age AS age,
		timestamp AS timestamp;
};  

group_events = GROUP trim_events BY rand_seed PARALLEL 10; 
result = FOREACH group_events GENERATE flatten(trim_events);

-- store
STORE result INTO '$output_data_path' USING PigStorage('\u0001');


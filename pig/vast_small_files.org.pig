-- register 
REGISTER DuckPigUdf.jar;

-- define 
DEFINE duck_storage duck.java.pig.udf.storage();

-- clean up 
rmf $output_data_path;

-- load data
raw_events = LOAD '$input_data_path' USING duck_storate;

trim_events = FOREACH raw_events {
        GENERATE
		name AS name,
		age AS age,
		timestamp AS timestamp;
};  

-- store
STORE trim_events INTO '$output_data_path' USING PigStorage('\u0001');


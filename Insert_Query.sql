SELECT  
    last_state_change,
    UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00')) AS last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
FROM (
SELECT 
    last_state_change,
    MIN(last_check) AS last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
FROM hosts
WHERE last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
      AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))
GROUP BY host_name
HAVING TIME(FROM_UNIXTIME(last_check)) > '00:00:00') AS tmp;

===== First Entry =======
INSERT INTO hosts 
(last_state_change,last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state )
SELECT 
last_state_change,UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00')) AS last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state
FROM (
SELECT 
last_state_change,MIN(last_check) AS last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state
FROM hosts
WHERE 
last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))
GROUP BY host_name
HAVING TIME(FROM_UNIXTIME(last_check)) > '00:00:00') AS tmp;

======== last entry =========
INSERT INTO hosts 
(last_state_change,last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state )
SELECT 
last_state_change,From_unixtime(UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))) AS last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state
FROM (
SELECT 
last_state_change,MAX(last_check) AS last_check,next_check,last_time_up,last_time_down,last_update,host_name,plugin_output,performance_data,scheduled_downtime_depth,current_state
FROM hosts
WHERE 
last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))
GROUP BY host_name
HAVING TIME(FROM_UNIXTIME(last_check)) < '23:59:59') AS tmp
SELECT 
    host_name,
    FROM_UNIXTIME(MIN(last_check)) AS min,
    FROM_UNIXTIME(MAX(last_check)) AS max
FROM 
    hosts
WHERE 
    host_name = 'S09_ACB_MDB_INCOMER_1'
    AND last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00')) 
                        AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'));

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
INSERT INTO hosts (
    last_state_change,
    last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
)
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
    FROM 
        hosts
    WHERE 
        last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
                       AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))
    GROUP BY 
        host_name
    HAVING 
        TIME(FROM_UNIXTIME(last_check)) > '00:00:00'
) AS tmp;

======== last entry =========
INSERT INTO hosts (
    last_state_change,
    last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
)
SELECT 
    last_state_change,
    UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59')) AS last_check,
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
        MAX(last_check) AS last_check,
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
    WHERE 
        last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
                       AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'))
    GROUP BY host_name
    HAVING TIME(FROM_UNIXTIME(last_check)) < '23:59:59'
) AS tmp;

======= Insert Query from one DB to Another DB =======
INSERT INTO fascia.hosts (
    last_state_change,
    last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
)
SELECT 
    last_state_change,
    last_check,
    next_check,
    last_time_up,
    last_time_down,
    last_update,
    host_name,
    plugin_output,
    performance_data,
    scheduled_downtime_depth,
    current_state
FROM fascia3.hosts
WHERE last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 00:00:00'))
      AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d 23:59:59'));

======= Where Condition for Current date ================
    WHERE 
        last_check BETWEEN UNIX_TIMESTAMP(DATE_FORMAT(CURDATE(), '%Y-%m-%d 00:00:00'))
                       AND UNIX_TIMESTAMP(DATE_FORMAT(CURDATE(), '%Y-%m-%d 23:59:59'))
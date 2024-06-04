SELECT  tmp4.host_name AS HOST_NAME,
        CONCAT(FLOOR(tmp4.total), ' Hours ', ROUND((tmp4.total - FLOOR(tmp4.total)) * 60), ' Minutes') AS TOTAL,
        CONCAT(FLOOR(tmp4.up), ' Hours ', ROUND((tmp4.up - FLOOR(tmp4.up)) * 60), ' Minutes') AS UP_TIME,
        CONCAT(FLOOR(tmp4.total_down), ' Hours ', ROUND((tmp4.total_down - FLOOR(tmp4.total_down)) * 60), ' Minutes') AS DOWN_TIME,
        CONCAT(FLOOR(tmp4.sc_down), ' Hours ', ROUND((tmp4.sc_down - FLOOR(tmp4.sc_down)) * 60), ' Minutes') AS SC_DOWN,
        ROUND((tmp4.up / tmp4.total) * 100, 2) AS PERCENTAGE
FROM (
    SELECT  tmp3.host_name,
            tmp3.total AS total,
            tmp3.total - (tmp3.down - tmp3.sc_down) AS up,
            tmp3.down AS total_down,
            tmp3.sc_down AS sc_down
    FROM (
        SELECT  tmp2.host_name AS host_name,
                24 AS total,
                ROUND(SUM(IF(tmp2.current_state = 0, tmp2.timedif, 0)) / 3600, 1) AS up,
                ROUND(SUM(IF(tmp2.current_state = 1, tmp2.timedif, 0)) / 3600, 1) AS down,
                ROUND(SUM(IF(tmp2.current_state IN (1, 2) AND tmp2.scheduled_downtime_depth = 1, tmp2.timedif, 0)) / 3600, 1) AS sc_down
        FROM (
            SELECT  tmp.host_name AS host_name,
                    IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1) AS min_lt,
                    tmp.lt AS max_lt,
                    TIMESTAMPDIFF(SECOND, IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1), tmp.lt) AS timedif,
                    tmp.state AS current_state,
                    tmp.scheduled_downtime_depth
            FROM (
                SELECT  tmp1.host_name AS host_name,
                        tmp1.current_state AS state,
                        tmp1.scheduled_downtime_depth AS scheduled_downtime_depth,
                        @prev := @prev := "", @first11 := "", @first21 := "", @first31 := "",
                        IF(current_state = 0, IF(@first11 = "", @first11 := FROM_UNIXTIME(tmp1.last_check), @tmp11 := ""), @first11 := "") AS t,
                        IF(current_state >= 1, IF(@first21 = "", @first21 := FROM_UNIXTIME(tmp1.last_check), @tmp21 := ""), @first21 := "") AS t1,
                        IF(current_state = 2, IF(@first31 = "", @first31 := FROM_UNIXTIME(tmp1.last_check), @tmp31 := ""), @first31 := "") AS t2,
                        IF(tmp1.scheduled_downtime_depth = 0, IF(@first41 = "", @first41 := FROM_UNIXTIME(last_check), @tmp41 := ""), @first41 := "") AS t3,
                        IF(tmp1.scheduled_downtime_depth = 1, IF(@first51 = "", @first51 := FROM_UNIXTIME(last_check), @tmp51 := ""), @first51 := "") AS t4,
                        IF(tmp1.scheduled_downtime_depth = 2, IF(@first61 = "", @first61 := FROM_UNIXTIME(last_check), @tmp61 := ""), @first61 := "") AS t5,
                        IF(tmp1.scheduled_downtime_depth = 5, IF(@first71 = "", @first71 := FROM_UNIXTIME(last_check), @tmp71 := ""), @first71 := "") AS t6,
                        @prev AS plt1, 
                        @prev := FROM_UNIXTIME(tmp1.last_check) AS plt,
                        FROM_UNIXTIME(MAX(tmp1.last_check)) AS lt,
                        @first11, @first21, @first31, @first41, @first51, @first61, @first71
                FROM (
                    SELECT  host_name, 
                            current_state, 
                            last_check, 
                            scheduled_downtime_depth
                    FROM hosts 
                    FORCE INDEX (cmp_index)
                    WHERE host_name IN ('AGR_L2_SW02', 'AGR_BTN_SW01', 'AGR_BTN_SW02')
                    AND last_check BETWEEN UNIX_TIMESTAMP('2024-05-04 00:00:00') AND UNIX_TIMESTAMP('2024-05-04 23:59:59')
                    GROUP BY host_name, last_check
                    ORDER BY host_name
                ) AS tmp1
                GROUP BY @first11, @first21, @first31, @first41, @first51, @first61, @first71, plt, host_name
                ORDER BY host_name
            ) AS tmp
            WHERE tmp.state IS NOT NULL
        ) AS tmp2
        GROUP BY host_name
    ) AS tmp3
) AS tmp4;

+--------------+--------------------+--------------------+-------------------+-------------------+------------+
| HOST_NAME    | TOTAL              | UP_TIME            | DOWN_TIME         | SC_DOWN           | PERCENTAGE |
+--------------+--------------------+--------------------+-------------------+-------------------+------------+
| AGR_BTN_SW01 | 24 Hours 0 Minutes | 24 Hours 0 Minutes | 0 Hours 0 Minutes | 0 Hours 0 Minutes | 100.00     |
| AGR_BTN_SW02 | 24 Hours 0 Minutes | 24 Hours 0 Minutes | 0 Hours 0 Minutes | 0 Hours 0 Minutes | 100.00     |
| AGR_L2_SW02  | 24 Hours 0 Minutes | 24 Hours 0 Minutes | 0 Hours 0 Minutes | 0 Hours 0 Minutes | 100.00     |
+--------------+--------------------+--------------------+-------------------+-------------------+------------+

SELECT  tmp4.host_name AS HOST_NAME,
        CONCAT(LPAD(FLOOR(tmp4.total), 2, '0'), ':', LPAD(ROUND((tmp4.total - FLOOR(tmp4.total)) * 60), 2, '0')) AS TOTAL,
        CONCAT(LPAD(FLOOR(tmp4.up), 2, '0'), ':', LPAD(ROUND((tmp4.up - FLOOR(tmp4.up)) * 60), 2, '0')) AS UP_TIME,
        CONCAT(LPAD(FLOOR(tmp4.total_down), 2, '0'), ':', LPAD(ROUND((tmp4.total_down - FLOOR(tmp4.total_down)) * 60), 2, '0')) AS DOWN_TIME,
        CONCAT(LPAD(FLOOR(tmp4.sc_down), 2, '0'), ':', LPAD(ROUND((tmp4.sc_down - FLOOR(tmp4.sc_down)) * 60), 2, '0')) AS SC_DOWN,
        ROUND((tmp4.up / tmp4.total) * 100, 2) AS PERCENTAGE,
		CONCAT(ROUND(((tmp4.up + tmp4.sc_down) / tmp4.total) * 100, 2), ' %') AS PERCENTAGE1

FROM (
    SELECT  tmp3.host_name,
            tmp3.total AS total,
            tmp3.up AS up,
            tmp3.total - tmp3.up AS total_down,
            tmp3.sc_down AS sc_down
    FROM (
        SELECT  tmp2.host_name AS host_name,
                24 AS total,
                ROUND(SUM(IF(tmp2.current_state = 0, tmp2.timedif, 0)) / 3600, 1) AS up,
                ROUND(SUM(IF(tmp2.current_state = 1, tmp2.timedif, 0)) / 3600, 1) AS down,
                ROUND(SUM(IF(tmp2.current_state IN (1, 2) AND tmp2.scheduled_downtime_depth = 1, tmp2.timedif, 0)) / 3600, 1) AS sc_down
        FROM (
            SELECT  tmp.host_name AS host_name,
                    IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1) AS min_lt,
                    tmp.lt AS max_lt,
                    TIMESTAMPDIFF(SECOND, IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1), tmp.lt) AS timedif,
                    tmp.state AS current_state,
                    tmp.scheduled_downtime_depth
            FROM (
                SELECT  tmp1.host_name AS host_name,
                        tmp1.current_state AS state,
                        tmp1.scheduled_downtime_depth AS scheduled_downtime_depth,
                        @prev := "", @first11 := "", @first21 := "", @first31 := "",
                        IF(current_state = 0, IF(@first11 = "", @first11 := FROM_UNIXTIME(tmp1.last_check), @tmp11 := ""), @first11 := "") AS t,                   
                        IF(current_state >= 1, IF(@first21 = "", @first21 := FROM_UNIXTIME(tmp1.last_check), @tmp21 := ""), @first21 := "") AS t1,
                        IF(current_state = 2, IF(@first31 = "", @first31 := FROM_UNIXTIME(tmp1.last_check), @tmp31 := ""), @first31 := "") AS t2,
                        IF(tmp1.scheduled_downtime_depth = 0, IF(@first41 = "", @first41 := FROM_UNIXTIME(last_check), @tmp41 := ""), @first41 := "") AS t3,
                        IF(tmp1.scheduled_downtime_depth = 1, IF(@first51 = "", @first51 := FROM_UNIXTIME(last_check), @tmp51 := ""), @first51 := "") AS t4,
                        IF(tmp1.scheduled_downtime_depth = 2, IF(@first61 = "", @first61 := FROM_UNIXTIME(last_check), @tmp61 := ""), @first61 := "") AS t5,
                        IF(tmp1.scheduled_downtime_depth = 5, IF(@first71 = "", @first71 := FROM_UNIXTIME(last_check), @tmp71 := ""), @first71 := "") AS t6,
                        @prev AS plt1, 
                        @prev := FROM_UNIXTIME(tmp1.last_check) AS plt,
                        FROM_UNIXTIME(MAX(tmp1.last_check)) AS lt,
                        @first11, @first21, @first31, @first41, @first51, @first61, @first71
                FROM (
                    SELECT  host_name, 
                            current_state, 
                            last_check, 
                            scheduled_downtime_depth
                    FROM hosts 
                    FORCE INDEX (cmp_index)
                    WHERE host_name IN ('AGR_L2_SW02', 'AGR_BTN_SW01', 'AGR_BTN_SW02')
                    AND last_check BETWEEN UNIX_TIMESTAMP('2024-05-04 00:00:00') AND UNIX_TIMESTAMP('2024-05-04 23:59:59')
                    GROUP BY host_name, last_check
                    ORDER BY host_name
                ) AS tmp1
                GROUP BY @first11, @first21, @first31, @first41, @first51, @first61, @first71, plt, host_name
                ORDER BY host_name
            ) AS tmp
            WHERE tmp.state IS NOT NULL
        ) AS tmp2
        GROUP BY host_name
    ) AS tmp3
) AS tmp4;

+--------------+-------+---------+-----------+---------+------------+
| HOST_NAME    | TOTAL | UP_TIME | DOWN_TIME | SC_DOWN | PERCENTAGE |
+--------------+-------+---------+-----------+---------+------------+
| AGR_BTN_SW01 | 24:00 | 24:00   | 00:00     | 00:00   | 100.00     |
| AGR_BTN_SW02 | 24:00 | 24:00   | 00:00     | 00:00   | 100.00     |
| AGR_L2_SW02  | 24:00 | 24:00   | 00:00     | 00:00   | 100.00     |
+--------------+-------+---------+-----------+---------+------------+

SELECT 
    tmp4.host_name AS HOST_NAME,
    CONCAT(LPAD(FLOOR(tmp4.total), 2, '0'), ':', LPAD(ROUND((tmp4.total - FLOOR(tmp4.total)) * 60), 2, '0')) AS TOTAL,
    CONCAT(LPAD(FLOOR(tmp4.up), 2, '0'), ':', LPAD(ROUND((tmp4.up - FLOOR(tmp4.up)) * 60), 2, '0')) AS UP_TIME,
    CONCAT(LPAD(FLOOR(tmp4.total_down), 2, '0'), ':', LPAD(ROUND((tmp4.total_down - FLOOR(tmp4.total_down)) * 60), 2, '0')) AS DOWN_TIME,
    CONCAT(LPAD(FLOOR(tmp4.sc_down), 2, '0'), ':', LPAD(ROUND((tmp4.sc_down - FLOOR(tmp4.sc_down)) * 60), 2, '0')) AS SC_DOWN,
    ROUND((tmp4.up / tmp4.total) * 100, 2) AS PERCENTAGE,
    CONCAT(ROUND(((tmp4.up + tmp4.sc_down) / tmp4.total) * 100, 2), ' %') AS PERCENTAGE1
FROM (
    SELECT 
        tmp3.host_name,
        tmp3.total AS total,
        tmp3.up AS up,
        tmp3.total - tmp3.up AS total_down,
        tmp3.sc_down AS sc_down
    FROM (
        SELECT 
            tmp2.host_name AS host_name,
            24 AS total,
            ROUND(SUM(IF(tmp2.current_state = 0, tmp2.timedif, 0)) / 3600, 1) AS up,
            ROUND(SUM(IF(tmp2.current_state = 1, tmp2.timedif, 0)) / 3600, 1) AS down,
            ROUND(SUM(IF(tmp2.current_state IN (1, 2) AND tmp2.scheduled_downtime_depth = 1, tmp2.timedif, 0)) / 3600, 1) AS sc_down
        FROM (
            SELECT 
                tmp.host_name AS host_name,
                IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1) AS min_lt,
                tmp.lt AS max_lt,
                TIMESTAMPDIFF(SECOND, IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1), tmp.lt) AS timedif,
                tmp.state AS current_state,
                tmp.scheduled_downtime_depth
            FROM (
                SELECT 
                    tmp1.host_name AS host_name,
                    tmp1.current_state AS state,
                    tmp1.scheduled_downtime_depth AS scheduled_downtime_depth,
                    @prev := "", @first11 := "", @first21 := "", @first31 := "",
                    IF(current_state = 0, IF(@first11 = "", @first11 := FROM_UNIXTIME(tmp1.last_check), @tmp11 := ""), @first11 := "") AS t,                   
                    IF(current_state >= 1, IF(@first21 = "", @first21 := FROM_UNIXTIME(tmp1.last_check), @tmp21 := ""), @first21 := "") AS t1,
                    IF(current_state = 2, IF(@first31 = "", @first31 := FROM_UNIXTIME(tmp1.last_check), @tmp31 := ""), @first31 := "") AS t2,
                    IF(tmp1.scheduled_downtime_depth = 0, IF(@first41 = "", @first41 := FROM_UNIXTIME(last_check), @tmp41 := ""), @first41 := "") AS t3,
                    IF(tmp1.scheduled_downtime_depth = 1, IF(@first51 = "", @first51 := FROM_UNIXTIME(last_check), @tmp51 := ""), @first51 := "") AS t4,
                    IF(tmp1.scheduled_downtime_depth = 2, IF(@first61 = "", @first61 := FROM_UNIXTIME(last_check), @tmp61 := ""), @first61 := "") AS t5,
                    IF(tmp1.scheduled_downtime_depth = 5, IF(@first71 = "", @first71 := FROM_UNIXTIME(last_check), @tmp71 := ""), @first71 := "") AS t6,
                    @prev AS plt1, 
                    @prev := FROM_UNIXTIME(tmp1.last_check) AS plt,
                    FROM_UNIXTIME(MAX(tmp1.last_check)) AS lt,
                    @first11, @first21, @first31, @first41, @first51, @first61, @first71
                FROM (
                    SELECT 
                        host_name, 
                        current_state, 
                        last_check, 
                        scheduled_downtime_depth
                    FROM 
                        hosts 
                    FORCE INDEX (cmp_index)
                    WHERE 
                        host_name IN ('AGR_L2_SW02', 'AGR_BTN_SW01', 'AGR_BTN_SW02')
                    AND 
                        last_check BETWEEN UNIX_TIMESTAMP('2024-05-04 00:00:00') AND UNIX_TIMESTAMP('2024-05-04 23:59:59')
                    GROUP BY 
                        host_name, last_check
                    ORDER BY 
                        host_name
                ) AS tmp1
                GROUP BY 
                    @first11, @first21, @first31, @first41, @first51, @first61, @first71, plt, host_name
                ORDER BY 
                    host_name
            ) AS tmp
            WHERE 
                tmp.state IS NOT NULL
        ) AS tmp2
        GROUP BY 
            host_name
    ) AS tmp3
) AS tmp4;
+--------------+-------+---------+-----------+---------+------------+-------------+
| HOST_NAME    | TOTAL | UP_TIME | DOWN_TIME | SC_DOWN | PERCENTAGE | PERCENTAGE1 |
+--------------+-------+---------+-----------+---------+------------+-------------+
| AGR_BTN_SW01 | 24:00 | 23:54   | 00:06     | 00:00   | 99.58      | 99.58 %     |
| AGR_BTN_SW02 | 24:00 | 23:54   | 00:06     | 00:00   | 99.58      | 99.58 %     |
| AGR_L2_SW02  | 24:00 | 23:42   | 00:18     | 00:00   | 98.75      | 98.75 %     |
+--------------+-------+---------+-----------+---------+------------+-------------+

SELECT 
    tmp4.host_name AS HOST_NAME,
    CONCAT(FLOOR(tmp4.total), ' Hours ', MINUTE(SEC_TO_TIME(ROUND(tmp4.total * 3600))) , ' Minutes') AS TOTAL,
    CONCAT(FLOOR(tmp4.up), ' Hours ', MINUTE(SEC_TO_TIME(ROUND(tmp4.up * 3600))), ' Minutes') AS UP_TIME,
    CONCAT(FLOOR(tmp4.total_down), ' Hours ', MINUTE(SEC_TO_TIME(ROUND(tmp4.total_down * 3600))), ' Minutes') AS DOWN_TIME,
    CONCAT(FLOOR(tmp4.sc_down), ' Hours ', MINUTE(SEC_TO_TIME(ROUND(tmp4.sc_down * 3600))), ' Minutes') AS SC_DOWN,
    ROUND((tmp4.up / tmp4.total) * 100, 2) AS PERCENTAGE,
    CONCAT(ROUND(((tmp4.up + tmp4.sc_down) / tmp4.total) * 100, 2), ' %') AS PERCENTAGE1
FROM (
    SELECT 
        tmp3.host_name,
        tmp3.total AS total,
        tmp3.up AS up,
        tmp3.total - tmp3.up AS total_down,
        tmp3.sc_down AS sc_down
    FROM (
        SELECT 
            tmp2.host_name AS host_name,
            144 AS total,
            ROUND(SUM(IF(tmp2.current_state = 0, tmp2.timedif, 0)) / 3600, 1) AS up,
            ROUND(SUM(IF(tmp2.current_state = 1, tmp2.timedif, 0)) / 3600, 1) AS down,
            ROUND(SUM(IF(tmp2.current_state IN (1, 2) AND tmp2.scheduled_downtime_depth = 1, tmp2.timedif, 0)) / 3600, 1) AS sc_down
        FROM (
            SELECT 
                tmp.host_name AS host_name,
                IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1) AS min_lt,
                tmp.lt AS max_lt,
                TIMESTAMPDIFF(SECOND, IF(tmp.plt1 = 0 OR tmp.plt1 > tmp.plt, tmp.plt, tmp.plt1), tmp.lt) AS timedif,
                tmp.state AS current_state,
                tmp.scheduled_downtime_depth
            FROM (
                SELECT 
                    tmp1.host_name AS host_name,
                    tmp1.current_state AS state,
                    tmp1.scheduled_downtime_depth AS scheduled_downtime_depth,
                    @prev := "", @first11 := "", @first21 := "", @first31 := "",
                    IF(current_state = 0, IF(@first11 = "", @first11 := FROM_UNIXTIME(tmp1.last_check), @tmp11 := ""), @first11 := "") AS t,                   
                    IF(current_state >= 1, IF(@first21 = "", @first21 := FROM_UNIXTIME(tmp1.last_check), @tmp21 := ""), @first21 := "") AS t1,
                    IF(current_state = 2, IF(@first31 = "", @first31 := FROM_UNIXTIME(tmp1.last_check), @tmp31 := ""), @first31 := "") AS t2,
                    IF(tmp1.scheduled_downtime_depth = 0, IF(@first41 = "", @first41 := FROM_UNIXTIME(last_check), @tmp41 := ""), @first41 := "") AS t3,
                    IF(tmp1.scheduled_downtime_depth = 1, IF(@first51 = "", @first51 := FROM_UNIXTIME(last_check), @tmp51 := ""), @first51 := "") AS t4,
                    IF(tmp1.scheduled_downtime_depth = 2, IF(@first61 = "", @first61 := FROM_UNIXTIME(last_check), @tmp61 := ""), @first61 := "") AS t5,
                    IF(tmp1.scheduled_downtime_depth = 5, IF(@first71 = "", @first71 := FROM_UNIXTIME(last_check), @tmp71 := ""), @first71 := "") AS t6,
                    @prev AS plt1, 
                    @prev := FROM_UNIXTIME(tmp1.last_check) AS plt,
                    FROM_UNIXTIME(MAX(tmp1.last_check)) AS lt,
                    @first11, @first21, @first31, @first41, @first51, @first61, @first71
                FROM (
                    SELECT 
                        host_name, 
                        current_state, 
                        last_check, 
                        scheduled_downtime_depth
                    FROM 
                        hosts 
                    FORCE INDEX (cmp_index)
                    WHERE 
                        host_name IN ('AGR_L2_SW02', 'AGR_BTN_SW01', 'AGR_BTN_SW02')
                    AND 
                        last_check BETWEEN UNIX_TIMESTAMP('2024-05-05 00:00:00') AND UNIX_TIMESTAMP('2024-05-10 23:59:59')
                    GROUP BY 
                        host_name, last_check
                    ORDER BY 
                        host_name
                ) AS tmp1
                GROUP BY 
                    @first11, @first21, @first31, @first41, @first51, @first61, @first71, plt, host_name
                ORDER BY 
                    host_name
            ) AS tmp
            WHERE 
                tmp.state IS NOT NULL
        ) AS tmp2
        GROUP BY 
            host_name
    ) AS tmp3
) AS tmp4;

+--------------+--------------------+---------------------+--------------------+-------------------+------------+-------------+
| HOST_NAME    | TOTAL              | UP_TIME             | DOWN_TIME          | SC_DOWN           | PERCENTAGE | PERCENTAGE1 |
+--------------+--------------------+---------------------+--------------------+-------------------+------------+-------------+
| AGR_BTN_SW01 | 24 Hours 0 Minutes | 23 Hours 54 Minutes | 0 Hours 6 Minutes  | 0 Hours 0 Minutes | 99.58      | 99.58 %     |
| AGR_BTN_SW02 | 24 Hours 0 Minutes | 23 Hours 54 Minutes | 0 Hours 6 Minutes  | 0 Hours 0 Minutes | 99.58      | 99.58 %     |
| AGR_L2_SW02  | 24 Hours 0 Minutes | 23 Hours 42 Minutes | 0 Hours 18 Minutes | 0 Hours 0 Minutes | 98.75      | 98.75 %     |
+--------------+--------------------+---------------------+--------------------+-------------------+------------+-------------+
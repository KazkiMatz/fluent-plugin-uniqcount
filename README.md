fluent-plugin-uniqcount
=======================

A fluent-output plugin which offers Count Distinct/Aggregation that is mostly equivalent to:

    SELECT key1, COUNT(key2) AS key2_count, COUNT(DISTINCT(key2)) AS key2_uniq_count FROM records WHERE time BETWEEN T1 AND T2 GROUP BY key1 ORDER BY key2_count DESC LIMIT 0, N;

in SQL


Configuration Examples
----------------------
    <match site.access_log>
      type uniq_count
    
      list1_label trends_in_min
      list1_time at
      list1_key1 uri
      list1_key2 remote_ip
      list1_span 60
      list1_offset 3
      list1_out_tag trends.min
      list1_out_num 10
      list1_out_interval 1
    
      list2_label trends_in_day
      list2_time at
      list2_key1 uri
      list2_key2 remote_ip
      list2_span 86400
      list2_offset 3
      list2_out_tag trends.day
      list2_out_num 10
      list2_out_interval 10
    </match>


Licence
-------

 GNU General Public License


Author
------

 Kazki Matz (kazki.matz@gmail.com)

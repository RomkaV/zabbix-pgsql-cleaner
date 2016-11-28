#!/bin/bash
PSQL="/usr/bin/psql"
DBNAME="zabbix24"
DBUSER="postgres"
last_day=10
array=( history history_str history_text history_uint trends trends_uint )
# array=( history )
for tbl in "${array[@]}"; do
	# echo $tbl
	echo $DBNAME" "$tbl
	for i in `seq 1 $last_day`; do
	        dd=`date +%Y_%m_%d -d "$i day ago"` 
	        # dd="2016_07_18"
	        partition=$tbl"_p$dd"   
	        index_name=$partition"_1" 
	        index_name_new=$partition"_1_new" 

			$PSQL -U $DBUSER -d $DBNAME  -t -c "SELECT COUNT(*) FROM partitions.$partition WHERE itemid NOT IN (SELECT itemid FROM items);"
	       	$PSQL -U $DBUSER -d $DBNAME -c "DELETE FROM partitions.$partition WHERE itemid NOT IN (SELECT itemid FROM items);"

			echo "$index_name" 			

			# echo "CREATE INDEX CONCURRENTLY $index_name_new  ON partitions.history_p$dd USING btree (itemid, clock); " 
			$PSQL -U $DBUSER -d $DBNAME  -t -c "CREATE INDEX CONCURRENTLY $index_name_new  ON partitions.history_p$dd USING btree (itemid, clock); " 
	        echo "Done CREATE" 

			$PSQL -U $DBUSER -d $DBNAME  -t -c "DROP INDEX partitions.$index_name" 
	        echo "Done DROP" 

			$PSQL -U $DBUSER -d $DBNAME  -t -c "ALTER INDEX  IF EXISTS  partitions.$index_name_new RENAME TO $index_name"  
	        echo "Done ALTER" 
	done
done


# # -- Delete all orphaned acknowledge entries
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM acknowledges WHERE NOT userid IN (SELECT userid FROM users);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM acknowledges WHERE NOT eventid IN (SELECT eventid FROM events);"

# # -- Delete orphaned alerts entries
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM alerts WHERE NOT actionid IN (SELECT actionid FROM actions);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM alerts WHERE NOT eventid IN (SELECT eventid FROM events);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM alerts WHERE NOT userid IN (SELECT userid FROM users);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM alerts WHERE NOT mediatypeid IN (SELECT mediatypeid FROM media_type);"

# # -- Delete orphaned application entries that no longer map back to a host
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM applications WHERE NOT hostid IN (SELECT hostid FROM hosts);"

# # -- Delete orphaned auditlog details (such as logins)
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM auditlog_details WHERE NOT auditid IN (SELECT auditid FROM auditlog);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM auditlog WHERE NOT userid IN (SELECT userid FROM users);"

# # -- Delete orphaned conditions
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM conditions WHERE NOT actionid IN (SELECT actionid FROM actions);"

# # -- Delete orphaned functions
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM functions WHERE NOT itemid IN (SELECT itemid FROM items);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM functions WHERE NOT triggerid IN (SELECT triggerid FROM triggers);"

# # -- Delete orphaned graph items
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM graphs_items WHERE NOT graphid IN (SELECT graphid FROM graphs);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM graphs_items WHERE NOT itemid IN (SELECT itemid FROM items);"

# # -- Delete orphaned host macro's
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM hostmacro WHERE NOT hostid IN (SELECT hostid FROM hosts);"

# # -- Delete orphaned item data
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM items WHERE hostid NOT IN (SELECT hostid FROM hosts);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM items_applications WHERE applicationid NOT IN (SELECT applicationid FROM applications);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM items_applications WHERE itemid NOT IN (SELECT itemid FROM items);"

# # -- Delete orphaned HTTP check data
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM httpstep WHERE NOT httptestid IN (SELECT httptestid FROM httptest);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM httpstepitem WHERE NOT httpstepid IN (SELECT httpstepid FROM httpstep);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM httpstepitem WHERE NOT itemid IN (SELECT itemid FROM items);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM httptest WHERE applicationid NOT IN (SELECT applicationid FROM applications);"

# # -- Delete orphaned maintenance data
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_groups WHERE maintenanceid NOT IN (SELECT maintenanceid FROM maintenances);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_groups WHERE groupid NOT IN (SELECT groupid FROM groups);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_hosts WHERE maintenanceid NOT IN (SELECT maintenanceid FROM maintenances);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_hosts WHERE hostid NOT IN (SELECT hostid FROM hosts);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_windows WHERE maintenanceid NOT IN (SELECT maintenanceid FROM maintenances);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM maintenances_windows WHERE timeperiodid NOT IN (SELECT timeperiodid FROM timeperiods);"

# # -- Delete orphaned mappings
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM mappings WHERE NOT valuemapid IN (SELECT valuemapid FROM valuemaps);"

# # -- Delete orphaned media items
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM media WHERE NOT userid IN (SELECT userid FROM users);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM media WHERE NOT mediatypeid IN (SELECT mediatypeid FROM media_type);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM rights WHERE NOT groupid IN (SELECT usrgrpid FROM usrgrp);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM rights WHERE NOT id IN (SELECT groupid FROM groups);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM sessions WHERE NOT userid IN (SELECT userid FROM users);"

# # -- Screens
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM screens_items WHERE screenid NOT IN (SELECT screenid FROM screens);"

# # -- Events & triggers
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM trigger_depends WHERE triggerid_down NOT IN (SELECT triggerid FROM triggers);"
$PSQL -U $DBUSER -d $DBNAME  -t -c "DELETE FROM trigger_depends WHERE triggerid_up NOT IN (SELECT triggerid FROM triggers);"
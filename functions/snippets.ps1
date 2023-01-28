# Iterate with single iterator over nested hashtable to populate 2 values

foreach($i in $apps){start "$apps[$i.Keys].Values" -ArgumentList "$apps[$i.Keys].keys"}
# Iterate with single iterator over nested hashtable to populate 2 values

foreach($i in $apps){Start-Process "$apps[$i.Keys].Values" -ArgumentList "$apps[$i.Keys].keys"}

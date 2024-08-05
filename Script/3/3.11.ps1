#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="USE [msdb] 
SELECT sp.name AS proxyname 
FROM dbo.sysproxylogin spl 
JOIN sys.database_principals dp 
ON dp.sid = spl.sid 
JOIN sysproxies sp 
ON sp.proxy_id = spl.proxy_id 
WHERE principal_id = USER_ID('public');"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number = $data.Rows.Count

if($number -gt 0){
    
    $proxyname = $row['proxyname']
    
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="USE [msdb]
    EXEC dbo.sp_revoke_login_from_proxy @name = N'public', @proxy_name = N'[$proxyname]';" #if error, try removing []

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    if($sqlDataAdapter){
        Write-Output "Successfully configured public role in the msdb database is not granted access to SQL Agent proxies"
        Write-Output "Rerun script to view changes"
    }
}
else{
    Write-Output "No changes made. Public role in the msdb database is not granted access to SQL Agent proxies"
}



$sqlConnection.Close()


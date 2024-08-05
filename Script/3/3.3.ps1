#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="USE <database_name>; 
SELECT dp.type_desc,
dp.sid, dp.name as orphan_user_name, dp.authentication_type_desc
FROM sys.database_principals AS dp LEFT JOIN sys.server_principals as sp
ON dp.sid=sp.sid WHERE sp.sid IS NULL AND dp.authentication_type_desc = 'INSTANCE' "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
$number = $data.Rows.Count
if($number -eq 0){
    Write-Output '3.3 is compliant'
}
else{
    
    $username = $row['orphan_user_name']

    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="USE <database_name>; 
    DROP USER [$username];"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output 'Successfully configured 3.3. Rerun script to view changes'
    }
}

$sqlConnection.Close()
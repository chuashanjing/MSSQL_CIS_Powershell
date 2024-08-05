#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress01;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE <DATABASE_NAME>
$sqlCommand.CommandText="IF (select value_data from sys.dm_server_registry where value_name = 'ListenOnAllIPs') = 1 
SELECT count(*) FROM sys.dm_server_registry WHERE registry_key like '%IPAll%' and value_name like '%Tcp%' and value_data='1433' 
ELSE 
SELECT count(*) FROM sys.dm_server_registry WHERE value_name like '%Tcp%' and value_data='1433'; "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
if($row['Column1'] -eq 0){
    Write-Output 'PASS'
}
else{
    Write-Output 'Not compliant'
}


$sqlConnection.Close()
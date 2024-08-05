#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE Logging WITH SOMETHING ELSE THIS IS FOR TESTING########################
$sqlCommand.CommandText="SELECT 
b.key_algorithm, b.encryptor_type, d.is_encrypted, 
    b.database_name, 
    b.server_name 
FROM msdb.dbo.backupset b 
inner join sys.databases d on b.database_name = d.name 
where b.key_algorithm IS NULL AND b.encryptor_type IS NULL AND d.is_encrypted = 0;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number = $row.Count

if($number -eq 0){
    Write-Output '7.3 is compliant'
}
else{
    Write-Output '7.3 is not compliant. Refer to manual file'
}

$sqlConnection.Close()
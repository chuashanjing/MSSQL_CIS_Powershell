#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name AS DBUser 
FROM sys.database_principals 
WHERE name NOT IN ('dbo','Information_Schema','sys','guest') 
AND type IN ('U','S','G') 
AND authentication_type = 2;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$number = $data.Rows.Count
if($number -eq 0){
    Write-Output '3.4 is compliant'
}
else{
    Write-Output '3.4 is not compliant'
}

$sqlConnection.Close()
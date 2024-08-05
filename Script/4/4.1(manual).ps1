#ONLY REMEDIATION
#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()
#CHANGE JOHN AND 1234567890 to your desired username and password respectively
$sqlCommand.CommandText="CREATE LOGIN john WITH PASSWORD='1234567890' MUST_CHANGE, CHECK_EXPIRATION=ON, CHECK_POLICY=ON; 
ALTER LOGIN john WITH PASSWORD='1234567890' MUST_CHANGE;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)
if($sqlDataAdapter){
    Write-Output "Successfully configured 'MUST_CHANGE' Option is set to 'ON' for all SQL Authenticated Logins"
}


$sqlConnection.Close()
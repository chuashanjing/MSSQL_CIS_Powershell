#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name, is_disabled 
FROM sys.server_principals 
WHERE sid = 0x01 
AND is_disabled = 0;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows.Count
$data

if($row -gt 0){
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="USE [master] 
    DECLARE @tsql nvarchar(max) 
    SET @tsql = 'ALTER LOGIN ' + SUSER_NAME(0x01) + ' DISABLE' 
    EXEC (@tsql)"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 'sa' Login Account is set to Disabled"
        Write-Output "Rerun script to view changes"
    }
}
else{
    Write-Output "No changes needed. 'sa' Login Account is set to Disabled"
}


$sqlConnection.Close()


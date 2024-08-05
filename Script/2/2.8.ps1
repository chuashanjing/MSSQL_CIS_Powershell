#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name, 
      CAST(value as int) as value_configured, 
      CAST(value_in_use as int) as value_in_use 
FROM sys.configurations 
WHERE name = 'scan for startup procs';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
$row

if($row['value_configured'] -eq 0 -and $row['value_in_use'] -eq 0){
    Write-Output "No changes needed. 'Scan For Startup Procs' Server Configuration Option is set to 0."
}
else{
    
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXECUTE sp_configure 'show advanced options', 1; 
    RECONFIGURE; 
    EXECUTE sp_configure 'scan for startup procs', 0; 
    RECONFIGURE;  
    EXECUTE sp_configure 'show advanced options', 0; 
    RECONFIGURE; "

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 'Scan For Startup Procs' Server Configuration Option is set to 0."
        Write-Output "2) Select Restart on SQLSERVER in MSSQL Service in SQL Server 2019 Configuration Manager"
        Write-Output "3) Rerun to view changes"
    }

}

$sqlConnection.Close()
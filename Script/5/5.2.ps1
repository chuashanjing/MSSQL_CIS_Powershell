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
WHERE name = 'default trace enabled';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]

if($row['value_configured'] -eq 1 -and $row['value_in_use'] -eq 1){
    Write-Output "No changes needed. 5.2 is compliant"
}
else{
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXECUTE sp_configure 'show advanced options', 1; 
    RECONFIGURE; 
    EXECUTE sp_configure 'default trace enabled', 1; 
    RECONFIGURE; 
    EXECUTE sp_configure 'show advanced options', 0; 
    RECONFIGURE;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 5.2"
        Write-Output "Rerun script to view changes"
    }
}


$sqlConnection.Close()

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
WHERE name = 'remote admin connections' 
AND SERVERPROPERTY('IsClustered') = 0; "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
$row

if($row['value_configured'] -eq 0 -and $row['value_in_use'] -eq 0){
    Write-Output "No changes needed. 'Remote Admin Connections' Server Configuration Option is set to 0."
}
else
{

    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXECUTE sp_configure 'remote admin connections', 0; 
    RECONFIGURE;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 'Remote Admin Connections' Server Configuration Option is set to 0."
        Write-Output "Rerun to see changes"
    }
}


$sqlConnection.Close()
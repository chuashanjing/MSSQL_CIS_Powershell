#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE <DATABASE_NAME>
$sqlCommand.CommandText="USE <database_name>; 
SELECT name, 
      permission_set_desc 
FROM sys.assemblies 
WHERE is_user_defined = 1 AND name <> 'Microsoft.SqlServer.Types';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]

if($row['permission_set_desc'] -eq 'SAFE_ACCESS'){
    Write-Output "No changes needed. 6.2 is compliant."
}
else{
    $sqlCommand=$sqlConnection.CreateCommand()

    #REPLACE <DATABASE_NAME>
    $sqlCommand.CommandText="USE Logging;
    ALTER ASSEMBLY hi WITH PERMISSION_SET=SAFE;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 6.2. Rerun script to view changes"
    }
}

$sqlConnection.Close()
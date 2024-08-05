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
WHERE name = 'clr strict security';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
Write-Output '##############################EXECUTING##############################'
$row=$data.Rows[0]
$row

if($row['value_configured'] -eq 0 -and $row['value_in_use'] -eq 0){

    #CREATE A COMMAND TEXT
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXECUTE sp_configure 'show advanced options', 1; 
    RECONFIGURE; 
    EXECUTE sp_configure 'clr strict security', 1; 
    RECONFIGURE; 
    EXECUTE sp_configure 'show advanced options', 0; 
    RECONFIGURE; "

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    
    if($sqlDataAdapter){
        Write-Output "Successfully configured 'clr strict security' Server Configuration Option is set to 1"
        Write-Output "Rerun the script to view changes"
    }
}
else{
    Write-Output "No changes needed. 'clr strict security' Server Configuration Option is set to 1"
}




$sqlConnection.Close()


#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name 
FROM sys.server_principals 
WHERE sid = 0x01;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$row

if($row['name'] -eq 'sa'){
    
    $sqlCommand=$sqlConnection.CreateCommand()
    #replace anyname with your desired name to replace 'sa'
    $sqlCommand.CommandText="ALTER LOGIN sa WITH NAME = anyname;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 'sa' Login Account has been renamed"
        Write-Output "Rerun script to view changes"
    }
}
else{
     Write-Output "No changes needed. 'sa' Login Account has been renamed"
}


$sqlConnection.Close()

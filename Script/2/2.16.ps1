#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT principal_id, name 
FROM sys.server_principals 
WHERE name = 'sa';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
Write-Output '##############################EXECUTING##############################'
$row=$data.Rows.Count
$data

if($row -gt 0){
    
    $sqlCommand=$sqlConnection.CreateCommand()
    #replace anyname with desired name for sa
    $sqlCommand.CommandText="USE [master] 
    -- If principal_id = 1 or the login owns database objects, rename the sa login  
    ALTER LOGIN [sa] WITH NAME = anyname;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    if($sqlDataAdapter){
        Write-Output "Successfully configured no login exists with the name sa"
        Write-Output "Rerun script to view changes"
    }    
}
else{
    Write-Output "No changes needed. 'no login exists with the name sa' complies with the MS SQL CIS BENCHMARK 2019"
}



$sqlConnection.Close()
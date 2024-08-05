#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name, containment, containment_desc, is_auto_close_on 
FROM sys.databases 
WHERE containment <> 1 and is_auto_close_on = 1;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
Write-Output '############################EXECUTING############################'
$data
$row = $data.Rows.Count
if($row -gt 0){
    foreach($value in $data){
        $name = $value.name

        #CREATE A COMMAND TEXT
        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="ALTER DATABASE [$name] SET AUTO_CLOSE OFF;"

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        if($sqlDataAdapter){
            Write-Output "Successfully configured 'AUTO_CLOSE' is set to 'OFF' on contained"
            Write-Output "Rerun script to view changes"
        }

    }
}
else
{
    Write-Output "No changes needed. 'AUTO_CLOSE' is set to 'OFF' on contained"
}


$sqlConnection.Close()
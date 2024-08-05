#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name 
FROM sys.databases 
WHERE is_trustworthy_on = 1 
AND name != 'msdb';"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$data
$row = $data.Rows.Count

if($row -gt 0){

    foreach($value in $data){
        
        $name = $value.name

        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="ALTER DATABASE [$name] SET TRUSTWORTHY OFF; "

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)
        
        if($sqlDataAdapter){
            Write-Output "Successfully configured 'Trustworthy' Database Property is set to Off."
        }
    }
}
else{
    Write-Output "No changes needed. 'Trustworthy' Database Property is set to Off."
}



$sqlConnection.Close()


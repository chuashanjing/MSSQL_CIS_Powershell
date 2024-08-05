#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE Logging WITH SOMETHING ELSE THIS IS FOR TESTING########################
$sqlCommand.CommandText="use [master] 
select distinct(encrypt_option) from sys.dm_exec_connections;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number = $data.Rows.Count

if($number -gt 0){
    foreach($value in $data){
        $encrypt = $value.encrypt_option

        if($encrypt = 'FALSE'){
            Write-Output '7.4 is not compliant. Refer to manual'
          
        }
        else{
            Write-Output '7.4 is compliant'
        }
    }   
}

$sqlConnection.Close()
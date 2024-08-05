#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name, is_disabled 
FROM sys.sql_logins 
WHERE is_policy_checked = 0;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number=$data.Rows.Count

if($number -eq 0){
    Write-Output "No changes needed 4.3 is compliant"
}
else{
    
    foreach($value in $data){
        $name=$value.name
        
        $name=$value.name
        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="ALTER LOGIN [$name] WITH CHECK_POLICY = ON; "

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        if($sqlDataAdapter){
            Write-Output "Successfully configured 4.3"
            Write-Output "Rerun script to view changes"
        }

    }

}


$sqlConnection.Close()
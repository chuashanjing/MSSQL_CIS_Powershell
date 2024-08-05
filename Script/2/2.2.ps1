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
$row = $data.Rows[0]
$row

#COMPARISON
if($row['value_configured'] -eq 1 -and $row['value_in_use'] -eq 1){
    Write-Output 'This method is not applicable.....'
    Write-Output 'Using next method.....'

    #SECOND METHOD
    $sqlCommand=$sqlConnection.CreateCommand()
    $sqlCommand.CommandText="SELECT name,
	    CAST(value as int) as value_configured,
	    CAST(value_in_use as int) as value_in_use
    FROM sys.configurations
    WHERE name = 'clr enabled';"

    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    $data=$dataSet.Tables[0]
    $second_method_row = $data.Rows[0]
    
    if($second_method_row['value_configured'] -eq 0 -and $second_method_row['value_in_use'] -eq 0){
        Write-Output "No changes needed, 'CLR Enabled' Server Configuration Option is already set to '0'"
    }
    else
    {
        $sqlCommand=$sqlConnection.CreateCommand()
        $sqlCommand.CommandText="EXECUTE sp_configure 'clr enabled', 0;
        RECONFIGURE;"

        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)
        if($sqlDataAdapter){
            Write-Output "Successfully configured 'CLR Enabled' Server Configuration Option to 0"
        }
    }
}
else{
    Write-Output "No changes needed, 'CLR Enabled' Server Configuration Option is already set to '0'"
}

$sqlConnection.Close()
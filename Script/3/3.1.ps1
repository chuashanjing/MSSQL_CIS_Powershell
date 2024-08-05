#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') as [login_mode];"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
$row

if($row['login_mode'] -eq 1){
    Write-Output "No changes needed. Server Authentication' Property is set to 'Windows Authentication Mode"
}
else{
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="USE [master]
    EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 1"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    if($sqlDataAdapter){
        Write-Output "Successfully configured Server Authentication' Property is set to 'Windows Authentication Mode"
        Write-Output "Restart SQL Server Services and rerun the script to view changes"
    }
}


$sqlConnection.Close()
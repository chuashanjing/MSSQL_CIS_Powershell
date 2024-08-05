#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="DECLARE @NumErrorLogs int; 
EXEC master.sys.xp_instance_regread 
N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer', 
N'NumErrorLogs', 
@NumErrorLogs OUTPUT; 
SELECT ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles]; "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]

if($row['NumberOfLogFiles'] -ige 12){
    Write-Output "No changes needed. 5.1 is compliant"
}
else
{
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXEC master.sys.xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer', 
    N'NumErrorLogs', 
    REG_DWORD, 
    12;" #12 can be set higher any lower will be non compliant

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 5.1"
        Write-Output "Rerun script to view changes"
    }
}


$sqlConnection.Close()
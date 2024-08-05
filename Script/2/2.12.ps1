#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="DECLARE @getValue INT; 
EXEC master.sys.xp_instance_regread 
      @rootkey = N'HKEY_LOCAL_MACHINE', 
      @key = N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib', 
      @value_name = N'HideInstance', 
      @value = @getValue OUTPUT; 
SELECT @getValue;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row = $data.Rows[0]
$row
Write-Output '#######################EXECUTING#######################'


if($row.Column1 -eq 0){
    
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXEC master.sys.xp_instance_regwrite 
      @rootkey = N'HKEY_LOCAL_MACHINE', 
      @key = N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib', 
      @value_name = N'HideInstance', 
      @type = N'REG_DWORD', 
      @value = 1;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    if($sqlDataAdapter){
         Write-Output "Successfully configured 'Hide Instance' option is set to 'Yes' for Production SQL Server instances"
         Write-Output "Rerun script to view changes"
    }
}
else{
    Write-Output "No changes needed. 'Hide Instance' option is set to 'Yes' for Production SQL Server instances"
}

$sqlConnection.Close()
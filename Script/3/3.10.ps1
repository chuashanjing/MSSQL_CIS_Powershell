#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="USE [master] 
SELECT pr.[name] AS LocalGroupName, pe.[permission_name], pe.[state_desc] 
FROM sys.server_principals pr 
JOIN sys.server_permissions pe 
ON pr.[principal_id] = pe.[grantee_principal_id] 
WHERE pr.[type_desc] = 'WINDOWS_GROUP' 
AND pr.[name] like CAST(SERVERPROPERTY('MachineName') AS nvarchar) + '%'; "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$data
$number = $data.Rows.Count

if($number -gt 0){
    
    foreach($values in $data){

        $name=$values.name

        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="USE [master]
        DROP LOGIN [$name] "

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        if($sqlDataAdapter){
            Write-Output "Successfully configured Windows local groups are not SQL Logins"
            Write-Output "Rerun script to view changes"
        }

    }
}
else{

    Write-Output "No changes needed. Windows local groups are not SQL Logins "

}

$sqlConnection.Close()

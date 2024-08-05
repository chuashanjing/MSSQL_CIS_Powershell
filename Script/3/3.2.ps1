#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name
FROM sys.databases
WHERE name NOT IN ('master','tempdb','msdb', 'rdsadmin');"

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
        #AUDIT
        $name = $value.name

        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="USE [$name]; 
        SELECT DB_NAME() AS DatabaseName, 'guest' AS Database_User, [permission_name], [state_desc] 
        FROM sys.database_permissions  
        WHERE [grantee_principal_id] = DATABASE_PRINCIPAL_ID('guest')  
        AND [state_desc] LIKE 'GRANT%'  
        AND [permission_name] = 'CONNECT' 
        AND DB_NAME() NOT IN ('master','tempdb','msdb');"

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        $data=$dataSet.Tables[0]
        $row = $data.Rows.Count
        if($row -gt 0){
            
            $sqlCommand=$sqlConnection.CreateCommand()

            $sqlCommand.CommandText="USE [$name];REVOKE CONNECT FROM guest;"

            #EXECUTE COMMAND
            $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
            $dataSet=New-Object System.Data.DataSet

            $sqlDataAdapter.Fill($dataSet)

            if($sqlDataAdapter){
                Write-Output "Successfully configured CONNECT permissions on the 'guest' user is Revoked within all SQL Server databases"
                Write-Output "Rerun script to view changes"
            }
        }
        else{
            Write-Output "No changes needed. CONNECT permissions on the 'guest' user is Revoked within all SQL Server databases"
        }
        
    }
}


$sqlConnection.Close()
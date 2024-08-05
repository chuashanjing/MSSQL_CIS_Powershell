#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="USE [msdb] 
 
SELECT count(*)  
FROM sys.databases AS db, sys.database_role_members AS drm  
INNER JOIN sys.database_principals AS r  
	ON drm.role_principal_id = r.principal_id  
INNER JOIN sys.database_principals AS m  
	ON drm.member_principal_id = m.principal_id  
WHERE r.name in ('db_owner', 'db_securityadmin', 'db_ddladmin', 'db_datawriter')
and m.name <>'dbo' and db.database_id=3; "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$value=$data.Rows[0]
$value
if($value['Column1'] -eq 0){
    Write-Output "No changes needed. Membership in admin roles in MSDB database is limited"
}
else{
    $sqlCommand.CommandText="USE [msdb]
    ALTER ROLE [db_owner] DROP MEMBER <username>; " #change username to desired username

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured membership in admin roles in MSDB database is limited"
        Write-Output "Rerun script to view changes"
    }
}

$sqlConnection.Close()
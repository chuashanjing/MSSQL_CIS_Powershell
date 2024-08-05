#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="USE [master] 
IF not exists (select * from sys.server_principals where name = 'DOMAIN\cis-scan') 
CREATE LOGIN [DOMAIN\cis-scan] FROM WINDOWS WITH DEFAULT_DATABASE=[master] 
USE master 
GRANT VIEW SERVER STATE TO [DOMAIN\cis-scan] 
IF not exists (select * from sys.database_principals where name = 'cis-scan') 
CREATE USER [cis-scan] for login [DOMAIN\cis-scan] 
GRANT EXECUTE on sys.xp_loginconfig to [cis-scan] 
USE msdb 
IF not exists (select * from sys.database_principals where name = 'cis-scan') 
CREATE USER [cis-scan] for login [DOMAIN\cis-scan] 
GRANT SELECT ON dbo.sysproxies to  [cis-scan] 
GRANT SELECT ON dbo.sysproxylogin to  [cis-scan] 
exec sp_MSforeachdb @command1= 'use ?;if db_name() not in (''master'',''msdb'',''tempdb'', ''model'') and not exists (select * from sys.database_principals where name = ''cis-scan'') CREATE USER [cis-scan] for login [DOMAIN\cis-scan]'  
exec sp_MSforeachdb @command1= 'use ?;if db_name() not in (''master'',''msdb'',''tempdb'', ''model'') and exists (select * from sys.database_principals where name = ''cis-scan'') GRANT SELECT ON sys.assemblies to  [cis-scan]'  
exec sp_MSforeachdb @command1= 'use ?;if db_name() not in (''master'',''msdb'',''tempdb'', ''model'') and exists (select * from sys.database_principals where name = ''cis-scan'') GRANT SELECT ON sys.symmetric_keys to [cis-scan]'  
exec sp_MSforeachdb @command1= 'use ?;if db_name() not in (''master'',''msdb'',''tempdb'', ''model'') and exists (select * from sys.database_principals where name = ''cis-scan'') GRANT SELECT ON sys.asymmetric_keys to [cis-scan]' "

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

if($sqlDataAdapter){
    Write-Output 'Established an audit/scan user'
}
else{
    Write-Output 'Failed'
}

$sqlConnection.Close()
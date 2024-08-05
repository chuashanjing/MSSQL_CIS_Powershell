#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT  
S.name AS 'Audit Name', CASE S.is_state_enabled WHEN 1 THEN 'Y' WHEN 0 THEN 'N' END AS 'Audit Enabled',
S.type_desc AS 'Write Location', SA.name AS 'Audit Specification Name', CASE SA.is_state_enabled 
WHEN 1 THEN 'Y' WHEN 0 THEN 'N' END AS 'Audit Specification Enabled', SAD.audit_action_name, SAD.audited_result 
FROM sys.server_audit_specification_details AS SAD JOIN sys.server_audit_specifications AS SA 
ON SAD.server_specification_id = SA.server_specification_id JOIN sys.server_audits AS S 
ON SA.audit_guid = S.audit_guid WHERE SAD.audit_action_id IN ('CNAU', 'LGFL', 'LGSD', 'ADDP', 'ADSP', 'OPSV')
or (SAD.audit_action_id IN ('DAGS', 'DAGF') and (select count(*) from sys.databases where containment=1) > 0);"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number = $row.Count

if($number -eq 0){
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="CREATE SERVER AUDIT TrackLogins TO APPLICATION_LOG; 
    CREATE SERVER AUDIT SPECIFICATION TrackAllLogins 
    FOR SERVER AUDIT TrackLogins 
      ADD (FAILED_LOGIN_GROUP), 
      ADD (SUCCESSFUL_LOGIN_GROUP), 
      ADD (AUDIT_CHANGE_GROUP), 
      ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP), 
      ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP), 
      ADD (SERVER_OPERATION_GROUP), 
      ADD (SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP), 
      ADD (FAILED_DATABASE_AUTHENTICATION_GROUP) 
    WITH (STATE = ON); 
    ALTER SERVER AUDIT TrackLogins 
    WITH (STATE = ON);"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 5.4."
        Write-Output "Rerun script to view changes"
    }
}
else{
    Write-Output "No changes needed. 5.4 is compliant"
}


$sqlConnection.Close()
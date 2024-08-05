#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT *  
FROM master.sys.server_permissions 
WHERE (grantee_principal_id = SUSER_SID(N'public') and state_desc LIKE 'GRANT%') 
AND NOT (state_desc = 'GRANT' and [permission_name] = 'VIEW ANY DATABASE' and class_desc = 'SERVER') 
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 2) 
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 3) 
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 4) 
AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 5);"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$data
$number=$data.Rows.Count
$values = $data.Rows[0]

if($number -gt 0){
    
    foreach($values in $data){
        $permission_name=$values['permission_name']
        $permission_name
        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="USE [master]
        REVOKE $permission_name FROM public;"

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        if($sqlDataAdapter){
            Write-Output "Successfully configured default permissions specified by Microsoft are granted to the public server role."
            Write-Output "Rerun script to view changes"
        }

    }

}
else{
    Write-Output "No changes needed. Default permissions specified by Microsoft are granted to the public server role."
}


$sqlConnection.Close()
#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT l.[name], 'sysadmin membership' AS 'Access_Method' 
FROM sys.sql_logins AS l 
WHERE IS_SRVROLEMEMBER('sysadmin',name) = 1 
AND l.is_expiration_checked <> 1 
UNION ALL 
SELECT l.[name], 'CONTROL SERVER' AS 'Access_Method' 
FROM sys.sql_logins AS l 
JOIN sys.server_permissions AS p 
ON l.principal_id = p.grantee_principal_id 
WHERE p.type = 'CL' AND p.state IN ('G', 'W') 
AND l.is_expiration_checked <> 1;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number=$data.Rows.Count

if($number -gt 0){
    foreach($value in $row){
        $name=$value.name
        $sqlCommand=$sqlConnection.CreateCommand()

        $sqlCommand.CommandText="ALTER LOGIN [$name] WITH CHECK_EXPIRATION = ON;"

        #EXECUTE COMMAND
        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)

        if($sqlDataAdapter){
            Write-Output "Successfully configured 4.2"
            Write-Output "Rerun script to view changes"
        }
    }
}
else{
    Write-Output "No changes needed. 4.2 is compliant"
}

$sqlConnection.Close()
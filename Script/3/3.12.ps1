#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT distinct(name),type_desc 
FROM master.sys.server_principals a , sys.dm_server_services b 
WHERE IS_SRVROLEMEMBER ('sysadmin',name) = 1 and a.name=b.service_account;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$number=$data.Rows.Count

if($number -eq 0){
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="SELECT   distinct(name),type_desc 
    FROM     master.sys.server_principals 
    WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1 
    AND name not in ( 
    'NT SERVICE\SQLWriter', 
    'NT SERVICE\Winmgmt', 
    'NT SERVICE\MSSQLSERVER', 
    'NT SERVICE\SQLSERVERAGENT' 
    );"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        $data = $dataSet.Tables[0]
        $number = $data.Rows.Count

        if($number -gt 0){
            
            foreach($value in $data){
                $name=$value.name
                
                $sqlCommand=$sqlConnection.CreateCommand()

                $sqlCommand.CommandText="ALTER ROLE SYSADMIN DROP MEMBER [$name];"

                #EXECUTE COMMAND
                $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
                $dataSet=New-Object System.Data.DataSet

                $sqlDataAdapter.Fill($dataSet)

                if($sqlDataAdapter){
                    Write-Output "Successfully configured 'SYSADMIN' Role is Limited to Administrative or Built-in Accounts"
                    Write-Output "Rerun script to view changes"
                }

            }             
        }
        else{
                Write-Output "No changes needed. 'SYSADMIN' Role is Limited to Administrative or Built-in Accounts"
        }
    }
}

$sqlConnection.Close()
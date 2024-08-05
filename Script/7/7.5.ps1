#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE <DATABASE_NAME>
$sqlCommand.CommandText="select database_id, name, is_encrypted from sys.databases 
where database_id > 4 and is_encrypted != 1"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$data
$row=$data.Rows
$number = $data.Rows.Count

if($number -gt 0){
    foreach($value in $data){
    
        $name = $value.name
        $sqlCommand=$sqlConnection.CreateCommand()

        #replace 1234abcd$ with strong password
        $sqlCommand.CommandText="USE master;
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'abcd1234$>';
        CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'My DEK Certificate';
        USE AdventureWorks2019;
        CREATE DATABASE ENCRYPTION KEY
        WITH ALGORITHM = AES_256
        ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
        ALTER DATABASE AdventureWorks2019
        SET ENCRYPTION ON;"

        $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
        $dataSet=New-Object System.Data.DataSet

        $sqlDataAdapter.Fill($dataSet)
        
        if($sqlDataAdapter){
            Write-Output "Successfully configured 7.5. Rerun to view changes"
        }

    }

}
else{
    Write-Output "No changes needed. 7.5 is compliant"
}

$sqlConnection.Close()
#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE Logging WITH SOMETHING ELSE THIS IS FOR TESTING########################
$sqlCommand.CommandText="USE Logging
SELECT db_name() AS Database_Name, name AS Key_Name 
FROM sys.symmetric_keys 
WHERE algorithm_desc NOT IN ('AES_128','AES_192','AES_256') 
AND db_id() > 4;"

#EXECUTE COMMAND
$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

#DISPLAY THE DATA
$data=$dataSet.Tables[0]
$row=$data.Rows[0]
$number = $row.Count

if($number -eq 0){
    Write-Output "No changes needed. 7.1 is compliant"
}
else{
    $sqlCommand=$sqlConnection.CreateCommand()
    $sqlCommand.CommandText="CREATE SYMMETRIC KEY JanainaKey043 WITH ALGORITHM = AES_256   
    ENCRYPTION BY CERTIFICATE Shipping04;
    -- Open the key.   
    OPEN SYMMETRIC KEY JanainaKey043 DECRYPTION BY CERTIFICATE Shipping04  
        WITH PASSWORD = '<enterStrongPasswordHere>';   
    -- First, encrypt the key with a password.  
    ALTER SYMMETRIC KEY JanainaKey043   
        ADD ENCRYPTION BY PASSWORD = '<enterStrongPasswordHere>';  
    -- Now remove encryption by the certificate.  
    ALTER SYMMETRIC KEY JanainaKey043   
        DROP ENCRYPTION BY CERTIFICATE Shipping04;  
    CLOSE SYMMETRIC KEY JanainaKey043;"

    #EXECUTE COMMAND
    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)

    if($sqlDataAdapter){
        Write-Output "Successfully configured 7.1. Rerun script to view changes"
    }
}

$sqlConnection.Close()
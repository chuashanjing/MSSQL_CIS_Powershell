#CONNECTION
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

#CREATE A COMMAND TEXT
$sqlCommand=$sqlConnection.CreateCommand()

#REPLACE Logging WITH SOMETHING ELSE THIS IS FOR TESTING########################
$sqlCommand.CommandText="USE Logging
SELECT db_name() AS Database_Name, name AS Key_Name 
FROM sys.asymmetric_keys 
WHERE key_length < 2048 
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
    Write-Output "No changes needed. 7.2 is compliant"
}
else{
    #################FIRST METHOD
    $sqlCommand=$sqlConnection.CreateCommand()
    $sqlCommand.CommandText="ALTER ASYMMETRIC KEY PacificSales09   
    WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '<oldPassword>', ENCRYPTION BY PASSWORD = '<enterStrongPasswordHere>');"

    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)


    #####################SECOND METHOD
    $sqlCommand1=$sqlConnection.CreateCommand()
    $sqlCommand1.CommandText="ALTER ASYMMETRIC KEY PacificSales19 REMOVE PRIVATE KEY;"

    $sqlDataAdapter1=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand1
    $dataSet1=New-Object System.Data.DataSet
    
    $sqlDataAdapter1.Fill($dataSet1)


    #############THIRD METHOD
    $sqlCommand2=$sqlConnection.CreateCommand()
    $sqlCommand2.CommandText="OPEN MASTER KEY DECRYPTION BY PASSWORD = '<database master key password>';  
    ALTER ASYMMETRIC KEY PacificSales09 WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '<enterStrongPasswordHere>' );"

    $sqlDataAdapter2=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand2
    $dataSet2=New-Object System.Data.DataSet
    
    $sqlDataAdapter2.Fill($dataSet2)
    

    if($sqlDataAdapter -and $sqlDataAdapter1 -and $sqlDataAdapter2){
        Write-Output "Successfully configured 7.2. Rerun script to view changes"
    }
}

$sqlConnection.Close()
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Ad Hoc Distributed Queries';"

$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

$data=$dataSet.Tables[0]
$row = $data.Rows[0]


if ($row['value_configured'] -eq 0 -and $row['value_in_use'] -eq 0){
    $row
    Write-Output 'The configuration complies to the MS SQL 2019 CIS BENCHMARK'
}
else
{
    $sqlCommand=$sqlConnection.CreateCommand()

    $sqlCommand.CommandText="EXECUTE sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXECUTE sp_configure 'Ad Hoc Distributed Queries', 0;
    RECONFIGURE;
    EXECUTE sp_configure 'show advanced options', 0;
    RECONFIGURE;"

    $sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataSet=New-Object System.Data.DataSet

    $sqlDataAdapter.Fill($dataSet)
    if($sqlDataAdapter){
        Write-Output "Successfully set 'Ad Hoc Distributed Queries' Server Configuration Option to 0. Rerun the script to see changes"
    }
}





$sqlConnection.Close()
$sqlConnection=New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString="Server=localhost\sqlexpress;Database=Logging;Integrated Security=true"
$sqlConnection.Open()

$sqlCommand=$sqlConnection.CreateCommand()

$sqlCommand.CommandText="SELECT SERVERPROPERTY('ProductLevel') as SP_installed,
SERVERPROPERTY('ProductVersion') as Version,
SERVERPROPERTY('ProductUpdateLevel') as 'ProductUpdate_Level1',
SERVERPROPERTY('ProductUpdateReference') as 'KB_Number';"

$sqlDataAdapter=New-Object System.Data.SqlClient.SqlDataAdapter $sqlCommand
$dataSet=New-Object System.Data.DataSet

$sqlDataAdapter.Fill($dataSet)

$data=$dataset.Tables
$data

$sqlConnection.Close()
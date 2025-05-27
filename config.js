const sql = require('mssql');
require('dotenv').config();

const config = {
    connectionString: process.env.DB_CONNECTION_STRING || 'Server=tcp:ahsqlserver3123.database.windows.net,1433;Initial Catalog=mydatabase;User ID=sqladminuser;Password=ah@Password123;Encrypt=true;Connection Timeout=30;'
};

module.exports = { sql, config };

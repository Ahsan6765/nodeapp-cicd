const sql = require('mssql');
require('dotenv').config();

const config = {
    connectionString: process.env.AZURE_SQL_CONNECTION_STRING,
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

module.exports = { sql, config };

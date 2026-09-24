const sql = require('mssql');
require('dotenv').config();

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_DATABASE,
    options: {
        trustServerCertificate: true,
    },
};

async function inspect() {
    try {
        console.log('Connecting to database...');
        await sql.connect(dbConfig);
        console.log('Connected successfully!');

        // 1. Get all tables
        const tablesResult = await sql.query(`
            SELECT TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_TYPE = 'BASE TABLE'
            ORDER BY TABLE_NAME
        `);
        console.log('\n--- TABLES IN DATABASE ---');
        const tables = tablesResult.recordset.map(r => r.TABLE_NAME);
        console.log(tables);

        // 2. Get details for each table
        for (const table of tables) {
            console.log(`\n======================================================`);
            console.log(`TABLE: ${table}`);
            console.log(`======================================================`);
            
            // Get columns and types
            const columnsResult = await sql.query(`
                SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = '${table}'
                ORDER BY ORDINAL_POSITION
            `);
            console.log('Columns:');
            columnsResult.recordset.forEach(c => {
                const len = c.CHARACTER_MAXIMUM_LENGTH ? `(${c.CHARACTER_MAXIMUM_LENGTH})` : '';
                const nullable = c.IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL';
                const def = c.COLUMN_DEFAULT ? ` DEFAULT ${c.COLUMN_DEFAULT}` : '';
                console.log(`  - ${c.COLUMN_NAME}: ${c.DATA_TYPE}${len} ${nullable}${def}`);
            });

            // Get primary and foreign keys
            const keysResult = await sql.query(`
                SELECT 
                    tc.CONSTRAINT_TYPE,
                    tc.CONSTRAINT_NAME,
                    kcu.COLUMN_NAME,
                    ccu.TABLE_NAME AS REFERENCED_TABLE_NAME,
                    ccu.COLUMN_NAME AS REFERENCED_COLUMN_NAME
                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
                    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
                LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
                    ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
                LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                    ON rc.UNIQUE_CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                WHERE tc.TABLE_NAME = '${table}'
            `);
            if (keysResult.recordset.length > 0) {
                console.log('Constraints/Keys:');
                keysResult.recordset.forEach(k => {
                    const ref = k.REFERENCED_TABLE_NAME ? ` -> ${k.REFERENCED_TABLE_NAME}.${k.REFERENCED_COLUMN_NAME}` : '';
                    console.log(`  - [${k.CONSTRAINT_TYPE}] ${k.COLUMN_NAME} (Name: ${k.CONSTRAINT_NAME})${ref}`);
                });
            }
        }

        // 3. Stored Procedures
        const proceduresResult = await sql.query(`
            SELECT ROUTINE_NAME, ROUTINE_TYPE
            FROM INFORMATION_SCHEMA.ROUTINES
            WHERE ROUTINE_TYPE = 'PROCEDURE'
            ORDER BY ROUTINE_NAME
        `);
        console.log('\n--- PROCEDURES ---');
        proceduresResult.recordset.forEach(p => {
            console.log(`  - ${p.ROUTINE_NAME} (${p.ROUTINE_TYPE})`);
        });

    } catch (err) {
        console.error('Error during inspection:', err);
    } finally {
        await sql.close();
    }
}

inspect();

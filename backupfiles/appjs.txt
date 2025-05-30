
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const sql = require('mssql');
const dotenv = require('dotenv');
const path = require('path');
const session = require('express-session');  // <-- Added

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static('public'));

// Session setup
app.use(session({
    secret: 'supersecretkey',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } // Set secure: true in production with HTTPS
}));

// SQL Configuration
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

// Root route redirect to /register
app.get('/', (req, res) => {
    res.redirect('/register');
});

// Registration Page
app.get('/register', (req, res) => {
    res.render('register', { message: null });
});

// Registration Handler
app.post('/register', async (req, res) => {
    const { username, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        await sql.connect(dbConfig);
        await sql.query`INSERT INTO AppUsers (username, email, password) VALUES (${username}, ${email}, ${hashedPassword})`;
        res.redirect('/login');
    } catch (err) {
        console.error(err);
        res.render('register', { message: 'Registration failed. Username might be taken.' });
    }
});

// Login Page
app.get('/login', (req, res) => {
    res.render('login', { message: null });
});

// Login Handler
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        await sql.connect(dbConfig);
        const result = await sql.query`SELECT * FROM AppUsers WHERE username = ${username}`;

        if (result.recordset.length === 0) {
            return res.render('login', { message: 'Invalid username or password.' });
        }

        const user = result.recordset[0];
        const isPasswordMatch = await bcrypt.compare(password, user.password);

        if (isPasswordMatch) {
            req.session.user = user.username;  // <-- Save session
            res.redirect('/home');
        } else {
            res.render('login', { message: 'Invalid username or password.' });
        }
    } catch (err) {
        console.error(err);
        res.render('login', { message: 'Login failed. Please try again.' });
    }
});

// Home Page (Protected)
app.get('/home', (req, res) => {
    if (!req.session.user) {
        return res.redirect('/login');
    }
    res.render('home', { username: req.session.user });
});

// Logout Handler
app.get('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) {
            console.error(err);
        }
        res.redirect('/login');
    });
});

// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});

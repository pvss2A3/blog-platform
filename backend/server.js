const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const session = require('express-session');
const serveStatic = require('serve-static');
const path = require('path');
const app = express();

app.use(express.json());
app.use(session({ secret: 'your-secret-key', resave: false, saveUninitialized: false }));

const db = new Pool({
    host: '${var.rds_endpoint}', // Replaces from Terraform output
    user: 'bloguser',
    password: process.env.DB_PASSWORD || '${var.db_password}', // Replace with your db_password
    database: 'blog_platform',
    port: 5432
});

const isAuthenticated = (req, res, next) => {
    if (req.session.user) next();
    else res.status(401).json({ error: 'Unauthorized' });
};

app.post('/api/register', async (req, res) => {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    try {
        const result = await db.query('INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id', [username, hashedPassword]);
        res.status(201).json({ id: result.rows[0].id });
    } catch (err) {
        res.status(400).json({ error: 'Username taken' });
    }
});

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    const result = await db.query('SELECT * FROM users WHERE username = $1', [username]);
    const user = result.rows[0];
    if (user && await bcrypt.compare(password, user.password)) {
        req.session.user = { id: user.id, username: user.username };
        res.json({ message: 'Logged in' });
    } else {
        res.status(401).json({ error: 'Invalid credentials' });
    }
});

app.post('/api/posts', isAuthenticated, async (req, res) => {
    const { title, content } = req.body;
    const result = await db.query('INSERT INTO posts (user_id, title, content) VALUES ($1, $2, $3) RETURNING id', [req.session.user.id, title, content]);
    res.status(201).json({ id: result.rows[0].id });
});

app.get('/api/posts', async (req, res) => {
    const result = await db.query('SELECT p.*, u.username FROM posts p JOIN users u ON p.user_id = u.id');
    res.json(result.rows);
});

app.use(serveStatic(path.join(__dirname, 'frontend'), { index: ['index.html'] }));

app.listen(3000, () => console.log('Server running on port 3000'));

resource "aws_instance" "app_server" {
  ami           = "ami-071226ecf16aa7d96" # Updated AMI as specified
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_ids[0]
  security_groups = [var.app_sg_id]
  key_name      = "MyKeyPair" # Replace with your AWS Academy Lab key pair name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              curl -sL https://rpm.nodesource.com/setup_16.x | bash -
              yum install -y nodejs
              mkdir /app
              cd /app
              npm init -y
              npm install express pg bcrypt express-session
              cat << 'EOL' > server.js
              const express = require('express');
              const { Pool } = require('pg');
              const bcrypt = require('bcrypt');
              const session = require('express-session');
              const app = express();
              app.use(express.json());
              app.use(session({ secret: 'your-secret-key', resave: false, saveUninitialized: false }));
              const db = new Pool({
                  host: '${var.rds_endpoint}',
                  user: 'bloguser',
                  password: '${var.db_password}',
                  database: 'blog_platform',
                  port: 5432
              });
              const isAuthenticated = (req, res, next) => {
                  if (req.session.user) next();
                  else res.status(401).json({ error: 'Unauthorized' });
              };
              app.post('/register', async (req, res) => {
                  const { username, password } = req.body;
                  const hashedPassword = await bcrypt.hash(password, 10);
                  try {
                      const result = await db.query('INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id', [username, hashedPassword]);
                      res.status(201).json({ id: result.rows[0].id });
                  } catch (err) { res.status(400).json({ error: 'Username taken' }); }
              });
              app.post('/login', async (req, res) => {
                  const { username, password } = req.body;
                  const result = await db.query('SELECT * FROM users WHERE username = $1', [username]);
                  const user = result.rows[0];
                  if (user && await bcrypt.compare(password, user.password)) {
                      req.session.user = { id: user.id, username: user.username };
                      res.json({ message: 'Logged in' });
                  } else { res.status(401).json({ error: 'Invalid credentials' }); }
              });
              app.post('/posts', isAuthenticated, async (req, res) => {
                  const { title, content } = req.body;
                  const result = await db.query('INSERT INTO posts (user_id, title, content) VALUES ($1, $2, $3) RETURNING id', [req.session.user.id, title, content]);
                  res.status(201).json({ id: result.rows[0].id });
              });
              app.get('/posts', async (req, res) => {
                  const result = await db.query('SELECT p.*, u.username FROM posts p JOIN users u ON p.user_id = u.id');
                  res.json(result.rows);
              });
              app.listen(3000, () => console.log('Server running on port 3000'));
              EOL
              node server.js &
              EOF
  tags = { Name = "BlogAppServer" }
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}
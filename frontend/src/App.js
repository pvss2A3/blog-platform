import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
    const [posts, setPosts] = useState([]);
    const [title, setTitle] = useState('');
    const [content, setContent] = useState('');
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [loggedIn, setLoggedIn] = useState(false);

    useEffect(() => {
        fetchPosts();
    }, []);

    const fetchPosts = async () => {
        const res = await fetch('/api/posts');
        const data = await res.json();
        setPosts(data);
    };

    const handleRegister = async () => {
        await fetch('/api/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        setUsername('');
        setPassword('');
    };

    const handleLogin = async () => {
        const res = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password }),
            credentials: 'include'
        });
        if (res.ok) setLoggedIn(true);
        setUsername('');
        setPassword('');
    };

    const handlePost = async () => {
        await fetch('/api/posts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title, content }),
            credentials: 'include'
        });
        fetchPosts();
        setTitle('');
        setContent('');
    };

    return (
        <div className="App">
            {!loggedIn ? (
                <div className="auth">
                    <h2>Register/Login</h2>
                    <input
                        value={username}
                        onChange={e => setUsername(e.target.value)}
                        placeholder="Username"
                    />
                    <input
                        value={password}
                        onChange={e => setPassword(e.target.value)}
                        type="password"
                        placeholder="Password"
                    />
                    <button onClick={handleRegister}>Register</button>
                    <button onClick={handleLogin}>Login</button>
                </div>
            ) : (
                <div className="post-form">
                    <h2>Create Post</h2>
                    <input
                        value={title}
                        onChange={e => setTitle(e.target.value)}
                        placeholder="Title"
                    />
                    <textarea
                        value={content}
                        onChange={e => setContent(e.target.value)}
                        placeholder="Content"
                    />
                    <button onClick={handlePost}>Post</button>
                </div>
            )}
            <h2>Posts</h2>
            <div className="posts">
                {posts.map(post => (
                    <div key={post.id} className="post">
                        <h3>{post.title} by {post.username}</h3>
                        <p>{post.content}</p>
                    </div>
                ))}
            </div>
        </div>
    );
}

export default App;

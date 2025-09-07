const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// In-memory storage (in production, use a database)
let runs = [
  {
    id: 1,
    date: '2024-01-15',
    distance: 5.2,
    duration: 28,
    pace: '5:23',
    location: 'Central Park'
  },
  {
    id: 2,
    date: '2024-01-17',
    distance: 3.1,
    duration: 18,
    pace: '5:48',
    location: 'Riverside Trail'
  }
];

// Routes
app.get('/api/runs', (req, res) => {
  res.json(runs);
});

app.post('/api/runs', (req, res) => {
  const { date, distance, duration, location } = req.body;
  
  if (!date || !distance || !duration) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const pace = calculatePace(distance, duration);
  const newRun = {
    id: runs.length + 1,
    date,
    distance: parseFloat(distance),
    duration: parseInt(duration),
    pace,
    location: location || 'Unknown'
  };

  runs.push(newRun);
  res.status(201).json(newRun);
});

app.delete('/api/runs/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = runs.findIndex(run => run.id === id);
  
  if (index === -1) {
    return res.status(404).json({ error: 'Run not found' });
  }

  runs.splice(index, 1);
  res.status(204).send();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Serve main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

function calculatePace(distance, duration) {
  const paceInMinutes = duration / distance;
  const minutes = Math.floor(paceInMinutes);
  const seconds = Math.round((paceInMinutes - minutes) * 60);
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

app.listen(port, '0.0.0.0', () => {
  console.log(`Running Tracker App listening on port ${port}`);
});
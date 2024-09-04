const express = require('express');
const authRoutes = require('./routes/authRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const splitRoutes = require('./routes/splitRoutes');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const { getSecretValueByKey, setRegion } = require('./utils/awsSecrets');

const app = express();
app.use(cors());
app.use(express.json());
app.use(cookieParser());

app.use('/api', authRoutes);
app.use('/api', transactionRoutes);
app.use('/api', splitRoutes);

async function startServer() {
  try {
    setRegion('us-east-1');
    const port = await getSecretValueByKey('dev-api', 'PORT');
    
    const PORT = port || process.env.PORT || 443;
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });

    app.get('/', (req, res) => {
      res.status(200).send('Hello World');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

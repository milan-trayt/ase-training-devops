import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';
import './index.css';
import AxiosConfigUpdater from './utils/AxiosConfigUpdater';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <AxiosConfigUpdater />
    <App />
  </StrictMode>
);

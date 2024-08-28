import axios from 'axios';
import useAuthStore from '../states/axios';
import { useNavigate } from 'react-router-dom';

const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

axiosInstance.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

axiosInstance.interceptors.response.use(
  (response) => response,
  async (error) => {
    const { response } = error;
    if (response && response.status === 401) {
      const refreshToken = JSON.parse(localStorage.getItem('refresh'));

      if (refreshToken) {
        try {
          const refreshResponse = await axiosInstance.post('/refresh', { refreshToken });

          useAuthStore.getState().setToken(refreshResponse.data.AccessToken);

          localStorage.setItem('token', refreshResponse.data.AccessToken);

          error.config.headers['Authorization'] = `Bearer ${refreshResponse.data.AccessToken}`;
          return axiosInstance(error.config);
        } catch (refreshError) {
          useAuthStore.getState().setToken('');
          localStorage.removeItem('token');
          localStorage.removeItem('refresh');
          localStorage.removeItem('user');
          const navigate = useNavigate();
          navigate('/signin');
          console.error('Failed to refresh token:', refreshError);
        }
      }
    }
    return Promise.reject(error);
  }
);

export default axiosInstance;

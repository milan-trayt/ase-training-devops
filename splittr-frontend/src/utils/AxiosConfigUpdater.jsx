import { useEffect } from 'react';
import axiosInstance from './axiosInstance';
import useAuthStore from '../states/axios';

const AxiosConfigUpdater = () => {
  const token = useAuthStore((state) => state.token);

  useEffect(() => {
    if (token) {
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    } else {
      delete axiosInstance.defaults.headers.common['Authorization'];
    }
  }, [token]);

  return null;
};

export default AxiosConfigUpdater;

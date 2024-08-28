import { create } from 'zustand';

const useAuthStore = create((set) => ({
  token: localStorage.getItem('token') || '',
  user: localStorage.getItem('user') || '',
  setToken: (newToken) => {
    localStorage.setItem('token', newToken);
    set({ token: newToken });
  },
  setUser: (newUser) => {
    localStorage.setItem('user', newUser);
    set({ user: newUser });
  },
}));

export default useAuthStore;

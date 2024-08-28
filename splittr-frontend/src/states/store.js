import { create } from 'zustand';

const authStore = create((set) => ({
  email: '',
  setEmail: (email) => set({ email }),
}));

export default authStore;

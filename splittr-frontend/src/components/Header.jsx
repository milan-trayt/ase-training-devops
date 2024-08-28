import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { jwtDecode } from 'jwt-decode';
import { isAuthenticated } from '../utils/auth'; // Ensure this function is implemented correctly
import useAuthStore from '../states/axios';

const Header = () => {
  const navigate = useNavigate();
  const [userName, setUserName] = useState('User');

  // Function to get username from the token
  const getUserName = () => {
    const token = useAuthStore.getState().user;
    if (token) {
      try {
        const decoded = jwtDecode(token);
        return decoded?.name || 'User';
      } catch (error) {
        console.error('Failed to decode token:', error);
        return 'User';
      }
    }
    return 'User';
  };

  // Update username on mount and when authentication status changes
  useEffect(() => {
    if (isAuthenticated()) {
      console.log('Authenticated');
      setUserName(getUserName());
    } else {
      setUserName('User');
    }
  }, [isAuthenticated()]);

  const handleLogout = () => {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    localStorage.removeItem('refresh');
    setUserName('User'); // Reset username on logout
    navigate('/signin');
  };

  return (
    <header className='border-b border-gray-300 bg-gray-50 shadow-md'>
      <div className='container mx-auto flex items-center justify-between h-16 px-4'>
        <div className='flex items-center space-x-6'>
          <Link to='/' className='text-blue-600 hover:text-blue-800 font-semibold'>Home</Link>
          <Link to='/statement' className='text-blue-600 hover:text-blue-800 font-semibold'>Statement</Link>
        </div>
        <div className='flex items-center space-x-4'>
          {isAuthenticated() ? (
            <>
              <span className='text-gray-800 font-medium'>Hi! {userName}</span>
              <button 
                className='bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700'
                onClick={handleLogout}
              >
                Logout
              </button>
            </>
          ) : (
            <Link to='/signin' className='text-blue-600 hover:text-blue-800 font-semibold'>
              Login
            </Link>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;

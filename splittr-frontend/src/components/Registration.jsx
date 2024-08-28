import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Icon } from "react-icons-kit";
import { eyeOff } from "react-icons-kit/feather/eyeOff";
import { eye } from "react-icons-kit/feather/eye";
import { toast } from "react-toastify";
import authStore from "../states/store";
import { useNavigate } from "react-router-dom";
import { isAuthenticated } from "../utils/auth";
import axiosInstance from "../utils/axiosInstance";

const Registration = () => {
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [email, setEmail] = authStore((state) => [state.email, state.setEmail]);
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [type, setType] = useState("password");
  const [confirmType, setConfirmType] = useState("password");
  const [icon, setIcon] = useState(eyeOff);
  const [confirmIcon, setConfirmIcon] = useState(eyeOff);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isAuthenticated()) {
      navigate("/");
    }
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);
    if (password !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    } else {
      const payload = {
        fullName: name,
        email: email,
        password: password
      };
      axiosInstance
        .post("signup", payload)
        .then((res) => {
          toast.success(res.data);
          toast.info("Please verify your email before logging in.");
          setLoading(false);
          navigate("/verify");
        })
        .catch((err) => {
          toast.error(err.response.data);
          setLoading(false);
        });
    }
  };

  const handleToggle = (field) => {
    if (field === "password") {
      if (type === "password") {
        setIcon(eye);
        setType("text");
      } else {
        setIcon(eyeOff);
        setType("password");
      }
    } else if (field === "confirmPassword") {
      if (confirmType === "password") {
        setConfirmIcon(eye);
        setConfirmType("text");
      } else {
        setConfirmIcon(eyeOff);
        setConfirmType("password");
      }
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4">
      <div className="w-full max-w-md bg-white shadow-lg rounded-lg p-6 sm:p-8 md:p-10">
        <h2 className="text-2xl sm:text-3xl font-bold mb-6 text-gray-800 text-center">
          Sign Up
        </h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label
              htmlFor="name"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Full Name
            </label>
            <input
              type="name"
              id="email"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Your full name"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm sm:text-base"
              required
            />
          </div>
          <div className="mb-4">
            <label
              htmlFor="email"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Email
            </label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Your email"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm sm:text-base"
              required
            />
          </div>
          <div className="mb-4">
            <label
              htmlFor="password"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Password
            </label>
            <div className="relative flex items-center">
              <input
                type={type}
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Your password"
                className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm sm:text-base"
                required
              />
              <span
                className="absolute right-3 cursor-pointer"
                onClick={() => handleToggle("password")}
              >
                <Icon icon={icon} size={25} />
              </span>
            </div>
          </div>
          <div className="mb-6">
            <label
              htmlFor="confirmPassword"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Confirm Password
            </label>
            <div className="relative flex items-center">
              <input
                type={confirmType}
                id="confirmPassword"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Confirm your password"
                className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm sm:text-base"
                required
              />
              <span
                className="absolute right-3 cursor-pointer"
                onClick={() => handleToggle("confirmPassword")}
              >
                <Icon icon={confirmIcon} size={25} />
              </span>
            </div>
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full disabled:opacity-50 py-2 px-4 bg-blue-500 text-white rounded-md shadow hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 text-sm sm:text-base"
          >
            {loading? "Signing Up...":"Sign Up"}
          </button>
          <p className="text-gray-600 text-sm mt-2 text-center">
            Already have an account?{" "}
            <Link to="/signin" className="text-blue-500">
              Login
            </Link>
          </p>
          <p className="text-gray-600 text-sm mt-2 text-center">
            Account not verified yet?{" "}
            <Link to="/verify" className="text-blue-500">
              Verify
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
};

export default Registration;

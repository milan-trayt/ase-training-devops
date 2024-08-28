import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Icon } from "react-icons-kit";
import { eyeOff } from "react-icons-kit/feather/eyeOff";
import { eye } from "react-icons-kit/feather/eye";
import { toast } from "react-toastify";
import authStore from "../states/store";
import useAuthStore from "../states/axios";
import { isAuthenticated } from "../utils/auth";
import axiosInstance from "../utils/axiosInstance";

const Login = () => {
  const navigate = useNavigate();
  const [email, setEmail] = authStore((state) => [state.email, state.setEmail]);
  const [password, setPassword] = useState("");
  const [type, setType] = useState("password");
  const [icon, setIcon] = useState(eyeOff);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isAuthenticated()) {
      navigate("/");
    }
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);
    const payload = {
      email: email,
      password: password,
    };

    axiosInstance
      .post("signin", payload)
      .then((res) => {
        useAuthStore.getState().setToken(res.data.AccessToken);
        useAuthStore.getState().setUser(res.data.IdToken);
        toast.success("Signed in successfully");
        localStorage.setItem("user", JSON.stringify(res.data.IdToken));
        localStorage.setItem("token", JSON.stringify(res.data.AccessToken));
        localStorage.setItem("refresh", JSON.stringify(res.data.RefreshToken));
        navigate("/");
        setLoading(false);
      })
      .catch((err) => {
        console.log(err);
        toast.error(err.response.data);
        setLoading(false);
      });
  };

  const handleToggle = () => {
    if (type === "password") {
      setIcon(eye);
      setType("text");
    } else {
      setIcon(eyeOff);
      setType("password");
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4">
      <div className="w-full max-w-md bg-white shadow-lg rounded-lg p-6 sm:p-8 md:p-10">
        <h2 className="text-2xl sm:text-3xl font-bold mb-6 text-gray-800 text-center">
          Sign In
        </h2>
        <form onSubmit={handleSubmit}>
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
          <div className="mb-6">
            <label
              htmlFor="password"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Password
            </label>
            <div className="flex">
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
                className="flex justify-around items-center"
                onClick={handleToggle}
              >
                <Icon
                  className="absolute mr-10 text-gray-500"
                  icon={icon}
                  size={25}
                />
              </span>
            </div>
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full disabled:opacity-50 py-2 px-4 bg-blue-500 text-white rounded-md shadow hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 text-sm sm:text-base"
          >
            {loading ? "Signing In ..." : "Sign In"}
          </button>
          <p className="text-gray-600 text-sm mt-2 text-center">
            Don&apos;t have an account?{" "}
            <Link to="/signup" className="text-blue-500">
              Sign up
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

export default Login;

import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { toast } from "react-toastify";
import authStore from "../states/store";
import { useNavigate } from "react-router-dom";
import { isAuthenticated } from "../utils/auth";
import axiosInstance from "../utils/axiosInstance";

const Verify = () => {
  const navigate = useNavigate();

  const [email, setEmail] = authStore((state) => [state.email, state.setEmail]);
  const [code, setCode] = useState("");
  const [resend, setResend] = useState(false);
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
      code: code
    };
    axiosInstance
      .post("verify", payload)
      .then((res) => {
        toast.success(res.data);
        toast.info("Please Sign in to continue.");
        setLoading(false);
        navigate("/signin");
      })
      .catch((err) => {
        toast.error(err.response.data);
        setLoading(false);
        setResend(true);
      });
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4">
      <div className="w-full max-w-md bg-white shadow-lg rounded-lg p-6 sm:p-8 md:p-10">
        <h2 className="text-2xl sm:text-3xl font-bold mb-6 text-gray-800 text-center">
          Verify
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
          <div>
            <label
              htmlFor="password"
              className="block text-gray-700 text-sm sm:text-base font-medium mb-2"
            >
              Verification Code
            </label>
            <div className="flex">
              <input
                type="text"
                id="code"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="Your verification code"
                className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm sm:text-base"
                required
              />
            </div>
          </div>
          {resend ? (
            <p className=" cursor-pointer text-blue-700" onClick={() => {
              axiosInstance
                .post("resend", { email: email })
                .then((res) => {
                  toast.success(res.data);
                  setResend(false);
                })
                .catch((err) => {
                  toast.error(err.response.data);
                });
            }}>Resend Code</p>
          ): null}
          <button
            type="submit"
            disabled={loading}
            className=" mt-6 w-full py-2 px-4 bg-blue-500 text-white rounded-md shadow hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 text-sm sm:text-base"
          >
            {loading? "Verifying...": "Verify"}
          </button>
          <p className="text-gray-600 text-sm mt-2 text-center">
            Don&apos;t have an account?{" "}
            <Link to="/signup" className="text-blue-500">
              Sign up
            </Link>
          </p>
          <p className="text-gray-600 text-sm mt-2 text-center">
            Account already verified?{" "}
            <Link to="/signin" className="text-blue-500">
              Login
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
};

export default Verify;

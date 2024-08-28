import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "./components/Home";
import Login from "./components/Login";
import Verify from "./components/Verify";
import Registration from "./components/Registration";
import Header from "./components/Header";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import ProtectedRoute from "./utils/ProtectedRoute";
import Statement from "./components/Statement";

function App() {
  return (
    <>
      <Router>
        <ToastContainer />
        <Header />
        <Routes>
          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<Home />} />
            <Route path="/statement" element={<Statement />} />
          </Route>
          <Route path="/signin" element={<Login/>} />
          <Route path="/verify" element={<Verify />} />
          <Route path="/signup" element={<Registration />} />
        </Routes>
      </Router>
    </>
  );
}

export default App;

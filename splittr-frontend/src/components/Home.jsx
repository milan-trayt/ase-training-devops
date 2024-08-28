import { useState, useEffect } from "react";
import { toast } from "react-toastify";
import axiosInstance from "../utils/axiosInstance";

const Home = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [totals, setTotals] = useState({
    totalAmount: 0,
    totalIncome: 0,
    totalExpense: 0,
    monthlyIncome: 0,
    monthlyExpense: 0,
  });

  const [form, setForm] = useState({
    name: "",
    type: "income",
    amount: 0,
  });

  const fetchTransactions = async () => {
    setLoading(true);
    try {
      const response = await axiosInstance.get("transaction");
      const transactions = response.data;

      setTransactions(transactions);
      calculateTotals(transactions);
    } catch (error) {
      console.error("Failed to fetch transactions:", error);
    } finally {
      setLoading(false);
    }
  };

  const calculateTotals = (transactions) => {
    let totalIncome = 0;
    let totalExpense = 0;
    let monthlyIncome = 0;
    let monthlyExpense = 0;

    const currentMonth = new Date().getMonth();

    transactions.forEach((transaction) => {
      const amount = transaction.amount;
      const transactionMonth = new Date(transaction.date).getMonth();

      if (transaction.type === "income") {
        totalIncome += amount;
        if (transactionMonth === currentMonth) {
          monthlyIncome += amount;
        }
      } else if (transaction.type === "expense") {
        totalExpense += amount;
        if (transactionMonth === currentMonth) {
          monthlyExpense += amount;
        }
      }
    });

    setTotals({
      totalAmount: totalIncome - totalExpense,
      totalIncome,
      totalExpense,
      monthlyIncome,
      monthlyExpense,
    });
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: name === "amount" ? parseFloat(value) : value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (form.amount <= 0 || (form.type === "expense" && form.amount > totals.totalAmount)) {
      toast.error("Invalid amount or insufficient balance");
      return;
    }
    try {
      await axiosInstance.post("transaction", form);
      setForm({ name: "", type: "income", amount: 0 });
      setTransactions([...transactions, form]);
      calculateTotals([...transactions, form]);
      toast.success("Transaction submitted successfully");
    } catch (error) {
      toast.error("Failed to submit transaction");
      console.error("Failed to submit transaction:", error);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, []);

  return (
    <div className="container mx-auto p-4">
      <div className="grid grid-cols-1 md:grid-cols-5 gap-8 mb-6">
        <div className="bg-white p-4 rounded-lg md:col-span-3 shadow-md">
          <p className=" w-full m-auto text-center text-gray-700 mb-3">
            Total Balance
          </p>
          <div className="text-6xl w-full font-bold text-center mb-6">
            {loading ? (
              <div className="h-6 bg-gray-200 rounded animate-pulse"></div>
            ) : (
              <p>₹{totals.totalAmount}</p>
            )}
          </div>
          <div className="flex justify-around">
            <div className="flex items-center flex-col">
              <p className="text-green-500 text-lg font-semibold mr-2">
                Income
              </p>
              <div className=" text-2xl font-bold">
                {loading ? (
                  <div className="h-6 bg-gray-200 rounded animate-pulse"></div>
                ) : (
                  `₹${totals.totalIncome}`
                )}
              </div>
            </div>
            <div className="flex items-center flex-col">
              <p className="text-red-500 text-lg font-semibold mr-2">Expense</p>
              <div className="text-2xl font-bold">
                {loading ? (
                  <div className="h-6 bg-gray-200 rounded animate-pulse"></div>
                ) : (
                  `₹${totals.totalExpense}`
                )}
              </div>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg md:col-span-2 shadow-md">
          <p className=" w-full m-auto text-center text-gray-700 mb-3">
            This Month
          </p>
          <div className="w-full md:h-full flex flex-col justify-evenly">
            <div className="flex items-center">
              <p className="text-green-500 text-xl font-semibold mr-2">
                Income:
              </p>
              <div className=" text-3xl font-bold">
                {loading ? (
                  <div className="h-6 bg-gray-200 rounded animate-pulse"></div>
                ) : (
                  `₹${totals.monthlyIncome}`
                )}
              </div>
            </div>
            <div className="w-full">
              <div className="flex items-center">
                <p className="text-red-500 text-xl font-semibold mr-2">
                  Expense:
                </p>
                <div className="text-3xl font-bold">
                  {loading ? (
                    <div className="h-6 bg-gray-200 rounded animate-pulse"></div>
                  ) : (
                    `₹${totals.monthlyExpense}`
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <form
        onSubmit={handleSubmit}
        className="bg-white p-6 rounded-lg shadow-lg mb-6"
      >
        <h2 className="text-2xl font-semibold mb-4">Add Transaction</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            name="name"
            value={form.name}
            onChange={handleInputChange}
            placeholder="Name of Expense"
            className="p-2 border rounded-lg w-full"
            required
          />
          <select
            name="type"
            value={form.type}
            onChange={handleInputChange}
            className="p-2 border rounded-lg w-full"
          >
            <option value="income">Income</option>
            <option value="expense">Expense</option>
          </select>
          <input
            type="number"
            name="amount"
            value={form.amount}
            onChange={handleInputChange}
            placeholder="Amount"
            className="p-2 border rounded-lg w-full"
            required
          />
        </div>
        <button
          type="submit"
          className="mt-4 bg-blue-500 text-white p-2 rounded-lg"
        >
          Add Transaction
        </button>
      </form>

      <div className="bg-white p-6 rounded-lg md:px-12 shadow-md">
        <div className="grid md:grid-cols-2">
          <div className=" col-span-1">
            <h2 className="text-2xl font-semibold mb-4 underline">Recent Incomes</h2>
            <ul>
              {loading
                ? Array.from({ length: 10 }).map((_, idx) => (
                    <li
                      key={idx}
                      className="h-6 bg-gray-200 rounded mb-2 animate-pulse"
                    ></li>
                  ))
                : transactions
                    .filter((transaction) => transaction.type === "income")
                    .slice(-10)
                    .reverse()
                    .map((transaction, idx) => (
                      <li key={idx} className="mb-2">
                        <span className="font-bold">{transaction.name}</span>: ₹
                        {transaction.amount}
                      </li>
                    ))}
            </ul>
          </div>
          <div className="md:hidden w-full h-1 bg-gray-300"></div>
          <div className=" col-span-1 ">
            <h2 className="text-2xl font-semibold mb-4 underline">Recent Expenses</h2>
            <ul>
              {loading
                ? Array.from({ length: 10 }).map((_, idx) => (
                    <li
                      key={idx}
                      className="h-6 bg-gray-200 rounded mb-2 animate-pulse"
                    ></li>
                  ))
                : transactions
                    .filter((transaction) => transaction.type === "expense")
                    .slice(-10)
                    .reverse()
                    .map((transaction, idx) => (
                      <li key={idx} className="mb-2">
                        <span className="font-bold">{transaction.name}</span>: ₹
                        {transaction.amount}
                      </li>
                    ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;

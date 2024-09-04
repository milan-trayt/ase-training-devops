import { useState, useEffect } from "react";
import { toast } from "react-toastify";
import axiosInstance from "../utils/axiosInstance";

const Home = () => {
  const [transactions, setTransactions] = useState([]);
  const [splits, setSplits] = useState([]);
  const [loading, setLoading] = useState(true);
  const [totals, setTotals] = useState({
    totalAmount: 0,
    totalIncome: 0,
    totalExpense: 0,
    monthlyIncome: 0,
    monthlyExpense: 0,
  });

  const [transactionForm, setTransactionForm] = useState({
    name: "",
    type: "income",
    amount: 0,
  });

  const [splitForm, setSplitForm] = useState({
    split_name: "",
    amount: 0,
    participants: [],
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

  const fetchSplits = async () => {
    setLoading(true);
    try {
      const response = await axiosInstance.get("split");
      setSplits(response.data);
    } catch (error) {
      console.error("Failed to fetch splits:", error);
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
    const currentYear = new Date().getFullYear();

    transactions.forEach((transaction) => {
      const amount = transaction.amount;
      const transactionDate = new Date(transaction.date);
      const transactionMonth = transactionDate.getMonth();
      const transactionYear = transactionDate.getFullYear();

      if (transaction.type === "income") {
        totalIncome += amount;
        if (
          transactionMonth === currentMonth &&
          transactionYear === currentYear
        ) {
          monthlyIncome += amount;
        }
      } else if (transaction.type === "expense") {
        totalExpense += amount;
        if (
          transactionMonth === currentMonth &&
          transactionYear === currentYear
        ) {
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

  const handleTransactionInputChange = (e) => {
    const { name, value } = e.target;
    setTransactionForm({ ...transactionForm, [name]: name === "amount" ? parseFloat(value) : value });
  };

  const handleTransactionSubmit = async (e) => {
    e.preventDefault();

    if (
      transactionForm.amount <= 0 ||
      (transactionForm.type === "expense" && transactionForm.amount > totals.totalAmount)
    ) {
      toast.error("Invalid amount or insufficient balance");
      return;
    }

    const transactionDate = new Date().toISOString();
    try {
      await axiosInstance.post("transaction", { ...transactionForm, date: transactionDate });

      const updatedTransactions = [...transactions, { ...transactionForm, date: transactionDate }];
      setTransactions(updatedTransactions);
      calculateTotals(updatedTransactions);
      setTransactionForm({ name: "", type: "income", amount: 0 });
      toast.success("Transaction submitted successfully");
    } catch (error) {
      toast.error("Failed to submit transaction");
      console.error("Failed to submit transaction:", error);
    }
  };

  const handleSplitInputChange = (e) => {
    const { name, value } = e.target;
    setSplitForm({
      ...splitForm,
      [name]: name === "amount" ? parseFloat(value) : value,
    });
  };

  const handleParticipantsChange = (e) => {
    const { value } = e.target;
    setSplitForm({
      ...splitForm,
      participants: value.split(",").map(participant => participant.trim()).filter(name => name),
    });
  };

  const handleSplitSubmit = async (e) => {
    e.preventDefault();

    if (splitForm.participants.length === 0 || splitForm.amount <= 0) {
      toast.error("Please enter valid split details");
      return;
    }

    try {
      const response = await axiosInstance.post("split", { ...splitForm });
      const newSplit = response.data; // Assume the response contains the new split

      // Update state with the new split
      setSplits([...splits, newSplit]);

      setSplitForm({ split_name: "", amount: 0, participants: [] });
      toast.success("Split created successfully");
    } catch (error) {
      toast.error("Failed to create split");
      console.error("Failed to create split:", error);
    }
  };

  useEffect(() => {
    fetchTransactions();
    fetchSplits();
  }, []);

  return (
    <div className="container mx-auto p-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-6">
        <div className="bg-white p-4 rounded-lg md:col-span-2 shadow-md">
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
      </div>

      <form
        onSubmit={handleTransactionSubmit}
        className="bg-white p-6 rounded-lg shadow-lg mb-6"
      >
        <h2 className="text-2xl font-semibold mb-4">Add Transaction</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            name="name"
            value={transactionForm.name}
            onChange={handleTransactionInputChange}
            placeholder="Name of Transaction"
            className="p-2 border rounded-lg w-full"
            required
          />
          <select
            name="type"
            value={transactionForm.type}
            onChange={handleTransactionInputChange}
            className="p-2 border rounded-lg w-full"
          >
            <option value="income">Income</option>
            <option value="expense">Expense</option>
          </select>
          <input
            type="number"
            name="amount"
            value={transactionForm.amount}
            onChange={handleTransactionInputChange}
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

      <form
        onSubmit={handleSplitSubmit}
        className="bg-white p-6 rounded-lg shadow-lg mb-6"
      >
        <h2 className="text-2xl font-semibold mb-4">Create Split</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            name="split_name"
            value={splitForm.split_name}
            onChange={handleSplitInputChange}
            placeholder="Split Name"
            className="p-2 border rounded-lg w-full"
            required
          />
          <input
            type="number"
            name="amount"
            value={splitForm.amount}
            onChange={handleSplitInputChange}
            placeholder="Total Amount"
            className="p-2 border rounded-lg w-full"
            required
          />
          <input
            type="text"
            name="participants"
            value={splitForm.participants.join(", ")}
            onChange={handleParticipantsChange}
            placeholder="Participants (comma separated)"
            className="p-2 border rounded-lg w-full"
            required
          />
        </div>
        <button
          type="submit"
          className="mt-4 bg-blue-500 text-white p-2 rounded-lg"
        >
          Create Split
        </button>
      </form>

      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-2xl font-semibold mb-4">Splits</h2>
        <ul>
          {loading
            ? Array.from({ length: 5 }).map((_, idx) => (
                <li
                  key={idx}
                  className="h-6 bg-gray-200 rounded mb-2 animate-pulse"
                ></li>
              ))
            : splits.map((split, idx) => (
                <li key={idx} className="mb-4">
                  <h3 className="font-bold">{split.name}</h3>
                  <p>Total Amount: ₹{split.amount}</p>
                  <ul>
                    {split.participants.map((participant, pIdx) => (
                      <li key={pIdx}>{participant.name}: ₹{participant.amount}</li>
                    ))}
                  </ul>
                </li>
              ))}
        </ul>
      </div>
    </div>
  );
};

export default Home;

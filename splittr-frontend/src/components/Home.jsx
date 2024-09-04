import { useState, useEffect } from "react";
import axiosInstance from "../utils/axiosInstance";
import Balance from "./modules/Balance";
import Transaction from "./modules/Transaction";
import CreateSplit from "./modules/CreateSplit";
import ViewSplits from "./modules/ViewSplits";

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
      const response = await axiosInstance.get("splits");
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

  useEffect(() => {
    fetchTransactions();
    fetchSplits();
  }, []);

  return (
    <div className="container mx-auto p-4">
      <Balance totals={totals} loading={loading} />
      <Transaction transactions={transactions} setTransactions={setTransactions} totals={totals} calculateTotals={calculateTotals} />
      <CreateSplit splits={splits} setSplits={setSplits} transactions={transactions} setTransactions={setTransactions} calculateTotals={calculateTotals} totals={totals} />
      <ViewSplits splits={splits} setSplits={setSplits} loading={loading} />
    </div>
  );
};

export default Home;

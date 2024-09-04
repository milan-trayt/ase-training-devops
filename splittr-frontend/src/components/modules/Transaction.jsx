import { toast } from "react-toastify";
import { useState } from "react";
import axiosInstance from "../../utils/axiosInstance";
import Proptype from "prop-types";

const Transaction = ({
  transactions,
  setTransactions,
  totals,
  calculateTotals,
}) => {
  const [transactionForm, setTransactionForm] = useState({
    name: "",
    type: "income",
    amount: 0,
  });

  const handleTransactionSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);

    if (
      transactionForm.amount <= 0 ||
      (transactionForm.type === "expense" &&
        transactionForm.amount > totals.totalAmount)
    ) {
      toast.error("Invalid amount or insufficient balance");
      setSubmitting(false);
      return;
    }

    const transactionDate = new Date().toISOString();
    try {
      await axiosInstance.post("transaction", {
        ...transactionForm,
        date: transactionDate,
      });

      const updatedTransactions = [
        ...transactions,
        { ...transactionForm, date: transactionDate },
      ];
      setTransactions(updatedTransactions);
      calculateTotals(updatedTransactions);
      setTransactionForm({ name: "", type: "income", amount: 0 });
      setSubmitting(false);
      toast.success("Transaction submitted successfully");
    } catch (error) {
      toast.error("Failed to submit transaction");
      console.error("Failed to submit transaction:", error);
      setSubmitting(false);
    }
  };

  const handleTransactionInputChange = (e) => {
    const { name, value } = e.target;
    setTransactionForm({
      ...transactionForm,
      [name]: name === "amount" ? parseInt(value) : value,
    });
  };

  const [submitting, setSubmitting] = useState(false);

  return (
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
        disabled={submitting}
        type="submit"
        className={
          `mt-4 text-white p-2 rounded-lg` +
          (submitting ? " bg-gray-500" : " bg-blue-500")
        }
      >
        {submitting ? "Adding..." : "Add Transaction"}
      </button>
    </form>
  );
};

export default Transaction;

Transaction.propTypes = {
  transactions: Proptype.array.isRequired,
  setTransactions: Proptype.func.isRequired,
  totals: Proptype.object.isRequired,
  calculateTotals: Proptype.func.isRequired,
};

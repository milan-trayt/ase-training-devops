import { useState } from "react";
import { toast } from "react-toastify";
import axiosInstance from "../../utils/axiosInstance";
import PropTypes from "prop-types";

const CreateSplit = ({
  splits,
  setSplits,
  transactions,
  setTransactions,
  calculateTotals,
}) => {
  const [splitForm, setSplitForm] = useState({
    split_name: "",
    amount: 0,
    participants: [],
  });

  const handleSplitInputChange = (e) => {
    const { name, value } = e.target;
    setSplitForm({
      ...splitForm,
      [name]: name === "amount" ? parseInt(value) : value,
    });
  };

  const handleParticipantsChange = (e) => {
    const { value } = e.target;
    setSplitForm({
      ...splitForm,
      participants: value
        .split(",")
        .map((participant) => participant.trim())
        .filter((name) => name),
    });
  };

  const handleSplitSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);

    if (splitForm.participants.length === 0 || splitForm.amount <= 0) {
      toast.error("Please enter valid split details");
      setSubmitting(false);
      return;
    }

    try {
      const response = await axiosInstance.post("create", { ...splitForm });
      const newSplit = response.data;

      setSplits([...splits, newSplit]);
      setTransactions([
        ...transactions,
        {
          name: splitForm.split_name,
          type: "expense",
          amount: splitForm.amount,
          date: new Date().toISOString(),
        },
      ]);
      calculateTotals([
        ...transactions,
        {
          name: splitForm.split_name,
          type: "expense",
          amount: splitForm.amount,
          date: new Date().toISOString(),
        },
      ]);
      setSplitForm({ split_name: "", amount: 0, participants: [] });
      setSubmitting(false);
      toast.success("Split created successfully");
    } catch (error) {
      toast.error("Failed to create split");
      console.error("Failed to create split:", error);
      setSubmitting(false);
    }
  };

  const [submitting, setSubmitting] = useState(false);

  return (
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
        disabled={submitting}
        type="submit"
        className={
          `mt-4 text-white p-2 rounded-lg` +
          (submitting ? " bg-gray-500" : " bg-blue-500")
        }
      >
        {submitting ? "Creating Split..." : "Create Split"}
      </button>
    </form>
  );
};

export default CreateSplit;

CreateSplit.propTypes = {
  splits: PropTypes.array.isRequired,
  setSplits: PropTypes.func.isRequired,
  transactions: PropTypes.array.isRequired,
  setTransactions: PropTypes.func.isRequired,
  calculateTotals: PropTypes.func.isRequired,
};

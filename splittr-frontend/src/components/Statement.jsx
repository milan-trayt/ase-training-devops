import { useEffect, useState } from "react";
import axiosInstance from "../utils/axiosInstance";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import { CSVLink } from "react-csv";
import { Icon } from "react-icons-kit";
import { download } from "react-icons-kit/icomoon/download";

const Statement = () => {
  const [startDate, setStartDate] = useState(null);
  const [endDate, setEndDate] = useState(null);
  const [transactions, setTransactions] = useState([]);
  const [filteredTransactions, setFilteredTransactions] = useState([]);
  const [sortBy, setSortBy] = useState("date");
  const [sortOrder, setSortOrder] = useState("asc");
  const [activeFilter, setActiveFilter] = useState(null);

  useEffect(() => {
    axiosInstance
      .get("transaction", {
        params: { startDate, endDate },
      })
      .then((res) => {
        setTransactions(res.data);
        applyFiltersAndSort(res.data);
      })
      .catch((err) => {
        console.error("Failed to fetch transactions:", err);
      });
  }, [startDate, endDate]);

  useEffect(() => {
    applyFiltersAndSort(transactions);
  }, [sortBy, sortOrder, transactions, activeFilter]);

  const applyFiltersAndSort = (data) => {
    let filteredData = data;

    if (activeFilter) {
      filteredData = filteredData.filter(
        (transaction) => transaction.type === activeFilter
      );
    }

    const sortedData = [...filteredData].sort((a, b) => {
      const aValue = sortBy === "date" ? new Date(a.date) : a[sortBy];
      const bValue = sortBy === "date" ? new Date(b.date) : b[sortBy];
      return sortOrder === "asc" ? aValue - bValue : bValue - aValue;
    });

    setFilteredTransactions(sortedData);
  };

  const handleStartDateChange = (date) => {
    setStartDate(date);
    if (endDate && date > endDate) {
      setEndDate(null);
    }
  };

  const handleEndDateChange = (date) => {
    setEndDate(date);
    if (startDate && date < startDate) {
      setStartDate(null);
    }
  };

  const handleSortChange = (e) => {
    const [sortByField, sortOrderValue] = e.target.value.split(",");
    setSortBy(sortByField);
    setSortOrder(sortOrderValue);
  };

  const handleFilter = (type) => {
    setActiveFilter(type);
  };

  const csvData = filteredTransactions.map((transaction) => ({
    Date: transaction.date,
    Name: transaction.name,
    Type: transaction.type,
    Amount: transaction.amount,
  }));

  return (
    <div className="container mx-auto p-6">
      <div className="bg-white p-6 rounded-lg shadow-lg mb-6">
        <div className="flex flex-col md:flex-row justify-between mb-4">
          <div className="mb-4 md:mb-0">
            <label className="block text-lg font-semibold mb-2">
              Start Date
            </label>
            <DatePicker
              selected={startDate}
              onChange={handleStartDateChange}
              placeholderText="Select start date"
              className="p-2 border border-gray-300 rounded-lg w-full"
              maxDate={endDate || new Date()}
            />
          </div>
          <div className="md:ml-4">
            <label className="block text-lg font-semibold mb-2">End Date</label>
            <DatePicker
              selected={endDate}
              onChange={handleEndDateChange}
              placeholderText="Select end date"
              className="p-2 border border-gray-300 rounded-lg w-full"
              minDate={startDate}
              maxDate={new Date()}
            />
          </div>
        </div>
        <div className="flex flex-col md:flex-row items-center mb-4">
          <div className="mb-4 md:mb-0 md:mr-4">
            <label className="block text-lg font-semibold mb-2">Sort By</label>
            <select
              onChange={handleSortChange}
              className="p-2 border border-gray-300 rounded-lg w-full"
            >
              <option value="date,asc">Date (Ascending)</option>
              <option value="date,desc">Date (Descending)</option>
              <option value="amount,asc">Amount (Ascending)</option>
              <option value="amount,desc">Amount (Descending)</option>
            </select>
          </div>
        </div>
        <div className="flex flex-col md:flex-row space-y-2 md:space-y-0 md:space-x-2">
          <button
            onClick={() => handleFilter("income")}
            className={`p-2 rounded-lg ${
              activeFilter === "income"
                ? "bg-blue-500 text-white"
                : "bg-blue-100 text-blue-700"
            }`}
          >
            Show Incomes
          </button>
          <button
            onClick={() => handleFilter("expense")}
            className={`p-2 rounded-lg ${
              activeFilter === "expense"
                ? "bg-red-500 text-white"
                : "bg-red-100 text-red-700"
            }`}
          >
            Show Expenses
          </button>
          <button
            onClick={() => setActiveFilter(null)}
            className={`p-2 rounded-lg ${
              activeFilter === null
                ? "bg-gray-500 text-white"
                : "bg-gray-100 text-gray-700"
            }`}
          >
            Show All
          </button>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-lg">
        <div className="flex justify-between items-center">
          <h2 className="text-2xl font-bold mb-4">Transaction Statement</h2>
          <CSVLink data={csvData} filename={"transactions.csv"}>
            <button className="bg-green-500 text-white p-2 rounded-lg hover:bg-green-600">
              <Icon
                className="text-white mr-2"
                icon={download}
                size={25}
              />
              Download CSV
            </button>
          </CSVLink>
        </div>
        <table className="w-full bg-gray-100 border border-gray-300 rounded-lg overflow-hidden">
          <thead className="bg-gray-200 text-left">
            <tr>
              <th className="p-3">Date</th>
              <th className="p-3">Name</th>
              <th className="p-3">Type</th>
              <th className="p-3">Amount</th>
            </tr>
          </thead>
          <tbody>
            {filteredTransactions.length === 0 ? (
              <tr>
                <td colSpan="4" className="p-3 text-center">
                  No transactions found.
                </td>
              </tr>
            ) : (
              filteredTransactions.map((transaction) => (
                <tr
                  key={transaction.id}
                  className={`border-t ${
                    transaction.type === "income"
                      ? "bg-green-100"
                      : "bg-red-100"
                  }`}
                >
                  <td className="p-3">
                    {new Date(transaction.date).toLocaleDateString()}
                  </td>
                  <td className="p-3">{transaction.name}</td>
                  <td className="p-3">{transaction.type}</td>
                  <td className="p-3">₹{transaction.amount}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Statement;

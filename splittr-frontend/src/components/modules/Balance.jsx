import PropTypes from "prop-types";
const Balance = ({ totals, loading }) => {
  return (
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
            <p className="text-green-500 text-lg font-semibold mr-2">Income</p>
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
        <p className="w-full m-auto text-center text-gray-700 mb-8">
          This Month
        </p>
        <div className="flex flex-col space-y-6">
          <div className="flex items-center">
            <p className="text-green-500 text-xl font-semibold mr-4">Income:</p>
            <div className="text-3xl font-bold">
              {loading ? (
                <div className="h-8 bg-gray-200 rounded animate-pulse w-24"></div>
              ) : (
                `₹${totals.monthlyIncome}`
              )}
            </div>
          </div>
          <div className="flex items-center">
            <p className="text-red-500 text-xl font-semibold mr-4">Expenses:</p>
            <div className="text-3xl font-bold">
              {loading ? (
                <div className="h-8 bg-gray-200 rounded animate-pulse w-24"></div>
              ) : (
                `₹${totals.monthlyExpense}`
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Balance;

Balance.propTypes = {
  totals: PropTypes.object.isRequired,
  loading: PropTypes.bool.isRequired,
};

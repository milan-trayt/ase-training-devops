import { useState } from "react";
import PropTypes from "prop-types";
import axiosInstance from "../../utils/axiosInstance";
import { toast } from "react-toastify";

const ViewSplits = ({ splits, setSplits, loading }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentParticipant, setCurrentParticipant] = useState(null);
  const [currentSplit, setCurrentSplit] = useState(null);
  const [amountReceived, setAmountReceived] = useState(0);
  const [submittingParticipantAmount, setSubmittingParticipantAmount] =
    useState(false);

  const openModal = (participant, split) => {
    setCurrentParticipant(participant);
    setCurrentSplit(split);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setAmountReceived("");
  };

  const handleAmountSubmit = () => {
    if (currentParticipant && amountReceived) {
      setSubmittingParticipantAmount(true);
      if (parseInt(amountReceived) > currentParticipant.amount) {
        toast.error("Amount cannot be greater than remaining balance");
        setSubmittingParticipantAmount(false);
        return;
      }else if (parseInt(amountReceived) <= 0) {
        toast.error("Amount should be greater than 0");
        setSubmittingParticipantAmount(false);
        return;
      }
      axiosInstance
        .post("paidByOne", {
          splitId: currentSplit.id,
          participantName: currentParticipant.name,
          amount: parseInt(amountReceived),
        })
        .then(() => {
          toast.success("Amount submitted successfully");
          setSplits((prevSplits) =>
            prevSplits.map((split) =>
              split.id === currentSplit.id
                ? {
                    ...split,
                    participants: split.participants.map((participant) =>
                      participant.name === currentParticipant.name
                        ? {
                            ...participant,
                            amount: participant.amount - amountReceived, // Deduct the amount
                          }
                        : participant
                    ),
                  }
                : split
            )
          );
          closeModal();
        })
        .catch(() => {
          toast.error("Failed to submit amount");
        })
        .finally(() => {
          setSubmittingParticipantAmount(false);
        });
    }
  };

  const markAllReceived = (splitId) => {
    axiosInstance
      .post("paidByAll", { splitId })
      .then(() => {
        setSplits((prevSplits) =>
          prevSplits.map((split) =>
            split.id === splitId
              ? {
                  ...split,
                  participants: split.participants.map((participant) => ({
                    ...participant,
                    amount: 0,
                  })),
                }
              : split
          )
        );
        toast.success("Marked all received successfully");
      })
      .catch((error) => {
        toast.error("Failed to mark all received");
        console.error("Failed to mark all received:", error);
      });
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-semibold mb-4">Splits</h2>
      <ul>
        {loading
          ? Array.from({ length: 5 }).map((_, idx) => (
              <li
                key={idx}
                className="relative h-24 bg-gray-200 rounded mb-4 animate-pulse p-4"
              ></li>
            ))
          : splits
              .filter(
                (split) =>
                  split.participants.reduce(
                    (acc, participant) => acc + participant.amount,
                    0
                  ) > 0
              ).reverse()
              .map((split, idx) => {
                // Calculate the total amount of all participants
                const totalAmount = split.participants.reduce(
                  (acc, participant) => acc + participant.amount,
                  0
                );

                return (
                  <li
                    key={idx}
                    className="relative mb-6 p-4 border rounded-lg shadow-sm bg-gray-50"
                  >
                    <div className="flex justify-between items-center mb-4">
                      <h3 className="text-lg font-semibold">{split.name}</h3>
                      <button
                        onClick={() => markAllReceived(split.id)}
                        disabled={split.participants.every(
                          (p) => p.amount === 0
                        )} // Disable if all amounts are 0
                        className={`bg-blue-500 text-white px-3 py-1 rounded text-sm ${split.participants.every((p) => p.amount === 0) ? "opacity-50 cursor-not-allowed" : ""}`}
                      >
                        Received All
                      </button>
                    </div>
                    <p className="mb-4 text-gray-700">
                      Total Amount: ₹{totalAmount}
                    </p>
                    <div className="grid grid-cols-2 gap-4 sm:grid-cols-2 md:grid-cols-4">
                      {split.participants.map((participant, pIdx) => (
                        <div
                          key={pIdx}
                          className="p-4 border rounded-lg bg-white shadow-sm flex flex-col"
                        >
                          <p className="font-bold">{participant.name}</p>
                          <p className="text-gray-700">
                            Remaining Balance: ₹{participant.amount}
                          </p>
                          <button
                            onClick={() => openModal(participant, split)}
                            className="bg-green-500 text-white px-2 py-1 rounded text-xs mt-2"
                          >
                            Received
                          </button>
                        </div>
                      ))}
                    </div>
                  </li>
                );
              })}
      </ul>

      {/* Modal for entering amount */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center">
          <div className="bg-white p-6 rounded-lg shadow-md w-80">
            <h3 className="text-lg font-semibold mb-4">
              {currentParticipant?.name} Paying For {currentSplit?.name}
            </h3>
            <input
              type="number"
              value={amountReceived}
              onChange={(e) => setAmountReceived(e.target.value)}
              className="border rounded px-3 py-2 w-full mb-4"
              placeholder="Enter amount"
            />
            <div className="flex justify-end gap-4">
              <button
                disabled={submittingParticipantAmount}
                onClick={handleAmountSubmit}
                className={
                  `text-white px-4 py-2 rounded` +
                  (submittingParticipantAmount
                    ? " bg-gray-500"
                    : " bg-blue-500")
                }
              >
                Submit
              </button>
              <button
                onClick={closeModal}
                className="bg-gray-500 text-white px-4 py-2 rounded"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

ViewSplits.propTypes = {
  splits: PropTypes.array.isRequired,
  setSplits: PropTypes.func.isRequired,
  loading: PropTypes.bool.isRequired,
};

export default ViewSplits;

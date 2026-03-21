export const createSfuCoordinator = () => {
  const rooms = new Map();

  const ensure = (roomId) => {
    if (!rooms.has(roomId)) rooms.set(roomId, new Set());
    return rooms.get(roomId);
  };

  return {
    join: ({ roomId, userId }) => {
      ensure(roomId).add(userId);
      return { roomId, participants: [...ensure(roomId)], maxParticipants: 4 };
    },
    leave: ({ roomId, userId }) => {
      ensure(roomId).delete(userId);
      return { roomId, participants: [...ensure(roomId)] };
    },
    muteAll: ({ roomId }) => ({ roomId, mutedAll: true, participants: [...ensure(roomId)] }),
    snapshot: () => Object.fromEntries([...rooms.entries()].map(([id, members]) => [id, [...members]]))
  };
};

/**
 * In-memory repositories for gradual migration from raw state access.
 */

export const createInMemoryRepositories = (state) => {
  const users = {
    all: () => state.users,
    setAll: (rows) => {
      state.users = rows;
    },
    findByEmail: (email) => state.users.find((user) => user.email === email) ?? null,
    findById: (userId) => state.users.find((user) => user.id === userId) ?? null,
    exists: (userId) => state.users.some((user) => user.id === userId),
    create: (row) => {
      state.users.push(row);
      return row;
    }
  };

  const matches = {
    all: () => state.matches,
    setAll: (rows) => {
      state.matches = rows;
    },
    findById: (matchId) => state.matches.find((match) => match.id === matchId) ?? null,
    create: (row) => {
      state.matches.push(row);
      return row;
    }
  };

  return { users, matches };
};

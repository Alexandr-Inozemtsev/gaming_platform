namespace BigWalker.Core
{
    public sealed class PlayerState
    {
        public PlayerState(int playerId)
        {
            PlayerId = playerId;
        }

        public int PlayerId { get; }
        public int CurrentCellIndex { get; private set; }
        public bool SkipNextTurn { get; private set; }

        public void MoveTo(int cellIndex)
        {
            CurrentCellIndex = cellIndex;
        }

        public void SetSkipTurn(bool value)
        {
            SkipNextTurn = value;
        }
    }
}

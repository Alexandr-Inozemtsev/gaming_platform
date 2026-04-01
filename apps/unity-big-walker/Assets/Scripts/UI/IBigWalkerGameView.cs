namespace BigWalker.UI
{
    public interface IBigWalkerGameView
    {
        void SetActivePlayer(int playerId, int turnNumber, int roundNumber);
        void SetRollInteractable(bool isInteractable);
        void ShowDiceResult(int value);
        void ShowWinner(int playerId);
    }
}

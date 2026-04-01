using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace BigWalker.UI
{
    public sealed class BigWalkerHudView : MonoBehaviour, IBigWalkerGameView
    {
        [SerializeField] private TMP_Text activePlayerLabel;
        [SerializeField] private TMP_Text turnLabel;
        [SerializeField] private TMP_Text roundLabel;
        [SerializeField] private TMP_Text diceResultLabel;
        [SerializeField] private TMP_Text winnerLabel;
        [SerializeField] private Button rollButton;

        public void SetActivePlayer(int playerId, int turnNumber, int roundNumber)
        {
            if (activePlayerLabel != null) activePlayerLabel.text = $"Player {playerId}";
            if (turnLabel != null) turnLabel.text = $"Turn {turnNumber}";
            if (roundLabel != null) roundLabel.text = $"Round {roundNumber}";
        }

        public void SetRollInteractable(bool isInteractable)
        {
            if (rollButton != null)
            {
                rollButton.interactable = isInteractable;
            }
        }

        public void ShowDiceResult(int value)
        {
            if (diceResultLabel != null)
            {
                diceResultLabel.text = value.ToString();
            }
        }

        public void ShowWinner(int playerId)
        {
            if (winnerLabel != null)
            {
                winnerLabel.text = $"Player {playerId} wins!";
                winnerLabel.gameObject.SetActive(true);
            }

            SetRollInteractable(false);
        }
    }
}

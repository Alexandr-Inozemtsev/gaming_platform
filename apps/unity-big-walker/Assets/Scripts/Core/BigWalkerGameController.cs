using System.Collections;
using System.Collections.Generic;
using BigWalker.Animation;
using BigWalker.Board;
using BigWalker.Config;
using BigWalker.UI;
using UnityEngine;

namespace BigWalker.Core
{
    public sealed class BigWalkerGameController : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private BigWalkerGameConfig config;
        [SerializeField] private BoardPath boardPath;
        [SerializeField] private DiceRoller diceRoller;
        [SerializeField] private MonoBehaviour gameViewBehaviour;
        [SerializeField] private List<TokenMover> tokens = new();

        private readonly List<PlayerState> players = new();

        private IBigWalkerGameView GameView => gameViewBehaviour as IBigWalkerGameView;
        private int currentPlayerIndex;
        private int turnNumber = 1;
        private int roundNumber = 1;
        private bool turnInProgress;

        private void Start()
        {
            InitializeGame();
        }

        public void OnRollPressed()
        {
            if (turnInProgress || players.Count == 0)
            {
                return;
            }

            StartCoroutine(PlayTurnFlow());
        }

        private void InitializeGame()
        {
            players.Clear();
            currentPlayerIndex = 0;
            turnNumber = 1;
            roundNumber = 1;
            turnInProgress = false;

            var playersCount = Mathf.Min(config.PlayersCount, tokens.Count);
            for (var i = 0; i < playersCount; i++)
            {
                var player = new PlayerState(i + 1);
                players.Add(player);
                if (tokens[i] != null)
                {
                    tokens[i].transform.position = boardPath.GetCellPosition(0, config.PawnYOffset);
                }
            }

            UpdateHud();
            GameView?.SetRollInteractable(true);
        }

        private IEnumerator PlayTurnFlow()
        {
            turnInProgress = true;
            GameView?.SetRollInteractable(false);

            var player = players[currentPlayerIndex];
            if (player.SkipNextTurn)
            {
                player.SetSkipTurn(false);
                yield return new WaitForSeconds(0.3f);
                EndTurn();
                yield break;
            }

            var diceValue = 1;
            yield return StartCoroutine(diceRoller.RollAnimated(config.DiceMin, config.DiceMax, config.DiceRollDuration,
                value => diceValue = value));
            GameView?.ShowDiceResult(diceValue);

            var from = player.CurrentCellIndex;
            var intended = from + diceValue;
            var max = boardPath.LastIndex;

            if (config.ExactFinishRequired && intended > max)
            {
                intended = from;
            }
            else
            {
                intended = Mathf.Clamp(intended, 0, max);
            }

            var token = tokens[currentPlayerIndex];
            if (token != null)
            {
                yield return StartCoroutine(token.MoveStepByStep(boardPath, from, intended, config.MoveStepDuration, config.PawnYOffset));
            }

            player.MoveTo(intended);
            yield return StartCoroutine(ResolveCellEffect(player, token));

            if (player.CurrentCellIndex >= max)
            {
                GameView?.ShowWinner(player.PlayerId);
                turnInProgress = false;
                yield break;
            }

            EndTurn();
        }

        private IEnumerator ResolveCellEffect(PlayerState player, TokenMover token)
        {
            var cell = boardPath.GetCell(player.CurrentCellIndex);
            if (cell == null || cell.EffectType == CellEffectType.None)
            {
                yield break;
            }

            var max = boardPath.LastIndex;
            var effectValue = Mathf.Max(1, cell.EffectValue);

            switch (cell.EffectType)
            {
                case CellEffectType.Forward:
                {
                    var target = Mathf.Clamp(player.CurrentCellIndex + effectValue, 0, max);
                    yield return MoveByEffect(player, token, target);
                    break;
                }
                case CellEffectType.Backward:
                {
                    var target = Mathf.Clamp(player.CurrentCellIndex - effectValue, 0, max);
                    yield return MoveByEffect(player, token, target);
                    break;
                }
                case CellEffectType.SkipTurn:
                    player.SetSkipTurn(true);
                    break;
                case CellEffectType.ExtraTurn:
                    turnNumber--;
                    currentPlayerIndex = (currentPlayerIndex - 1 + players.Count) % players.Count;
                    break;
            }
        }

        private IEnumerator MoveByEffect(PlayerState player, TokenMover token, int target)
        {
            var from = player.CurrentCellIndex;
            if (token != null)
            {
                yield return StartCoroutine(token.MoveStepByStep(boardPath, from, target, config.MoveStepDuration, config.PawnYOffset));
            }

            player.MoveTo(target);
        }

        private void EndTurn()
        {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.Count;
            turnNumber++;
            if (currentPlayerIndex == 0)
            {
                roundNumber++;
            }

            turnInProgress = false;
            UpdateHud();
            GameView?.SetRollInteractable(true);
        }

        private void UpdateHud()
        {
            if (players.Count == 0)
            {
                return;
            }

            GameView?.SetActivePlayer(players[currentPlayerIndex].PlayerId, turnNumber, roundNumber);
        }
    }
}

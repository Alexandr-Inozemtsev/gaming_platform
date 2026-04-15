using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Минимальная "Большая бродилка" для быстрого старта в Unity 6.3.
/// Логика: 2 игрока, бросок кубика, движение по треку, победа на финише.
/// </summary>
public class BigWalkerGameController : MonoBehaviour
{
    [Header("Gameplay")]
    [SerializeField] private int trackLength = 24;
    [SerializeField] private int playersCount = 2;
    [SerializeField] private float cellSpacing = 1.6f;
    [SerializeField] private float pawnHeight = 0.55f;

    private readonly List<Transform> _trackCells = new();
    private readonly List<Transform> _pawns = new();
    private int[] _positions = System.Array.Empty<int>();
    private int _currentPlayer;
    private bool _finished;

    private Text _statusText = null!;
    private Button _rollButton = null!;
    private readonly Color[] _playerColors = { new(0.2f, 0.8f, 1f), new(1f, 0.75f, 0.2f), Color.green, Color.magenta };

    private void Start()
    {
        BuildTrack();
        BuildPawns();
        BuildHud();
        UpdateHud("Игра готова. Ход игрока 1");
    }

    private void BuildTrack()
    {
        for (int i = 0; i < trackLength; i++)
        {
            var cell = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cell.name = $"Cell_{i:00}";
            cell.transform.localScale = new Vector3(1.4f, 0.25f, 1.4f);
            cell.transform.position = new Vector3(i * cellSpacing, 0f, 0f);

            var renderer = cell.GetComponent<Renderer>();
            renderer.material.color = i == trackLength - 1 ? new Color(0.35f, 1f, 0.45f) : new Color(0.25f, 0.28f, 0.35f);
            _trackCells.Add(cell.transform);
        }
    }

    private void BuildPawns()
    {
        _positions = new int[playersCount];

        for (int i = 0; i < playersCount; i++)
        {
            var pawn = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            pawn.name = $"Pawn_{i + 1}";
            pawn.transform.localScale = new Vector3(0.75f, 0.75f, 0.75f);

            var renderer = pawn.GetComponent<Renderer>();
            renderer.material.color = _playerColors[i % _playerColors.Length];

            _pawns.Add(pawn.transform);
            MovePawn(i, 0);
        }
    }

    private void BuildHud()
    {
        var canvasGo = new GameObject("HUD_Canvas", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
        var canvas = canvasGo.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        var scaler = canvasGo.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);

        var panel = CreateUiElement("Panel", canvasGo.transform);
        var panelImage = panel.AddComponent<Image>();
        panelImage.color = new Color(0.06f, 0.08f, 0.12f, 0.78f);
        var panelRect = panel.GetComponent<RectTransform>();
        panelRect.anchorMin = new Vector2(0.02f, 0.02f);
        panelRect.anchorMax = new Vector2(0.45f, 0.22f);
        panelRect.offsetMin = Vector2.zero;
        panelRect.offsetMax = Vector2.zero;

        var status = CreateUiElement("StatusText", panel.transform);
        _statusText = status.AddComponent<Text>();
        _statusText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        _statusText.alignment = TextAnchor.UpperLeft;
        _statusText.color = Color.white;
        _statusText.fontSize = 30;
        var statusRect = status.GetComponent<RectTransform>();
        statusRect.anchorMin = new Vector2(0.04f, 0.36f);
        statusRect.anchorMax = new Vector2(0.96f, 0.96f);
        statusRect.offsetMin = Vector2.zero;
        statusRect.offsetMax = Vector2.zero;

        var roll = CreateUiElement("RollButton", panel.transform);
        var rollImage = roll.AddComponent<Image>();
        rollImage.color = new Color(0.18f, 0.54f, 1f, 1f);
        _rollButton = roll.AddComponent<Button>();
        _rollButton.targetGraphic = rollImage;
        _rollButton.onClick.AddListener(OnRollClicked);
        var rollRect = roll.GetComponent<RectTransform>();
        rollRect.anchorMin = new Vector2(0.04f, 0.06f);
        rollRect.anchorMax = new Vector2(0.44f, 0.30f);
        rollRect.offsetMin = Vector2.zero;
        rollRect.offsetMax = Vector2.zero;

        var rollTextGo = CreateUiElement("RollText", roll.transform);
        var rollText = rollTextGo.AddComponent<Text>();
        rollText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        rollText.text = "Бросить кубик";
        rollText.alignment = TextAnchor.MiddleCenter;
        rollText.color = Color.white;
        rollText.fontSize = 28;
        var rollTextRect = rollTextGo.GetComponent<RectTransform>();
        rollTextRect.anchorMin = Vector2.zero;
        rollTextRect.anchorMax = Vector2.one;
        rollTextRect.offsetMin = Vector2.zero;
        rollTextRect.offsetMax = Vector2.zero;
    }

    private static GameObject CreateUiElement(string name, Transform parent)
    {
        var go = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);
        return go;
    }

    private void OnRollClicked()
    {
        if (_finished) return;

        int dice = Random.Range(1, 7);
        int next = Mathf.Min(_positions[_currentPlayer] + dice, trackLength - 1);
        _positions[_currentPlayer] = next;
        MovePawn(_currentPlayer, next);

        if (next >= trackLength - 1)
        {
            _finished = true;
            _rollButton.interactable = false;
            UpdateHud($"Игрок {_currentPlayer + 1} выбросил {dice} и победил!");
            HighlightWinner(_currentPlayer);
            return;
        }

        int previousPlayer = _currentPlayer;
        _currentPlayer = (_currentPlayer + 1) % playersCount;
        UpdateHud($"Игрок {previousPlayer + 1}: {dice}. Ход игрока {_currentPlayer + 1}");
    }

    private void MovePawn(int playerIndex, int cellIndex)
    {
        var cellPosition = _trackCells[cellIndex].position;
        float xOffset = playerIndex * 0.45f;
        _pawns[playerIndex].position = new Vector3(cellPosition.x + xOffset, pawnHeight, 0f);
    }

    private void HighlightWinner(int winnerIndex)
    {
        var renderer = _pawns[winnerIndex].GetComponent<Renderer>();
        renderer.material.color = Color.yellow;
        _pawns[winnerIndex].localScale = Vector3.one * 1.1f;
    }

    private void UpdateHud(string text)
    {
        _statusText.text = text;
    }
}

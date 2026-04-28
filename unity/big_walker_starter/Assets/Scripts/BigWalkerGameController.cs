using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// Big Walker demo controller:
/// - стартовое меню выбора фишки игрока (1 из 6)
/// - случайный выбор уникальных фишек для ИИ
/// - анимированное пошаговое движение фишек по полю
/// </summary>
public class BigWalkerGameController : MonoBehaviour
{
    [System.Serializable]
    private sealed class PawnAssetEntry
    {
        [SerializeField] private string title = string.Empty;
        [SerializeField] private GameObject characterPrefab = null!;
        [SerializeField] private Vector3 worldScale = Vector3.one;
        [SerializeField] private Vector3 worldRotationEuler = Vector3.zero;

        public string Title => title;
        public GameObject CharacterPrefab => characterPrefab;
        public Vector3 WorldScale => worldScale;
        public Vector3 WorldRotationEuler => worldRotationEuler;
    }

    private readonly struct PawnArchetype
    {
        public PawnArchetype(string title, PrimitiveType primitive, Color baseColor, Color accentColor)
        {
            Title = title;
            Primitive = primitive;
            BaseColor = baseColor;
            AccentColor = accentColor;
        }

        public string Title { get; }
        public PrimitiveType Primitive { get; }
        public Color BaseColor { get; }
        public Color AccentColor { get; }
    }

    [Header("Gameplay")]
    [SerializeField] private int trackLength = 26;
    [SerializeField] private int playersCount = 4;
    [SerializeField] private float cellSpacing = 1.65f;
    [SerializeField] private float pawnHeight = 0.58f;
    [SerializeField] private float cameraHeight = 12f;
    [SerializeField] private float cameraMoveDuration = 0.32f;
    [SerializeField] private float stepMoveDuration = 0.16f;
    [Header("Character Assets (optional)")]
    [SerializeField] private PawnAssetEntry[] pawnAssets = System.Array.Empty<PawnAssetEntry>();

    private readonly PawnArchetype[] _pawnArchetypes =
    {
        new PawnArchetype("Emerald Drake", PrimitiveType.Capsule, new Color(0.22f, 0.72f, 0.28f), new Color(0.55f, 1f, 0.55f)),
        new PawnArchetype("Mystic Owl", PrimitiveType.Sphere, new Color(0.58f, 0.40f, 0.22f), new Color(1f, 0.93f, 0.68f)),
        new PawnArchetype("Azure Cat", PrimitiveType.Sphere, new Color(0.24f, 0.78f, 0.95f), new Color(0.68f, 0.96f, 1f)),
        new PawnArchetype("Ruby Imp", PrimitiveType.Cube, new Color(0.90f, 0.20f, 0.20f), new Color(1f, 0.58f, 0.45f)),
        new PawnArchetype("Frost Wolf", PrimitiveType.Capsule, new Color(0.82f, 0.92f, 1f), new Color(0.64f, 0.82f, 1f)),
        new PawnArchetype("Amethyst Fox", PrimitiveType.Cylinder, new Color(0.74f, 0.38f, 0.98f), new Color(0.98f, 0.72f, 1f))
    };

    private readonly List<Transform> _trackCells = new();
    private readonly List<Transform> _pawns = new();
    private readonly List<Vector3> _pawnBaseScales = new();
    private readonly List<int> _playerPawnIndices = new();
    private readonly List<Button> _pawnSelectButtons = new();

    private int[] _positions = System.Array.Empty<int>();
    private Transform _dice = null!;
    private int _currentPlayer;
    private bool _finished;
    private bool _rollingDice;
    private bool _gameStarted;

    private int _selectedHumanPawn = -1;

    private Canvas _selectionCanvas = null!;
    private Canvas _gameCanvas = null!;
    private Text _statusText = null!;
    private Button _rollButton = null!;
    private Text _selectedPawnText = null!;
    private readonly List<Button> _playersCountButtons = new();

    private void Start()
    {
        BuildTrack();
        BuildDice();
        EnsureEventSystem();
        BuildSelectionHud();
        BuildGameHud();
        SetGameHudVisible(false);

        FocusCameraInstant(0);
    }

    private void BuildTrack()
    {
        for (int i = 0; i < trackLength; i++)
        {
            var cell = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cell.name = $"Cell_{i:00}";
            cell.transform.localScale = new Vector3(1.38f, 0.22f, 1.38f);
            cell.transform.position = new Vector3(i * cellSpacing, 0f, 0f);

            var renderer = cell.GetComponent<Renderer>();
            renderer.material.color = i == trackLength - 1 ? new Color(0.33f, 0.95f, 0.48f) : new Color(0.14f, 0.18f, 0.25f);
            renderer.material.SetColor("_EmissionColor", i == trackLength - 1 ? new Color(0.08f, 0.35f, 0.12f) : new Color(0.03f, 0.05f, 0.09f));
            _trackCells.Add(cell.transform);
        }
    }

    private void BuildDice()
    {
        var diceGo = GameObject.CreatePrimitive(PrimitiveType.Cube);
        diceGo.name = "Dice";
        diceGo.transform.localScale = Vector3.one * 0.9f;
        diceGo.transform.position = new Vector3(1.1f, 0.72f, -1.85f);
        var renderer = diceGo.GetComponent<Renderer>();
        renderer.material.color = new Color(0.93f, 0.95f, 0.98f);
        _dice = diceGo.transform;
        _dice.gameObject.SetActive(false);
    }

    private void BuildSelectionHud()
    {
        _selectionCanvas = CreateCanvas("Selection_Canvas");

        var panel = CreatePanel(_selectionCanvas.transform, new Color(0.05f, 0.07f, 0.11f, 0.86f),
            new Vector2(0.08f, 0.1f), new Vector2(0.92f, 0.92f));

        CreateText(panel.transform, "Title", "Select Players", 76, TextAnchor.UpperCenter,
            new Vector2(0.12f, 0.82f), new Vector2(0.88f, 0.96f));

        CreateText(panel.transform, "Subtitle", "Choose your token and player count", 34, TextAnchor.UpperCenter,
            new Vector2(0.12f, 0.74f), new Vector2(0.88f, 0.84f));

        _selectedPawnText = CreateText(panel.transform, "SelectedPawn", "Selected: none", 30, TextAnchor.MiddleCenter,
            new Vector2(0.12f, 0.67f), new Vector2(0.88f, 0.74f));

        CreatePawnSelectionCards(panel.transform);
        CreatePlayersCountSelector(panel.transform);
        CreateStartButton(panel.transform);
    }

    private void CreatePawnSelectionCards(Transform parent)
    {
        float left = 0.06f;
        float right = 0.94f;
        float width = (right - left) / _pawnArchetypes.Length;

        for (int i = 0; i < _pawnArchetypes.Length; i++)
        {
            var archetype = _pawnArchetypes[i];
            float minX = left + width * i;
            float maxX = minX + width - 0.005f;

            var button = CreateButton(parent, $"PawnCard_{i}", archetype.BaseColor,
                new Vector2(minX, 0.37f), new Vector2(maxX, 0.64f));
            int capturedIndex = i;
            button.onClick.AddListener(() => OnPawnSelected(capturedIndex));

            var title = CreateText(button.transform, "Title", archetype.Title, 21, TextAnchor.UpperCenter,
                new Vector2(0.05f, 0.68f), new Vector2(0.95f, 0.98f));
            title.color = Color.white;

            var icon = CreateUiElement("Icon", button.transform);
            var iconImage = icon.AddComponent<Image>();
            iconImage.color = archetype.AccentColor;
            var iconRect = icon.GetComponent<RectTransform>();
            iconRect.anchorMin = new Vector2(0.27f, 0.12f);
            iconRect.anchorMax = new Vector2(0.73f, 0.62f);
            iconRect.offsetMin = Vector2.zero;
            iconRect.offsetMax = Vector2.zero;

            _pawnSelectButtons.Add(button);
        }
    }

    private void CreatePlayersCountSelector(Transform parent)
    {
        CreateText(parent, "PlayersCountTitle", "Choose number of adventurers", 28, TextAnchor.MiddleCenter,
            new Vector2(0.2f, 0.28f), new Vector2(0.8f, 0.35f));

        const int minPlayers = 2;
        const int maxPlayers = 6;
        float left = 0.16f;
        float right = 0.84f;
        float width = (right - left) / (maxPlayers - minPlayers + 1);

        for (int value = minPlayers; value <= maxPlayers; value++)
        {
            float minX = left + width * (value - minPlayers);
            float maxX = minX + width - 0.012f;

            var button = CreateButton(parent, $"Players_{value}", new Color(0.14f, 0.2f, 0.3f, 1f),
                new Vector2(minX, 0.16f), new Vector2(maxX, 0.27f));
            int capturedValue = value;
            button.onClick.AddListener(() => OnPlayersCountSelected(capturedValue));
            CreateText(button.transform, "Label", value.ToString(), 34, TextAnchor.MiddleCenter,
                new Vector2(0f, 0f), new Vector2(1f, 1f));

            _playersCountButtons.Add(button);
        }

        OnPlayersCountSelected(playersCount);
    }

    private void CreateStartButton(Transform parent)
    {
        var startButton = CreateButton(parent, "StartButton", new Color(0.78f, 0.42f, 0.14f, 1f),
            new Vector2(0.36f, 0.04f), new Vector2(0.64f, 0.13f));
        startButton.onClick.AddListener(OnStartGameClicked);
        CreateText(startButton.transform, "Label", "START GAME", 38, TextAnchor.MiddleCenter,
            new Vector2(0f, 0f), new Vector2(1f, 1f));
    }

    private void BuildGameHud()
    {
        _gameCanvas = CreateCanvas("HUD_Canvas");

        var panel = CreatePanel(_gameCanvas.transform, new Color(0.05f, 0.07f, 0.1f, 0.78f),
            new Vector2(0.02f, 0.02f), new Vector2(0.48f, 0.22f));

        _statusText = CreateText(panel.transform, "StatusText", string.Empty, 30, TextAnchor.UpperLeft,
            new Vector2(0.04f, 0.34f), new Vector2(0.96f, 0.96f));

        _rollButton = CreateButton(panel.transform, "RollButton", new Color(0.17f, 0.53f, 1f, 1f),
            new Vector2(0.04f, 0.06f), new Vector2(0.44f, 0.3f));
        _rollButton.onClick.AddListener(OnRollClicked);
        CreateText(_rollButton.transform, "RollText", "Бросить кубик", 28, TextAnchor.MiddleCenter,
            new Vector2(0f, 0f), new Vector2(1f, 1f));
    }

    private void OnPawnSelected(int pawnIndex)
    {
        _selectedHumanPawn = pawnIndex;
        _selectedPawnText.text = $"Selected: {_pawnArchetypes[pawnIndex].Title}";

        for (int i = 0; i < _pawnSelectButtons.Count; i++)
        {
            var image = _pawnSelectButtons[i].GetComponent<Image>();
            bool isSelected = i == pawnIndex;
            Color baseColor = _pawnArchetypes[i].BaseColor;
            image.color = isSelected ? Color.Lerp(baseColor, Color.white, 0.25f) : baseColor;
        }
    }

    private void OnPlayersCountSelected(int value)
    {
        playersCount = Mathf.Clamp(value, 2, 6);
        for (int i = 0; i < _playersCountButtons.Count; i++)
        {
            int represented = i + 2;
            var image = _playersCountButtons[i].GetComponent<Image>();
            image.color = represented == playersCount
                ? new Color(0.22f, 0.62f, 1f, 1f)
                : new Color(0.14f, 0.2f, 0.3f, 1f);
        }
    }

    private void OnStartGameClicked()
    {
        if (_gameStarted) return;
        if (_selectedHumanPawn < 0)
        {
            _selectedPawnText.text = "Selected: choose one token first";
            _selectedPawnText.color = new Color(1f, 0.55f, 0.55f);
            return;
        }

        _selectedPawnText.color = Color.white;
        _gameStarted = true;
        _selectionCanvas.gameObject.SetActive(false);
        SetGameHudVisible(true);
        _dice.gameObject.SetActive(true);

        PreparePlayers();
        BuildPawns();
        _currentPlayer = 0;
        FocusCameraInstant(_currentPlayer);
        HighlightActivePawn(_currentPlayer);
        UpdateHud($"Вы выбрали {_pawnArchetypes[_playerPawnIndices[0]].Title}. Ход игрока 1");
        _rollButton.interactable = true;
    }

    private void PreparePlayers()
    {
        _playerPawnIndices.Clear();
        _playerPawnIndices.Add(_selectedHumanPawn);

        var candidates = new List<int>();
        for (int i = 0; i < _pawnArchetypes.Length; i++)
        {
            if (i != _selectedHumanPawn)
            {
                candidates.Add(i);
            }
        }

        for (int i = candidates.Count - 1; i > 0; i--)
        {
            int swap = Random.Range(0, i + 1);
            (candidates[i], candidates[swap]) = (candidates[swap], candidates[i]);
        }

        int neededBots = playersCount - 1;
        for (int i = 0; i < neededBots && i < candidates.Count; i++)
        {
            _playerPawnIndices.Add(candidates[i]);
        }

        while (_playerPawnIndices.Count < playersCount)
        {
            _playerPawnIndices.Add(Random.Range(0, _pawnArchetypes.Length));
        }
    }

    private void BuildPawns()
    {
        foreach (var pawn in _pawns)
        {
            if (pawn != null)
            {
                Destroy(pawn.gameObject);
            }
        }

        _pawns.Clear();
        _pawnBaseScales.Clear();
        _positions = new int[playersCount];

        for (int i = 0; i < playersCount; i++)
        {
            int archetypeIndex = _playerPawnIndices[Mathf.Min(i, _playerPawnIndices.Count - 1)];
            PawnArchetype archetype = _pawnArchetypes[archetypeIndex];

            var pawn = CreatePawnObject(archetypeIndex, i, archetype);

            _pawns.Add(pawn.transform);
            _pawnBaseScales.Add(pawn.transform.localScale);
            MovePawn(i, 0);
        }
    }

    private GameObject CreatePawnObject(int archetypeIndex, int playerIndex, PawnArchetype archetype)
    {
        var asset = GetPawnAsset(archetypeIndex);
        if (asset != null && asset.CharacterPrefab != null)
        {
            var pawn = Instantiate(asset.CharacterPrefab);
            pawn.name = $"Pawn_{playerIndex + 1}_{archetype.Title}";
            pawn.transform.localScale = asset.WorldScale == Vector3.zero ? Vector3.one : asset.WorldScale;
            pawn.transform.rotation = Quaternion.Euler(asset.WorldRotationEuler);
            ApplyPawnColors(pawn.transform, archetype);
            return pawn;
        }

        var fallbackPawn = BigWalkerPawnFactory.CreateStylizedPawn(archetypeIndex, $"Pawn_{playerIndex + 1}_{archetype.Title}");
        fallbackPawn.transform.localScale = new Vector3(0.9f, 0.9f, 0.9f);
        ApplyPawnColors(fallbackPawn.transform, archetype);
        return fallbackPawn;
    }

    private PawnAssetEntry GetPawnAsset(int archetypeIndex)
    {
        if (pawnAssets == null) return null;
        if (archetypeIndex < 0 || archetypeIndex >= pawnAssets.Length) return null;
        return pawnAssets[archetypeIndex];
    }

    private static void ApplyPawnColors(Transform pawnRoot, PawnArchetype archetype)
    {
        var renderers = pawnRoot.GetComponentsInChildren<Renderer>(true);
        foreach (var renderer in renderers)
        {
            renderer.material.color = archetype.BaseColor;
            renderer.material.SetColor("_EmissionColor", archetype.AccentColor * 0.22f);
        }
    }

    private static Vector3 GetPawnScale(PrimitiveType primitive)
    {
        return primitive switch
        {
            PrimitiveType.Cube => new Vector3(0.65f, 0.65f, 0.65f),
            PrimitiveType.Cylinder => new Vector3(0.58f, 0.72f, 0.58f),
            PrimitiveType.Capsule => new Vector3(0.56f, 0.72f, 0.56f),
            _ => new Vector3(0.7f, 0.7f, 0.7f)
        };
    }

    private void OnRollClicked()
    {
        if (_finished || !_rollButton.interactable || _rollingDice || !_gameStarted) return;
        _rollButton.interactable = false;
        StartCoroutine(RollAndApplyTurn());
    }

    private IEnumerator RollAndApplyTurn()
    {
        _rollingDice = true;
        int dice = Random.Range(1, 7);
        yield return AnimateDiceRoll(dice, 0.7f);

        int from = _positions[_currentPlayer];
        int to = Mathf.Min(from + dice, trackLength - 1);
        _positions[_currentPlayer] = to;

        yield return MovePawnAnimatedStepByStep(_currentPlayer, from, to);
        yield return MoveCameraAnimated(_currentPlayer);

        if (to >= trackLength - 1)
        {
            _finished = true;
            UpdateHud($"Игрок {_currentPlayer + 1} ({_pawnArchetypes[_playerPawnIndices[_currentPlayer]].Title}) победил! Бросок: {dice}");
            HighlightWinner(_currentPlayer);
            _rollingDice = false;
            yield break;
        }

        int previousPlayer = _currentPlayer;
        _currentPlayer = (_currentPlayer + 1) % playersCount;
        HighlightActivePawn(_currentPlayer);
        yield return MoveCameraAnimated(_currentPlayer);
        UpdateHud($"Игрок {previousPlayer + 1}: {dice}. Ход игрока {_currentPlayer + 1} ({_pawnArchetypes[_playerPawnIndices[_currentPlayer]].Title})");

        _rollingDice = false;
        _rollButton.interactable = true;
    }

    private void MovePawn(int playerIndex, int cellIndex)
    {
        var cellPosition = _trackCells[cellIndex].position;
        Vector2 lane = GetLaneOffset(playerIndex);
        _pawns[playerIndex].position = new Vector3(cellPosition.x + lane.x, pawnHeight, lane.y);
    }

    private IEnumerator MovePawnAnimatedStepByStep(int playerIndex, int fromCell, int toCell)
    {
        if (toCell <= fromCell)
        {
            MovePawn(playerIndex, toCell);
            yield break;
        }

        var pawn = _pawns[playerIndex];
        for (int cell = fromCell + 1; cell <= toCell; cell++)
        {
            Vector3 start = pawn.position;
            Vector3 end = GetPawnWorldPosition(playerIndex, cell);

            float elapsed = 0f;
            while (elapsed < stepMoveDuration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / stepMoveDuration);
                float arc = Mathf.Sin(t * Mathf.PI) * 0.28f;
                float stretch = 1f + Mathf.Sin(t * Mathf.PI) * 0.08f;

                pawn.position = Vector3.Lerp(start, end, t) + Vector3.up * arc;
                pawn.localScale = GetPawnScaleForPlayer(playerIndex) * new Vector3(stretch, 1f / stretch, stretch);
                pawn.Rotate(Vector3.up, 230f * Time.deltaTime, Space.World);

                yield return null;
            }

            pawn.position = end;
            pawn.localScale = GetPawnScaleForPlayer(playerIndex);
        }
    }

    private Vector3 GetPawnScaleForPlayer(int playerIndex)
    {
        if (_pawnBaseScales.Count == 0)
        {
            int archetypeIndex = _playerPawnIndices[Mathf.Min(playerIndex, _playerPawnIndices.Count - 1)];
            return GetPawnScale(_pawnArchetypes[archetypeIndex].Primitive);
        }

        int index = Mathf.Clamp(playerIndex, 0, _pawnBaseScales.Count - 1);
        return _pawnBaseScales[index];
    }

    private Vector3 GetPawnWorldPosition(int playerIndex, int cellIndex)
    {
        var cellPosition = _trackCells[cellIndex].position;
        Vector2 lane = GetLaneOffset(playerIndex);
        return new Vector3(cellPosition.x + lane.x, pawnHeight, lane.y);
    }

    private static Vector2 GetLaneOffset(int playerIndex)
    {
        Vector2[] lanes =
        {
            new Vector2(-0.32f, -0.28f),
            new Vector2(0.32f, -0.28f),
            new Vector2(-0.32f, 0.28f),
            new Vector2(0.32f, 0.28f),
            new Vector2(0f, -0.48f),
            new Vector2(0f, 0.48f)
        };

        return lanes[Mathf.Clamp(playerIndex, 0, lanes.Length - 1)];
    }

    private IEnumerator AnimateDiceRoll(int finalValue, float duration)
    {
        if (_dice == null) yield break;

        Quaternion startRot = _dice.rotation;
        Quaternion endRot = GetDiceRotationForValue(finalValue);
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            _dice.rotation = Quaternion.Euler(
                Mathf.Lerp(0f, 720f, t) + Mathf.LerpAngle(startRot.eulerAngles.x, endRot.eulerAngles.x, t),
                Mathf.Lerp(0f, 900f, t) + Mathf.LerpAngle(startRot.eulerAngles.y, endRot.eulerAngles.y, t),
                Mathf.Lerp(0f, 540f, t) + Mathf.LerpAngle(startRot.eulerAngles.z, endRot.eulerAngles.z, t)
            );
            _dice.position = new Vector3(_dice.position.x, 0.72f + Mathf.Sin(t * Mathf.PI) * 0.16f, _dice.position.z);
            yield return null;
        }

        _dice.rotation = endRot;
        _dice.position = new Vector3(_dice.position.x, 0.72f, _dice.position.z);
    }

    private static Quaternion GetDiceRotationForValue(int value)
    {
        return value switch
        {
            1 => Quaternion.Euler(0f, 0f, 0f),
            2 => Quaternion.Euler(0f, 0f, 90f),
            3 => Quaternion.Euler(90f, 0f, 0f),
            4 => Quaternion.Euler(-90f, 0f, 0f),
            5 => Quaternion.Euler(0f, 0f, -90f),
            6 => Quaternion.Euler(180f, 0f, 0f),
            _ => Quaternion.identity
        };
    }

    private void FocusCameraInstant(int playerIndex)
    {
        var camera = Camera.main;
        if (camera == null || _trackCells.Count == 0) return;
        (Vector3 targetPos, Vector3 targetLook) = GetCameraTargets(playerIndex);
        camera.transform.position = targetPos;
        camera.transform.LookAt(targetLook);
    }

    private IEnumerator MoveCameraAnimated(int playerIndex)
    {
        var camera = Camera.main;
        if (camera == null || _trackCells.Count == 0) yield break;

        (Vector3 targetPos, Vector3 targetLook) = GetCameraTargets(playerIndex);
        Vector3 startPos = camera.transform.position;
        Quaternion startRot = camera.transform.rotation;
        Quaternion targetRot = Quaternion.LookRotation(targetLook - targetPos);

        float elapsed = 0f;
        while (elapsed < cameraMoveDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / cameraMoveDuration);
            camera.transform.position = Vector3.Lerp(startPos, targetPos, t);
            camera.transform.rotation = Quaternion.Slerp(startRot, targetRot, t);
            yield return null;
        }

        camera.transform.position = targetPos;
        camera.transform.rotation = targetRot;
    }

    private (Vector3 pos, Vector3 lookAt) GetCameraTargets(int playerIndex)
    {
        int index = _positions.Length > 0 ? Mathf.Clamp(_positions[Mathf.Clamp(playerIndex, 0, _positions.Length - 1)], 0, _trackCells.Count - 1) : 0;
        float focusX = _trackCells[index].position.x + 0.4f;
        Vector3 targetPos = new Vector3(focusX + 3.2f, cameraHeight, -cameraHeight * 0.6f);
        Vector3 targetLook = new Vector3(focusX, 0.1f, 0f);
        return (targetPos, targetLook);
    }

    private void HighlightActivePawn(int activeIndex)
    {
        for (int i = 0; i < _pawns.Count; i++)
        {
            var renderer = _pawns[i].GetComponent<Renderer>();
            if (renderer == null) continue;

            int archetypeIndex = _playerPawnIndices[Mathf.Min(i, _playerPawnIndices.Count - 1)];
            Color baseColor = _pawnArchetypes[archetypeIndex].BaseColor;
            bool isActive = i == activeIndex;

            renderer.material.color = isActive ? Color.Lerp(baseColor, Color.white, 0.2f) : baseColor;
            renderer.material.SetColor("_EmissionColor", (isActive ? _pawnArchetypes[archetypeIndex].AccentColor * 0.45f : _pawnArchetypes[archetypeIndex].AccentColor * 0.2f));
        }
    }

    private void HighlightWinner(int winnerIndex)
    {
        HighlightActivePawn(winnerIndex);
        _pawns[winnerIndex].localScale = GetPawnScaleForPlayer(winnerIndex) * 1.15f;
    }

    private void UpdateHud(string text)
    {
        _statusText.text = text;
    }

    private static void EnsureEventSystem()
    {
        if (Object.FindFirstObjectByType<EventSystem>() != null) return;
        var eventSystemGo = new GameObject("EventSystem", typeof(EventSystem));
        var inputSystemModuleType = System.Type.GetType("UnityEngine.InputSystem.UI.InputSystemUIInputModule, Unity.InputSystem");
        if (inputSystemModuleType != null)
        {
            eventSystemGo.AddComponent(inputSystemModuleType);
            return;
        }

        eventSystemGo.AddComponent<StandaloneInputModule>();
    }

    private static Canvas CreateCanvas(string name)
    {
        var canvasGo = new GameObject(name, typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
        var canvas = canvasGo.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;

        var scaler = canvasGo.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920f, 1080f);

        return canvas;
    }

    private static GameObject CreateUiElement(string name, Transform parent)
    {
        var go = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);
        return go;
    }

    private static GameObject CreatePanel(Transform parent, Color color, Vector2 anchorMin, Vector2 anchorMax)
    {
        var panel = CreateUiElement("Panel", parent);
        var image = panel.AddComponent<Image>();
        image.color = color;

        var rect = panel.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
        return panel;
    }

    private static Text CreateText(Transform parent, string name, string content, int size, TextAnchor anchor, Vector2 anchorMin, Vector2 anchorMax)
    {
        var textGo = CreateUiElement(name, parent);
        var text = textGo.AddComponent<Text>();
        text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        text.text = content;
        text.fontSize = size;
        text.color = Color.white;
        text.alignment = anchor;

        var rect = textGo.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;

        return text;
    }

    private static Button CreateButton(Transform parent, string name, Color color, Vector2 anchorMin, Vector2 anchorMax)
    {
        var buttonGo = CreateUiElement(name, parent);
        var image = buttonGo.AddComponent<Image>();
        image.color = color;

        var button = buttonGo.AddComponent<Button>();
        button.targetGraphic = image;

        var rect = buttonGo.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
        return button;
    }

    private void SetGameHudVisible(bool visible)
    {
        _gameCanvas.gameObject.SetActive(visible);
    }
}

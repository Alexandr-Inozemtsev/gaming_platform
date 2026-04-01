using UnityEngine;

namespace BigWalker.Config
{
    [CreateAssetMenu(menuName = "BigWalker/Game Config", fileName = "BigWalkerGameConfig")]
    public sealed class BigWalkerGameConfig : ScriptableObject
    {
        [field: SerializeField, Range(2, 6)] public int PlayersCount { get; private set; } = 4;
        [field: SerializeField, Min(1)] public int DiceMin { get; private set; } = 1;
        [field: SerializeField, Min(2)] public int DiceMax { get; private set; } = 6;
        [field: SerializeField] public bool ExactFinishRequired { get; private set; } = false;
        [field: SerializeField, Min(0f)] public float PawnYOffset { get; private set; } = 0.4f;
        [field: SerializeField, Min(0.01f)] public float MoveStepDuration { get; private set; } = 0.17f;
        [field: SerializeField, Min(0.05f)] public float DiceRollDuration { get; private set; } = 0.8f;
    }
}

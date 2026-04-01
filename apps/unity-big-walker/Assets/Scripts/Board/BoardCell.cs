using UnityEngine;

namespace BigWalker.Board
{
    public enum CellEffectType
    {
        None = 0,
        Forward = 1,
        Backward = 2,
        SkipTurn = 3,
        ExtraTurn = 4,
    }

    public sealed class BoardCell : MonoBehaviour
    {
        [field: SerializeField] public int Index { get; private set; }
        [field: SerializeField] public CellEffectType EffectType { get; private set; } = CellEffectType.None;
        [field: SerializeField] public int EffectValue { get; private set; } = 0;

        public Vector3 GetWorldPosition(float yOffset = 0f)
        {
            var pos = transform.position;
            pos.y += yOffset;
            return pos;
        }

        public void Configure(int index, CellEffectType effectType = CellEffectType.None, int effectValue = 0)
        {
            Index = Mathf.Max(0, index);
            EffectType = effectType;
            EffectValue = Mathf.Max(0, effectValue);
        }
    }
}

using System.Collections.Generic;
using UnityEngine;

namespace BigWalker.Board
{
    public sealed class BoardPath : MonoBehaviour
    {
        [SerializeField] private List<BoardCell> cells = new();

        public int LastIndex => Mathf.Max(0, cells.Count - 1);
        public int CellCount => cells.Count;

        public BoardCell GetCell(int index)
        {
            if (cells.Count == 0)
            {
                return null;
            }

            var clamped = Mathf.Clamp(index, 0, LastIndex);
            return cells[clamped];
        }

        public Vector3 GetCellPosition(int index, float yOffset = 0f)
        {
            var cell = GetCell(index);
            return cell == null ? transform.position : cell.GetWorldPosition(yOffset);
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            for (var i = 0; i < cells.Count; i++)
            {
                if (cells[i] != null)
                {
                    cells[i].Configure(i, cells[i].EffectType, cells[i].EffectValue);
                }
            }
        }
#endif
    }
}

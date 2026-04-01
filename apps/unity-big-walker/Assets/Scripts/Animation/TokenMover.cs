using System.Collections;
using BigWalker.Board;
using UnityEngine;

namespace BigWalker.Animation
{
    public sealed class TokenMover : MonoBehaviour
    {
        [SerializeField, Min(0.05f)] private float hopHeight = 0.18f;

        public IEnumerator MoveStepByStep(BoardPath path, int fromIndex, int toIndex, float durationPerStep, float yOffset)
        {
            if (path == null || fromIndex == toIndex)
            {
                yield break;
            }

            var direction = fromIndex < toIndex ? 1 : -1;
            var current = fromIndex;

            while (current != toIndex)
            {
                var next = current + direction;
                var start = transform.position;
                var end = path.GetCellPosition(next, yOffset);
                var t = 0f;

                while (t < 1f)
                {
                    t += Time.deltaTime / durationPerStep;
                    var linear = Vector3.Lerp(start, end, t);
                    linear.y += Mathf.Sin(t * Mathf.PI) * hopHeight;
                    transform.position = linear;
                    yield return null;
                }

                transform.position = end;
                current = next;
            }
        }
    }
}

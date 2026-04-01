using System;
using System.Collections;
using TMPro;
using UnityEngine;

namespace BigWalker.Animation
{
    public sealed class DiceRoller : MonoBehaviour
    {
        [SerializeField] private Transform diceVisual;
        [SerializeField] private TMP_Text diceValueLabel;

        public IEnumerator RollAnimated(int min, int max, float duration, Action<int> onFinished)
        {
            var elapsed = 0f;
            var shown = min;

            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                shown = UnityEngine.Random.Range(min, max + 1);
                SetDiceLabel(shown);

                if (diceVisual != null)
                {
                    diceVisual.Rotate(new Vector3(720f, 900f, 810f) * Time.deltaTime, Space.Self);
                }

                yield return null;
            }

            var finalValue = UnityEngine.Random.Range(min, max + 1);
            SetDiceLabel(finalValue);
            onFinished?.Invoke(finalValue);
        }

        private void SetDiceLabel(int value)
        {
            if (diceValueLabel != null)
            {
                diceValueLabel.text = value.ToString();
            }
        }
    }
}

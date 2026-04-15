using UnityEngine;

/// <summary>
/// Автоматически подготавливает пустую сцену для BigWalkerGameController.
/// Повесьте скрипт на любой объект в сцене (например, Bootstrap).
/// </summary>
public class BigWalkerSceneBootstrap : MonoBehaviour
{
    private void Awake()
    {
        EnsureCamera();
        EnsureLight();
        EnsureController();
    }

    private static void EnsureCamera()
    {
        if (Camera.main != null) return;

        var camGo = new GameObject("Main Camera");
        var camera = camGo.AddComponent<Camera>();
        camGo.tag = "MainCamera";
        camera.clearFlags = CameraClearFlags.Skybox;
        camera.fieldOfView = 42f;
        camGo.transform.position = new Vector3(16f, 16f, -20f);
        camGo.transform.LookAt(new Vector3(16f, 0f, 0f));
    }

    private static void EnsureLight()
    {
        if (Object.FindFirstObjectByType<Light>() != null) return;

        var lightGo = new GameObject("Directional Light");
        var light = lightGo.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.1f;
        lightGo.transform.rotation = Quaternion.Euler(50f, -35f, 0f);
    }

    private static void EnsureController()
    {
        if (Object.FindFirstObjectByType<BigWalkerGameController>() != null) return;

        var controllerGo = new GameObject("BigWalkerGameController");
        controllerGo.AddComponent<BigWalkerGameController>();
    }
}

using UnityEngine;

/// <summary>
/// Кодогенерация стилизованных 3D-фишек (без внешних FBX).
/// Нужна как fallback, если настоящие ассеты не назначены в инспекторе.
/// </summary>
public static class BigWalkerPawnFactory
{
    public static GameObject CreateStylizedPawn(int archetypeIndex, string pawnName)
    {
        var root = new GameObject(pawnName);
        BuildPedestal(root.transform);

        switch (archetypeIndex)
        {
            case 0:
                BuildDrake(root.transform);
                break;
            case 1:
                BuildOwl(root.transform);
                break;
            case 2:
                BuildCat(root.transform);
                break;
            case 3:
                BuildImp(root.transform);
                break;
            case 4:
                BuildFrostWolf(root.transform);
                break;
            default:
                BuildArcaneFox(root.transform);
                break;
        }

        return root;
    }

    private static void BuildPedestal(Transform parent)
    {
        var baseDisc = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        baseDisc.name = "Pedestal";
        baseDisc.transform.SetParent(parent, false);
        baseDisc.transform.localPosition = new Vector3(0f, -0.25f, 0f);
        baseDisc.transform.localScale = new Vector3(0.48f, 0.08f, 0.48f);

        var ring = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        ring.name = "PedestalRing";
        ring.transform.SetParent(parent, false);
        ring.transform.localPosition = new Vector3(0f, -0.18f, 0f);
        ring.transform.localScale = new Vector3(0.58f, 0.03f, 0.58f);
    }

    private static void BuildDrake(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.06f, 0f), new Vector3(0.52f, 0.42f, 0.72f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.20f, 0.33f), new Vector3(0.34f, 0.28f, 0.34f), "Head");
        CreatePart(parent, PrimitiveType.Cylinder, new Vector3(0.02f, 0.28f, 0.49f), new Vector3(0.06f, 0.18f, 0.06f), "HornL", new Vector3(-26f, 0f, -20f));
        CreatePart(parent, PrimitiveType.Cylinder, new Vector3(-0.02f, 0.28f, 0.49f), new Vector3(0.06f, 0.18f, 0.06f), "HornR", new Vector3(-26f, 0f, 20f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0f, 0.03f, -0.45f), new Vector3(0.14f, 0.24f, 0.34f), "Tail", new Vector3(18f, 0f, 0f));
        CreatePart(parent, PrimitiveType.Cube, new Vector3(0.26f, 0.1f, -0.05f), new Vector3(0.12f, 0.22f, 0.32f), "WingL", new Vector3(0f, 0f, 25f));
        CreatePart(parent, PrimitiveType.Cube, new Vector3(-0.26f, 0.1f, -0.05f), new Vector3(0.12f, 0.22f, 0.32f), "WingR", new Vector3(0f, 0f, -25f));
    }

    private static void BuildOwl(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.04f, 0f), new Vector3(0.52f, 0.52f, 0.46f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.22f, 0.16f), new Vector3(0.36f, 0.34f, 0.30f), "Head");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.09f, 0.16f), new Vector3(0.28f, 0.28f, 0.20f), "Chest");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.22f, 0.08f, 0.04f), new Vector3(0.11f, 0.22f, 0.16f), "WingL", new Vector3(0f, 0f, 24f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(-0.22f, 0.08f, 0.04f), new Vector3(0.11f, 0.22f, 0.16f), "WingR", new Vector3(0f, 0f, -24f));
        CreatePart(parent, PrimitiveType.Cube, new Vector3(0f, 0.18f, 0.33f), new Vector3(0.08f, 0.07f, 0.10f), "Beak");
    }

    private static void BuildCat(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.06f, 0f), new Vector3(0.56f, 0.46f, 0.64f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.22f, 0.26f), new Vector3(0.34f, 0.30f, 0.34f), "Head");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.14f, 0.38f, 0.28f), new Vector3(0.06f, 0.16f, 0.06f), "EarL", new Vector3(0f, 0f, -22f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(-0.14f, 0.38f, 0.28f), new Vector3(0.06f, 0.16f, 0.06f), "EarR", new Vector3(0f, 0f, 22f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.24f, 0.12f, -0.34f), new Vector3(0.07f, 0.28f, 0.07f), "Tail", new Vector3(30f, 0f, -32f));
    }

    private static void BuildImp(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.08f, 0f), new Vector3(0.52f, 0.40f, 0.52f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.24f, 0.23f), new Vector3(0.32f, 0.28f, 0.30f), "Head");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.22f, 0.2f, 0.18f), new Vector3(0.05f, 0.18f, 0.05f), "EarL", new Vector3(0f, 0f, 48f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(-0.22f, 0.2f, 0.18f), new Vector3(0.05f, 0.18f, 0.05f), "EarR", new Vector3(0f, 0f, -48f));
        CreatePart(parent, PrimitiveType.Cylinder, new Vector3(0.26f, 0.09f, 0.22f), new Vector3(0.05f, 0.09f, 0.05f), "FistL");
        CreatePart(parent, PrimitiveType.Cylinder, new Vector3(-0.26f, 0.09f, 0.22f), new Vector3(0.05f, 0.09f, 0.05f), "FistR");
    }

    private static void BuildFrostWolf(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0f, 0.08f, 0.02f), new Vector3(0.48f, 0.42f, 0.52f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.22f, 0.26f), new Vector3(0.36f, 0.30f, 0.34f), "Head");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.17f, 0.36f, 0.25f), new Vector3(0.05f, 0.20f, 0.05f), "IceEarL");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(-0.17f, 0.36f, 0.25f), new Vector3(0.05f, 0.20f, 0.05f), "IceEarR");
        CreatePart(parent, PrimitiveType.Cube, new Vector3(0f, 0.34f, 0.12f), new Vector3(0.22f, 0.20f, 0.22f), "CrystalCrown", new Vector3(0f, 45f, 0f));
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0f, 0.15f, -0.32f), new Vector3(0.08f, 0.22f, 0.08f), "Tail", new Vector3(22f, 0f, 0f));
    }

    private static void BuildArcaneFox(Transform parent)
    {
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0f, 0.08f, 0.02f), new Vector3(0.44f, 0.40f, 0.50f), "Body");
        CreatePart(parent, PrimitiveType.Sphere, new Vector3(0f, 0.22f, 0.22f), new Vector3(0.30f, 0.28f, 0.30f), "Head");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.12f, 0.36f, 0.26f), new Vector3(0.05f, 0.17f, 0.05f), "EarL");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(-0.12f, 0.36f, 0.26f), new Vector3(0.05f, 0.17f, 0.05f), "EarR");
        CreatePart(parent, PrimitiveType.Capsule, new Vector3(0.23f, 0.10f, -0.30f), new Vector3(0.10f, 0.26f, 0.10f), "Tail", new Vector3(30f, 0f, -35f));
    }

    private static void CreatePart(Transform parent, PrimitiveType primitive, Vector3 localPos, Vector3 localScale, string partName, Vector3 localEuler = default)
    {
        var part = GameObject.CreatePrimitive(primitive);
        part.name = partName;
        part.transform.SetParent(parent, false);
        part.transform.localPosition = localPos;
        part.transform.localRotation = Quaternion.Euler(localEuler);
        part.transform.localScale = localScale;
    }
}

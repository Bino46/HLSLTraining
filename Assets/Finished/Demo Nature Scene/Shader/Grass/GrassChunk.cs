using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class GrassChunk : MonoBehaviour
{
    bool chunkVisible;
    bool forceShow;
    MeshFilter chunkRenderer;
    TerrainData terrainData;

    [Header("Chunk")]
    int chunkSize;
    float density;
    float spacing;
    Material grassMat;
    Vector3 basePosition;
    Material chunkMat;

    [Header("Single Instance")]
    Mesh grassMesh;
    float rotationOffset;
    float displacementAmount;
    RenderParams rp;
    List<Matrix4x4> instanceList = new ();

    #region System
    void OnBecameInvisible()
    {
        chunkVisible = false;
    }

    void OnBecameVisible()
    {
        chunkVisible = true;
    }

    public void RenderChunk()
    {   
        if((chunkVisible || forceShow) && instanceList.Count > 0)
            Graphics.RenderMeshInstanced(rp, grassMesh, 0, instanceList);
    }
    #endregion

    #region Chunk Setup
    public void SetChunkValues(int ChunkSize, float chunkDensity, Mesh baseObject, Material instanceMaterial, float RotationOffset, float DisplacementAmount, float grassSpacing, bool forceGrass, Material newChunkMat)
    {
        chunkSize = ChunkSize;
        density = chunkDensity;
        spacing = grassSpacing;

        grassMesh = baseObject;
        grassMat = instanceMaterial;

        rotationOffset = RotationOffset;
        displacementAmount = DisplacementAmount;

        forceShow = forceGrass;

        chunkMat = newChunkMat;

        GrassGrid.OnRenderChunk += RenderChunk;
    }

    public void GetTerrainData(TerrainData newData)
    {
        terrainData = newData;
    }

    void CreateShape()
    {
        chunkRenderer = gameObject.AddComponent<MeshFilter>();

        MeshRenderer renderer = gameObject.AddComponent<MeshRenderer>();
        renderer.material = chunkMat;
        renderer.shadowCastingMode = ShadowCastingMode.Off;

        GameObject primitive = GameObject.CreatePrimitive(PrimitiveType.Cube);
        chunkRenderer.mesh = primitive.GetComponent<MeshFilter>().sharedMesh;
        Destroy(primitive);
        
        transform.localScale = (Vector3.forward + Vector3.right) * chunkSize + Vector3.up;
        transform.localPosition += (Vector3.forward + Vector3.right) * chunkSize * 0.5f;
    }

    public void GenerateChunk()
    {
        basePosition = transform.position;
        CreateShape();
        
        grassMat.enableInstancing = true;
        
        rp = new RenderParams(grassMat);
        rp.shadowCastingMode = ShadowCastingMode.Off;

        int gridDensity = (int)(chunkSize * density);

        for(int x = 0; x < gridDensity; x++)
        {
            for(int z = 0; z < gridDensity; z++)
            {
                SetInstanceValues(x,z);
            }
        }
    }
    #endregion

    #region Single instance
    void MakeInstance(Vector3 pos, Vector3 rotation)
    {
        instanceList.Add(Matrix4x4.TRS(pos, Quaternion.Euler(rotation), Vector3.one)); 
    }

    void SetInstanceValues(int x, int y)
    {
        Vector2 randomPosition = new Vector2();
        randomPosition.x = Random.insideUnitCircle.x * displacementAmount - displacementAmount * 0.5f;
        randomPosition.y = Random.insideUnitCircle.y * displacementAmount - displacementAmount * 0.5f;

        Vector3 pos = Vector3.zero;

        float finalSpacing = spacing / density;

        pos.x = x * finalSpacing + basePosition.x + randomPosition.x;
        pos.z = y * finalSpacing + basePosition.z + randomPosition.y;
        pos.y = GetYGrassPos(new Vector2(pos.x, pos.z)); //Check beneath the grass for ground check. if not grass, discard.

        if(pos.y == -1)
            return;

        Vector3 randomRotation = new Vector3();
        randomRotation.x = -90;
        randomRotation.z = Random.value * rotationOffset;

        MakeInstance(pos, randomRotation);
    }

    float GetYGrassPos(Vector2 uvPos)
    {
        if(terrainData == null)
            return basePosition.y;

        Vector3 worldPos = new Vector3(uvPos.x, basePosition.y, uvPos.y); 

        int layer = TerrainManager._instance.GetDominantTextureIndexAt(worldPos);

        if(layer != 0)
            return -1; 

        float yPos = Terrain.activeTerrain.SampleHeight(new Vector3(uvPos.x, transform.position.y, uvPos.y));
        return yPos;
    }
    #endregion
}

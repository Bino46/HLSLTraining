using System.Collections.Generic;
using UnityEngine;

public class GrassGrid : MonoBehaviour
{
    [Header("Grid Params")]
    [SerializeField] Vector2 rowsAndColums;
    [SerializeField] Material chunkMat;

    public delegate void RenderAllChunks();
    public static event RenderAllChunks OnRenderChunk;

    [Header("Chunk Param")]
    [SerializeField] int chunkSize;
    [SerializeField] float chunkDensity;
    [SerializeField] float grassSpacing;
    [SerializeField] Mesh grassObject;
    [SerializeField] Material grassMat;
    [SerializeField] bool forceShowGrass;

    [Header("Single Instance Param")]
    [SerializeField] float rotationOffset;
    [SerializeField] float displacementAmount;
    [Header("Terrain hugging")]
    [SerializeField] bool stickToTerrain;
    [SerializeField] TerrainData terrainData;

    GameObject MakeChunk(int i, int j)
    {
        string newName = "Chunk" + i.ToString() + j.ToString();

        GameObject chunk = new ();
        chunk.name = newName;

        chunk.transform.SetParent(transform);
        chunk.transform.localPosition = Vector3.zero;

        Vector3 newPos = new Vector3(chunkSize * i, 0, chunkSize * j);
        chunk.transform.localPosition += newPos * grassSpacing;

        return chunk;
    }

    void SetChunk(GameObject chunk)
    {
        chunk.AddComponent<GrassChunk>();
        
        GrassChunk data = chunk.GetComponent<GrassChunk>();

        if(stickToTerrain)
        {
            data.GetTerrainData(terrainData);
        }
        
        data.SetChunkValues(chunkSize, chunkDensity, grassObject, grassMat, rotationOffset, displacementAmount, grassSpacing, forceShowGrass, chunkMat);
        data.GenerateChunk();
    }

    void Start()
    { 
        for(int i = 0; i < rowsAndColums.x; i++)
        {
            for(int j = 0; j < rowsAndColums.y;j++)
            {
                GameObject chunk = MakeChunk(i,j);
                SetChunk(chunk);
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRenderChunk?.Invoke();
    }
}

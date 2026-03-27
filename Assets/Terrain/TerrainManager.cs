using UnityEngine;

public class TerrainManager : MonoBehaviour
{
    [SerializeField] Terrain ThisTerrain;
    TerrainData ThisTerrainData => ThisTerrain.terrainData;
    float[,,] CachedTerrainAlphamapData;
    public static TerrainManager _instance;

    void Awake()
    {
        _instance = this;
    }

    void Start()
    {
        CachedTerrainAlphamapData = ThisTerrainData.GetAlphamaps(0, 0, ThisTerrainData.alphamapWidth, ThisTerrainData.alphamapHeight);
    }

    bool ContainsIndex(float[,,] array, int index, int dimension)
    {
        if (index < 0)
            return false;

        return index < array.GetLength(dimension);
    }    

    public int GetDominantTextureIndexAt(Vector3 worldPosition)
    {
        Vector3Int alphamapCoordinates = ConvertToAlphamapCoordinates(worldPosition);
        
        if(!ContainsIndex(CachedTerrainAlphamapData, alphamapCoordinates.x, dimension : 1))
            return -1;

        if(!ContainsIndex(CachedTerrainAlphamapData, alphamapCoordinates.z, dimension : 0))
            return -1;


        int mostDominantTextureIndex = 0;
        float greatestTextureWeight = float.MinValue;

        int textureCount = CachedTerrainAlphamapData.GetLength(2);
        for (int textureIndex = 0; textureIndex < textureCount; textureIndex++)
        {
            // I am really not sure why the x and z coordinates are out of order here, I think it's just Unity being lame and weird
            float textureWeight = CachedTerrainAlphamapData[alphamapCoordinates.z, alphamapCoordinates.x, textureIndex];

            if (textureWeight > greatestTextureWeight)
            {
                greatestTextureWeight = textureWeight;
                mostDominantTextureIndex = textureIndex;
            }
        }

        return mostDominantTextureIndex;
    }
    Vector3Int ConvertToAlphamapCoordinates(Vector3 _worldPosition)
    {
        Vector3 relativePosition = _worldPosition - transform.position;
        // Important note: terrains cannot be rotated, so we don't have to worry about rotation

        return new Vector3Int
        (
            x: Mathf.RoundToInt((relativePosition.x / ThisTerrainData.size.x) * ThisTerrainData.alphamapWidth),
            y: 0,
            z: Mathf.RoundToInt((relativePosition.z / ThisTerrainData.size.z) * ThisTerrainData.alphamapHeight)
        );
    }
}

